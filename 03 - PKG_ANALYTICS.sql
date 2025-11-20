CREATE OR REPLACE PACKAGE PKG_ANALYTICS AS
    -- Simula o endpoint POST /analytics/eventos
    PROCEDURE PRC_INS_EVENTO (
        p_usuario_id IN analytics_evento.usuario_id%TYPE,
        p_tarefa_id  IN analytics_evento.tarefa_id%TYPE DEFAULT NULL,
        p_reuniao_id IN analytics_evento.reuniao_id%TYPE DEFAULT NULL,
        p_tipo_evento IN analytics_evento.tipo_evento%TYPE,
        p_evento_id_out OUT analytics_evento.id%TYPE
    );

    -- Lógica de negócio: Calcula as métricas do dia com base nos eventos
    PROCEDURE PRC_CALCULAR_METRICAS_DIARIAS (
        p_usuario_id IN usuarios.id%TYPE,
        p_data       IN DATE
    );

    -- Requisito: Procedure para exportar JSON (para MongoDB) 
    PROCEDURE PRC_EXPORT_METRICAS_JSON (
        p_usuario_id IN usuarios.id%TYPE,
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    );
    
    -- Requisito: Procedure para exportar JSON (para MongoDB) 
    PROCEDURE PRC_EXPORT_RELATORIOS_JSON (
        p_usuario_id IN usuarios.id%TYPE
    );

    -- Procedimento de teste para inserir eventos com timestamp específico
    PROCEDURE PRC_INS_EVENTO_TESTE (
        p_usuario_id IN analytics_evento.usuario_id%TYPE,
        p_tarefa_id  IN analytics_evento.tarefa_id%TYPE DEFAULT NULL,
        p_reuniao_id IN analytics_evento.reuniao_id%TYPE DEFAULT NULL,
        p_tipo_evento IN analytics_evento.tipo_evento%TYPE,
        p_timestamp IN TIMESTAMP
    );
END PKG_ANALYTICS;
/

