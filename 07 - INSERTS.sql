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
    PKG_USUARIOS.PRC_INS_USUARIO('Carla Souza', 'carla.souza@work360.com', 'hash111');
    PKG_USUARIOS.PRC_INS_USUARIO('Marcos Almeida', 'marcos.almeida@work360.com', 'hash222');
    PKG_USUARIOS.PRC_INS_USUARIO('Beatriz Costa', 'beatriz.costa@work360.com', 'hash333');
    PKG_USUARIOS.PRC_INS_USUARIO('Lucas Pereira', 'lucas.pereira@work360.com', 'hash444');
    PKG_USUARIOS.PRC_INS_USUARIO('Juliana Ferreira', 'juliana.ferreira@work360.com', 'hash555');
    PKG_USUARIOS.PRC_INS_USUARIO('Rafael Oliveira', 'rafael.oliveira@work360.com', 'hash666');
    PKG_USUARIOS.PRC_INS_USUARIO('Fernanda Lima', 'fernanda.lima@work360.com', 'hash777');

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
    -- Usando a procedure PKG_OPERATIONS.PRC_INS_TAREFA
    PKG_OPERATIONS.PRC_INS_TAREFA(1, 'Revisar Relatório Mensal', 'Verificar dados', 'alta', 120);
    PKG_OPERATIONS.PRC_INS_TAREFA(1, 'Planejar Sprint 5', 'Definir prioridades', 'alta', 60);
    PKG_OPERATIONS.PRC_INS_TAREFA(1, 'Curso de Reskilling IA', 'Assistir módulo 2', 'baixa', 90);
    PKG_OPERATIONS.PRC_INS_TAREFA(1, 'Preparar apresentação para cliente', 'Criar slides', 'alta', 180);
    PKG_OPERATIONS.PRC_INS_TAREFA(1, 'Feedback 360', 'Preencher formulário para pares', 'media', 30);
    PKG_OPERATIONS.PRC_INS_TAREFA(2, 'Desenvolver API de Analytics', 'Endpoint /metricas', 'alta', 240);
    PKG_OPERATIONS.PRC_INS_TAREFA(2, 'Testes Unitários', 'Cobrir serviço de relatórios', 'media', 120);
    PKG_OPERATIONS.PRC_INS_TAREFA(2, 'Refatorar módulo de autenticação', 'Melhorar segurança', 'alta', 180);
    PKG_OPERATIONS.PRC_INS_TAREFA(3, 'Onboarding novo colega', 'Apresentar o projeto', 'media', 60);
    PKG_OPERATIONS.PRC_INS_TAREFA(3, 'Analisar logs de produção', 'Investigar erro 503', 'alta', 90);

    -- 3. Inserir Reuniões
    -- Usando a procedure PKG_OPERATIONS.PRC_INS_REUNIAO
    PKG_OPERATIONS.PRC_INS_REUNIAO(1, 'Daily Scrum', 'Alinhamento', SYSTIMESTAMP - INTERVAL '1' HOUR, 'http://meet.work360.com/daily');
    PKG_OPERATIONS.PRC_INS_REUNIAO(1, '1:1 com Gestor', 'Feedback', SYSTIMESTAMP + INTERVAL '2' DAY, 'http://meet.work360.com/1on1');
    PKG_OPERATIONS.PRC_INS_REUNIAO(2, 'Planning da Sprint', 'Definir escopo da próxima sprint', SYSTIMESTAMP + INTERVAL '3' DAY, 'http://meet.work360.com/planning');
    PKG_OPERATIONS.PRC_INS_REUNIAO(3, 'Reunião de Kick-off', 'Início do projeto X', SYSTIMESTAMP + INTERVAL '4' DAY, 'http://meet.work360.com/kickoff');
    PKG_OPERATIONS.PRC_INS_REUNIAO(1, 'Review da Sprint', 'Apresentar resultados', SYSTIMESTAMP + INTERVAL '5' DAY, 'http://meet.work360.com/review');
    PKG_OPERATIONS.PRC_INS_REUNIAO(2, 'Sessão de Brainstorming', 'Novas features para IA', SYSTIMESTAMP + INTERVAL '6' DAY, 'http://meet.work360.com/brainstorm');
    PKG_OPERATIONS.PRC_INS_REUNIAO(4, 'Alinhamento de Design', 'Discutir mockups', SYSTIMESTAMP + INTERVAL '1' DAY, 'http://meet.work360.com/design');
    PKG_OPERATIONS.PRC_INS_REUNIAO(5, 'Retrospectiva', 'Pontos de melhoria do time', SYSTIMESTAMP + INTERVAL '7' DAY, 'http://meet.work360.com/retro');
    PKG_OPERATIONS.PRC_INS_REUNIAO(1, 'Apresentação para Stakeholders', 'Demo do produto', SYSTIMESTAMP + INTERVAL '10' DAY, 'http://meet.work360.com/stakeholders');
    PKG_OPERATIONS.PRC_INS_REUNIAO(2, 'Workshop de Segurança', 'Melhores práticas de desenvolvimento seguro', SYSTIMESTAMP + INTERVAL '12' DAY, 'http://meet.work360.com/security');

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