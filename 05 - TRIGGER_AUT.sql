-- Requisito: Triggers de auditoria 
CREATE OR REPLACE TRIGGER TRG_TAREFAS_AUD
BEFORE INSERT OR UPDATE OR DELETE ON tarefas
FOR EACH ROW
DECLARE
    v_dados_antigos CLOB;
    v_dados_novos   CLOB;
BEGIN
    -- Construção manual de JSON para os logs
    IF UPDATING OR DELETING THEN
        v_dados_antigos := '{"titulo": "' || :OLD.titulo || '", "status": "' || :OLD.status || '", "prioridade": "' || :OLD.prioridade || '"}';
    END IF;
    IF INSERTING OR UPDATING THEN
        v_dados_novos := '{"titulo": "' || :NEW.titulo || '", "status": "' || :NEW.status || '", "prioridade": "' || :NEW.prioridade || '"}';
    END IF;

    -- Inserção na tabela de log
    IF INSERTING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'TAREFAS', :NEW.id, 'INSERT', USER, v_dados_novos);
    ELSIF UPDATING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos, dados_novos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'TAREFAS', :NEW.id, 'UPDATE', USER, v_dados_antigos, v_dados_novos);
    ELSIF DELETING THEN
        INSERT INTO auditoria_log (id_log, tabela_afetada, id_registro_afetado, operacao, usuario_db, dados_antigos)
        VALUES (SEQ_AUDITORIA_LOG.NEXTVAL, 'TAREFAS', :OLD.id, 'DELETE', USER, v_dados_antigos);
    END IF;
END;
/