CREATE OR REPLACE PACKAGE BODY PKG_ANALYTICS AS
    -- Procedimento de teste que permite inserir com timestamp e IDs específicos
    PROCEDURE PRC_INS_EVENTO_TESTE (
        p_usuario_id IN analytics_evento.usuario_id%TYPE,
        p_tarefa_id  IN analytics_evento.tarefa_id%TYPE DEFAULT NULL,
        p_reuniao_id IN analytics_evento.reuniao_id%TYPE DEFAULT NULL,
        p_tipo_evento IN analytics_evento.tipo_evento%TYPE,
        p_timestamp IN TIMESTAMP
    ) IS
    BEGIN
        INSERT INTO analytics_evento (id, usuario_id, tarefa_id, reuniao_id, tipo_evento, timestamp)
        VALUES (SEQ_ANALYTICS_EVENTO.NEXTVAL, p_usuario_id, p_tarefa_id, p_reuniao_id, p_tipo_evento, p_timestamp);
    END PRC_INS_EVENTO_TESTE;

    PROCEDURE PRC_INS_EVENTO (
        p_usuario_id IN analytics_evento.usuario_id%TYPE,
        p_tarefa_id  IN analytics_evento.tarefa_id%TYPE DEFAULT NULL,
        p_reuniao_id IN analytics_evento.reuniao_id%TYPE DEFAULT NULL,
        p_tipo_evento IN analytics_evento.tipo_evento%TYPE,
        p_evento_id_out OUT analytics_evento.id%TYPE
    ) IS
    BEGIN
        INSERT INTO analytics_evento (id, usuario_id, tarefa_id, reuniao_id, tipo_evento, timestamp)
        VALUES (SEQ_ANALYTICS_EVENTO.NEXTVAL, p_usuario_id, p_tarefa_id, p_reuniao_id, p_tipo_evento, SYSTIMESTAMP)
        RETURNING id INTO p_evento_id_out;
        
        DBMS_OUTPUT.PUT_LINE('Evento: ' || p_tipo_evento || ' registrado para usuário ' || p_usuario_id);
    END PRC_INS_EVENTO;

    
    PROCEDURE PRC_CALCULAR_METRICAS_DIARIAS (
        p_usuario_id IN usuarios.id%TYPE,
        p_data       IN DATE
    ) IS
        v_min_foco NUMBER := 0;
        v_min_reuniao NUMBER := 0;
        v_tarefas_concluidas NUMBER := 0;
        v_start_time TIMESTAMP;
        v_end_time TIMESTAMP;
    BEGIN
        -- 1. Calcular Minutos de Foco
        v_start_time := NULL;
        FOR ev IN (
            SELECT tipo_evento, timestamp
            FROM analytics_evento
            WHERE usuario_id = p_usuario_id
              AND timestamp >= p_data AND timestamp < p_data + 1
              AND tipo_evento IN ('FOCO_INICIO', 'FOCO_FIM')
            ORDER BY timestamp
        ) LOOP
            -- Só inicia um novo bloco se não estivermos já em um
            IF ev.tipo_evento = 'FOCO_INICIO' AND v_start_time IS NULL THEN
                v_start_time := ev.timestamp;
            ELSIF ev.tipo_evento = 'FOCO_FIM' AND v_start_time IS NOT NULL THEN
                v_end_time := ev.timestamp;
                v_min_foco := v_min_foco + ROUND((CAST(v_end_time AS DATE) - CAST(v_start_time AS DATE)) * 24 * 60);
                v_start_time := NULL; -- Reseta para o próximo bloco
            END IF;
        END LOOP;
        
        -- 2. Calcular Minutos de Reunião (lógica similar)
        v_start_time := NULL;
        FOR ev IN (
            SELECT tipo_evento, timestamp
            FROM analytics_evento
            WHERE usuario_id = p_usuario_id
              AND timestamp >= p_data AND timestamp < p_data + 1 -- Captura o dia inteiro
              AND tipo_evento IN ('REUNIAO_INICIO', 'REUNIAO_FIM')
            ORDER BY timestamp
        ) LOOP
            -- Só inicia um novo bloco se não estivermos já em um
            IF ev.tipo_evento = 'REUNIAO_INICIO' AND v_start_time IS NULL THEN
                v_start_time := ev.timestamp;
            ELSIF ev.tipo_evento = 'REUNIAO_FIM' AND v_start_time IS NOT NULL THEN
                v_end_time := ev.timestamp;
                v_min_reuniao := v_min_reuniao + ROUND((CAST(v_end_time AS DATE) - CAST(v_start_time AS DATE)) * 24 * 60);
                v_start_time := NULL;
            END IF;
        END LOOP;
        
        -- 3. Calcular Tarefas Concluídas
        SELECT COUNT(*) INTO v_tarefas_concluidas
        FROM analytics_evento
        WHERE usuario_id = p_usuario_id
          AND timestamp >= p_data AND timestamp < p_data + 1 -- Captura o dia inteiro
          AND tipo_evento = 'TAREFA_CONCLUIDA';

        -- 4. Inserir ou Atualizar a Métrica
        MERGE INTO analytics_metrica m
        USING (SELECT p_usuario_id AS usuario_id, p_data AS data_metrica FROM DUAL) src
        ON (m.usuario_id = src.usuario_id AND m.data_metrica = src.data_metrica)
        WHEN MATCHED THEN
            UPDATE SET
                m.minutos_foco = v_min_foco,
                m.minutos_reuniao = v_min_reuniao,
                m.tarefas_concluidas_no_dia = v_tarefas_concluidas
                -- (Lógica do periodo_mais_produtivo seria mais complexa, omitida por brevidade)
        WHEN NOT MATCHED THEN
            INSERT (id, usuario_id, data_metrica, minutos_foco, minutos_reuniao, tarefas_concluidas_no_dia)
            VALUES (SEQ_ANALYTICS_METRICA.NEXTVAL, p_usuario_id, p_data, v_min_foco, v_min_reuniao, v_tarefas_concluidas);
            
        DBMS_OUTPUT.PUT_LINE('Métricas de ' || TO_CHAR(p_data, 'DD/MM/YYYY') || ' calculadas.');
        
        COMMIT; -- Adicionado para salvar as métricas calculadas e fechar a transação.
    END PRC_CALCULAR_METRICAS_DIARIAS;

    
    PROCEDURE PRC_EXPORT_METRICAS_JSON (
        p_usuario_id IN usuarios.id%TYPE,
        p_data_inicio IN DATE,
        p_data_fim IN DATE
    ) IS
        v_json_clob CLOB;
    BEGIN
        SELECT JSON_SERIALIZE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'idMetrica'        VALUE m.id,
                    'usuarioEmail'     VALUE u.email,
                    'data'             VALUE TO_CHAR(m.data_metrica, 'YYYY-MM-DD'),
                    'minutosFoco'      VALUE m.minutos_foco,
                    'minutosReuniao'   VALUE m.minutos_reuniao,
                    'tarefasConcluidas' VALUE m.tarefas_concluidas_no_dia,
                    'periodoProdutivo' VALUE m.periodo_mais_produtivo
                )
            ORDER BY m.data_metrica)
        PRETTY)
        INTO v_json_clob
        FROM analytics_metrica m
        JOIN usuarios u ON m.usuario_id = u.id
        WHERE m.usuario_id = p_usuario_id
          AND m.data_metrica BETWEEN p_data_inicio AND p_data_fim;

        DBMS_OUTPUT.PUT_LINE(v_json_clob);
    END PRC_EXPORT_METRICAS_JSON;

    
    PROCEDURE PRC_EXPORT_RELATORIOS_JSON (
        p_usuario_id IN usuarios.id%TYPE
    ) IS
        v_json_clob CLOB;
    BEGIN
        SELECT JSON_SERIALIZE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'idRelatorio'  VALUE r.id,
                    'usuario'      VALUE JSON_OBJECT('nome' VALUE u.nome, 'email' VALUE u.email),
                    'periodo'      VALUE JSON_OBJECT('inicio' VALUE r.data_inicio, 'fim' VALUE r.data_fim),
                    'metricasAgregadas' VALUE JSON_OBJECT(
                        'tarefasConcluidas'      VALUE r.tarefas_concluidas,
                        'minutosFocoTotal'       VALUE r.minutos_foco_total,
                        'riscoBurnout'           VALUE r.risco_burnout,
                        'tendenciaProdutividade' VALUE r.tendencia_produtividade
                    ),
                    'recomendacaoIA' VALUE r.recomendacaoIA,
                    'resumo'         VALUE r.resumo_geral
                )
            ORDER BY r.data_fim DESC)
        PRETTY)
        INTO v_json_clob
        FROM relatorios r
        JOIN usuarios u ON r.usuario_id = u.id
        WHERE r.usuario_id = p_usuario_id;

        DBMS_OUTPUT.PUT_LINE(v_json_clob);
    END PRC_EXPORT_RELATORIOS_JSON;

END PKG_ANALYTICS;
/