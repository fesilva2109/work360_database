CREATE OR REPLACE PACKAGE PKG_OPERATIONS AS
    -- Procedure para inserir uma nova tarefa
    PROCEDURE PRC_INS_TAREFA (
        p_usuario_id IN tarefas.usuario_id%TYPE,
        p_titulo     IN tarefas.titulo%TYPE,
        p_descricao  IN tarefas.descricao%TYPE,
        p_prioridade IN tarefas.prioridade%TYPE,
        p_estimativa IN tarefas.estimativa%TYPE
    );

    -- Procedure para inserir uma nova reunião
    PROCEDURE PRC_INS_REUNIAO (
        p_usuario_id  IN reunioes.usuario_id%TYPE,
        p_titulo      IN reunioes.titulo%TYPE,
        p_descricao   IN reunioes.descricao%TYPE,
        p_data_reuniao IN reunioes.data_reuniao%TYPE,
        p_link        IN reunioes.link%TYPE
    );
END PKG_OPERATIONS;
/

CREATE OR REPLACE PACKAGE BODY PKG_OPERATIONS AS
    PROCEDURE PRC_INS_TAREFA (
        p_usuario_id IN tarefas.usuario_id%TYPE,
        p_titulo     IN tarefas.titulo%TYPE,
        p_descricao  IN tarefas.descricao%TYPE,
        p_prioridade IN tarefas.prioridade%TYPE,
        p_estimativa IN tarefas.estimativa%TYPE
    ) IS
    BEGIN
        INSERT INTO tarefas (id, usuario_id, titulo, descricao, prioridade, estimativa, status)
        VALUES (SEQ_TAREFAS.NEXTVAL, p_usuario_id, p_titulo, p_descricao, p_prioridade, p_estimativa, 'pendente');
    END PRC_INS_TAREFA;

    PROCEDURE PRC_INS_REUNIAO (
        p_usuario_id  IN reunioes.usuario_id%TYPE,
        p_titulo      IN reunioes.titulo%TYPE,
        p_descricao   IN reunioes.descricao%TYPE,
        p_data_reuniao IN reunioes.data_reuniao%TYPE,
        p_link        IN reunioes.link%TYPE
    ) IS
    BEGIN
        INSERT INTO reunioes (id, usuario_id, titulo, descricao, data_reuniao, link)
        VALUES (SEQ_REUNIOES.NEXTVAL, p_usuario_id, p_titulo, p_descricao, p_data_reuniao, p_link);
    END PRC_INS_REUNIAO;
END PKG_OPERATIONS;
/