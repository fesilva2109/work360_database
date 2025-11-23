-- Trigger de auditoria para a tabela REUNIOES
CREATE OR REPLACE TRIGGER TRG_REUNIOES_AUD
BEFORE INSERT OR UPDATE OR DELETE ON reunioes
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON para os logs
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"titulo": "' || :OLD.titulo || '", "data_reuniao": "' || TO_CHAR(:OLD.data_reuniao, 'YYYY-MM-DD HH24:MI:SS') || '"}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"titulo": "' || :NEW.titulo || '", "data_reuniao": "' || TO_CHAR(:NEW.data_reuniao, 'YYYY-MM-DD HH24:MI:SS') || '"}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'REUNIOES', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'REUNIOES', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'REUNIOES', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/

-- Trigger de auditoria para a tabela USUARIOS
CREATE OR REPLACE TRIGGER TRG_USUARIOS_AUD
BEFORE INSERT OR UPDATE OR DELETE ON usuarios
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON (sem logar a senha por segurança)
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"nome": "' || :OLD.nome || '", "email": "' || :OLD.email || '"}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"nome": "' || :NEW.nome || '", "email": "' || :NEW.email || '"}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'USUARIOS', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'USUARIOS', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'USUARIOS', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/

-- Trigger de auditoria para a tabela RELATORIOS
CREATE OR REPLACE TRIGGER TRG_RELATORIOS_AUD
BEFORE INSERT OR UPDATE OR DELETE ON relatorios
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"risco_burnout": "' || :OLD.risco_burnout || '", "tendencia_produtividade": "' || :OLD.tendencia_produtividade || '"}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"risco_burnout": "' || :NEW.risco_burnout || '", "tendencia_produtividade": "' || :NEW.tendencia_produtividade || '"}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'RELATORIOS', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'RELATORIOS', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'RELATORIOS', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/

-- Trigger de auditoria para a tabela ANALYTICS_EVENTO
CREATE OR REPLACE TRIGGER TRG_ANALYTICS_EVENTO_AUD
BEFORE INSERT OR UPDATE OR DELETE ON analytics_evento
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"tipo_evento": "' || :OLD.tipo_evento || '"}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"tipo_evento": "' || :NEW.tipo_evento || '"}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_EVENTO', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_EVENTO', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_EVENTO', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/

-- Nota: A tabela analytics_metrica é atualizada via MERGE, que dispara triggers de INSERT ou UPDATE.
-- Não há necessidade de um trigger específico para MERGE.
-- O trigger abaixo cobrirá as operações resultantes do MERGE.
CREATE OR REPLACE TRIGGER TRG_ANALYTICS_METRICA_AUD
BEFORE INSERT OR UPDATE OR DELETE ON analytics_metrica
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"minutos_foco": ' || :OLD.minutos_foco || ', "tarefas_concluidas": ' || :OLD.tarefas_concluidas_no_dia || '}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"minutos_foco": ' || :NEW.minutos_foco || ', "tarefas_concluidas": ' || :NEW.tarefas_concluidas_no_dia || '}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_METRICA', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_METRICA', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'ANALYTICS_METRICA', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/
