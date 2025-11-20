-- Ativar output para ver os logs
SET SERVEROUTPUT ON SIZE 1000000;

-- Bloco de Limpeza (Executar antes de popular para evitar duplicatas)
-- A ordem é importante para respeitar as Foreign Keys
BEGIN
    DELETE FROM auditoria_log;
    DELETE FROM analytics_metrica;
    DELETE FROM analytics_evento;
    DELETE FROM relatorios;
    DELETE FROM tarefas;
    DELETE FROM reunioes;
    DELETE FROM usuarios;
    DBMS_OUTPUT.PUT_LINE('Tabelas limpas para novo povoamento.');
END;
/

-- Bloco de Povoamento
DECLARE
    v_evento_id_tarefa NUMBER;
BEGIN
    -- 1. Inserir Usuários (Usando PKG_USUARIOS)
    PKG_USUARIOS.PRC_INS_USUARIO('Felipe Silva Maciel', 'felipe.silva@work360.com', 'hash123');
    PKG_USUARIOS.PRC_INS_USUARIO('Eduardo Nagado', 'eduardo.nagado@work360.com', 'hash456');
    PKG_USUARIOS.PRC_INS_USUARIO('Gustavo Lazzuri', 'gustavo.lazzuri@work360.com', 'hash789');

    -- Salva os usuários válidos antes de prosseguir para o teste de exceção
    COMMIT;

    -- Teste de exceção (Função 2)
    -- Envolvemos a chamada que esperamos que falhe em seu próprio bloco
    -- para que o script principal possa continuar.
    BEGIN
        PKG_USUARIOS.PRC_INS_USUARIO('Email Invalido', 'email-invalido.com', 'hash789');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('-> Teste de exceção: Falha esperada ao inserir e-mail inválido. Script continuará.');
    END;

    -- 2. Inserir Tarefas (Vamos precisar do ID delas para os eventos)
    -- (Para simplificar, faremos inserts diretos, mas o ideal seria um PKG_TAREFAS.PRC_INS_TAREFA)
    INSERT INTO tarefas VALUES (SEQ_TAREFAS.NEXTVAL, 1, 'Revisar Relatório Mensal', 'Verificar dados', 'alta', 120, 'pendente');
    INSERT INTO tarefas VALUES (SEQ_TAREFAS.NEXTVAL, 1, 'Planejar Sprint 5', 'Definir prioridades', 'alta', 60, 'pendente');
    INSERT INTO tarefas VALUES (SEQ_TAREFAS.NEXTVAL, 1, 'Curso de Reskilling IA', 'Assistir módulo 2', 'baixa', 90, 'pendente');
    INSERT INTO tarefas VALUES (SEQ_TAREFAS.NEXTVAL, 2, 'Desenvolver API de Analytics', 'Endpoint /metricas', 'alta', 240, 'pendente');
    INSERT INTO tarefas VALUES (SEQ_TAREFAS.NEXTVAL, 2, 'Testes Unitários', 'Cobrir serviço de relatórios', 'media', 120, 'pendente');
    -- (Inserir mais 5 tarefas...)

    -- 3. Inserir Reuniões
    INSERT INTO reunioes VALUES (SEQ_REUNIOES.NEXTVAL, 1, 'Daily Scrum', 'Alinhamento', SYSTIMESTAMP - INTERVAL '1' HOUR, 'http://meet.work360.com/daily');
    INSERT INTO reunioes VALUES (SEQ_REUNIOES.NEXTVAL, 1, '1:1 com Gestor', 'Feedback', SYSTIMESTAMP + INTERVAL '2' DAY, 'http://meet.work360.com/1on1');
    -- (Inserir mais 8 reuniões...)

    -- 4. Simular Eventos da Ana (Usuário 1) - HOJE (Lógica simplificada)
    -- Inserindo diretamente com os timestamps corretos para evitar race conditions.
    -- Bloco de Foco 1 (90 min): Terminou há 100 minutos.
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(1, NULL, NULL, 'FOCO_INICIO', SYSTIMESTAMP - INTERVAL '190' MINUTE);
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(1, NULL, NULL, 'FOCO_FIM', SYSTIMESTAMP - INTERVAL '100' MINUTE);

    -- Reunião 1 (30 min): Terminou há 60 minutos.
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(p_usuario_id => 1, p_reuniao_id => 1, p_tipo_evento => 'REUNIAO_INICIO', p_timestamp => SYSTIMESTAMP - INTERVAL '90' MINUTE);
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(p_usuario_id => 1, p_reuniao_id => 1, p_tipo_evento => 'REUNIAO_FIM', p_timestamp => SYSTIMESTAMP - INTERVAL '60' MINUTE);

    -- Bloco de Foco 2 (60 min): Terminou agora.
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(1, NULL, NULL, 'FOCO_INICIO', SYSTIMESTAMP - INTERVAL '60' MINUTE);
    PKG_ANALYTICS.PRC_INS_EVENTO_TESTE(1, NULL, NULL, 'FOCO_FIM', SYSTIMESTAMP);

    -- Tarefa Concluída
    PKG_ANALYTICS.PRC_INS_EVENTO(p_usuario_id => 1, p_tarefa_id => 1, p_tipo_evento => 'TAREFA_CONCLUIDA', p_evento_id_out => v_evento_id_tarefa);
    UPDATE tarefas SET status = 'concluida' WHERE id = 1; -- Dispara o trigger

    -- Tarefa Concluída
    PKG_ANALYTICS.PRC_INS_EVENTO(p_usuario_id => 1, p_tarefa_id => 2, p_tipo_evento => 'TAREFA_CONCLUIDA', p_evento_id_out => v_evento_id_tarefa);
    UPDATE tarefas SET status = 'concluida' WHERE id = 2; -- Dispara o trigger
    
    -- (Simular mais eventos para usuário 2...)
    -- Salva os eventos para que fiquem visíveis para a procedure de cálculo
    COMMIT;
    -- 5. Inserir Relatórios (Base para exportação)
    INSERT INTO relatorios (id, usuario_id, data_inicio, data_fim, tarefas_concluidas, risco_burnout, tendencia_produtividade, recomendacaoIA, resumo_geral)
    VALUES (SEQ_RELATORIOS.NEXTVAL, 1, TRUNC(SYSDATE, 'MM'), SYSDATE, 25, 0.65, 'alta', 'Recomendamos blocos de foco "deep work" nas terças.', 'Produtividade alta, risco de burnout moderado.');
    
    INSERT INTO relatorios (id, usuario_id, data_inicio, data_fim, tarefas_concluidas, risco_burnout, tendencia_produtividade, recomendacaoIA, resumo_geral)
    VALUES (SEQ_RELATORIOS.NEXTVAL, 2, TRUNC(SYSDATE, 'MM'), SYSDATE, 40, 0.20, 'alta', 'Sugerir mentoria para novos membros do time.', 'Produtividade excelente e bem-estar em dia.');
    
    COMMIT; -- Salva o restante dos dados
END;
/