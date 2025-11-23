CREATE OR REPLACE PACKAGE PKG_USUARIOS AS
    -- Requisito: Procedure de Inserção 
    PROCEDURE PRC_INS_USUARIO (
        p_nome   IN usuarios.nome%TYPE,
        p_email  IN usuarios.email%TYPE,
        p_senha  IN usuarios.senha%TYPE
    );

    -- Requisito: Função 2 (Validação com REGEXP + Exceções) 
    FUNCTION FN_VALIDAR_FORMATO_EMAIL (
        p_email IN usuarios.email%TYPE
    ) RETURN BOOLEAN;

    -- Requisito: Função 1 (Conversão Manual JSON) 
    FUNCTION FN_GET_USUARIO_JSON (
        p_usuario_id IN usuarios.id%TYPE
    ) RETURN CLOB;
END PKG_USUARIOS;
/

CREATE OR REPLACE PACKAGE BODY PKG_USUARIOS AS
    PROCEDURE PRC_INS_USUARIO (
        p_nome   IN usuarios.nome%TYPE,
        p_email  IN usuarios.email%TYPE,
        p_senha  IN usuarios.senha%TYPE
    ) IS
        e_formato_invalido EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_formato_invalido, -20001);
    BEGIN
        -- A função de validação irá disparar uma exceção se o e-mail for inválido.
        -- Se a função for concluída, o e-mail é válido e podemos inserir.
        IF FN_VALIDAR_FORMATO_EMAIL(p_email) THEN
           INSERT INTO usuarios (id, nome, email, senha)
           VALUES (SEQ_USUARIOS.NEXTVAL, p_nome, p_email, p_senha);
           DBMS_OUTPUT.PUT_LINE('Usuário ' || p_nome || ' inserido.');
        END IF; 
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erro: Email ' || p_email || ' já existe.');
        WHEN e_formato_invalido THEN
            DBMS_OUTPUT.PUT_LINE(SQLERRM); 
            RAISE; 
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro inesperado ao inserir usuário: ' || SQLERRM);
            RAISE; 
    END PRC_INS_USUARIO;


    FUNCTION FN_VALIDAR_FORMATO_EMAIL (
        p_email IN usuarios.email%TYPE
    ) RETURN BOOLEAN IS
        e_formato_invalido EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_formato_invalido, -20001);
    BEGIN
        -- Requisito: Expressão Regular (REGEXP) 
        -- Valida um formato de email padrão
        IF NOT REGEXP_LIKE(p_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$') THEN
            -- Requisito: Tratamento de Exceções 
            RAISE_APPLICATION_ERROR(-20001, 'Formato de e-mail inválido: ' || p_email);
        END IF;
        RETURN TRUE;
    EXCEPTION
        WHEN e_formato_invalido THEN
            RAISE; -- Repassa a exceção customizada
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro inesperado na validação de email: ' || SQLERRM);
            RETURN FALSE;
    END FN_VALIDAR_FORMATO_EMAIL;


    FUNCTION FN_GET_USUARIO_JSON (
        p_usuario_id IN usuarios.id%TYPE
    ) RETURN CLOB IS
        v_json CLOB;
        v_rec usuarios%ROWTYPE;
    BEGIN
        SELECT * INTO v_rec
        FROM usuarios
        WHERE id = p_usuario_id;

        -- Requisito: Proibido TO_JSON, JSON_OBJECT, etc. 
        -- Construção manual via concatenação
        v_json := '{' ||
                  '"id": ' || v_rec.id || ',' ||
                  '"nome": "' || v_rec.nome || '",' ||
                  '"email": "' || v_rec.email || '",' ||
                  '"contextoApp": "Work360 - Futuro do Trabalho"' || -- Contexto 
                  '}';
        RETURN v_json;
    EXCEPTION
        -- Requisito: 3 Exceções distintas 
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Log: Usuário ' || p_usuario_id || ' não encontrado.');
            RETURN '{"erro": "USUARIO_NAO_ENCONTRADO", "id": ' || p_usuario_id || '}';
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Log: Erro crítico, ID duplicado: ' || p_usuario_id);
            RETURN '{"erro": "DADOS_INCONSISTENTES"}';
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Log: Erro genérico: ' || SQLERRM);
            RETURN '{"erro": "ERRO_INTERNO_PLSQL"}';
    END FN_GET_USUARIO_JSON;

END PKG_USUARIOS;
/