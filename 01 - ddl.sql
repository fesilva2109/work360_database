-- Bloco para dropar objetos existentes e ignorar erros se não existirem
BEGIN
   -- A ordem de drop é importante. Usar CASCADE CONSTRAINTS para simplificar.
   EXECUTE IMMEDIATE 'DROP TABLE auditoria_log CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE analytics_metrica CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE analytics_evento CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE relatorios CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE tarefas CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE reunioes CASCADE CONSTRAINTS';
   EXECUTE IMMEDIATE 'DROP TABLE usuarios CASCADE CONSTRAINTS';
   
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_USUARIOS';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TAREFAS';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_REUNIOES';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ANALYTICS_EVENTO';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_ANALYTICS_METRICA';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_RELATORIOS';
   EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_AUDITORIA_LOG';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- 1. Sequences para simular o IDENTITY (PKs)
CREATE SEQUENCE SEQ_USUARIOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_TAREFAS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_REUNIOES START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ANALYTICS_EVENTO START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_ANALYTICS_METRICA START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_RELATORIOS START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_AUDITORIA_LOG START WITH 1 INCREMENT BY 1;

-- 2. Tabela de Usuários
CREATE TABLE usuarios (
    id NUMBER PRIMARY KEY,
    nome VARCHAR2(255 CHAR) NOT NULL,
    email VARCHAR2(255 CHAR) UNIQUE NOT NULL,
    senha VARCHAR2(255 CHAR) NOT NULL
);

-- 3. Tabela de Tarefas
CREATE TABLE tarefas (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL,
    titulo VARCHAR2(255 CHAR) NOT NULL,
    descricao CLOB,
    prioridade VARCHAR2(50 CHAR),
    estimativa NUMBER, -- Usando NUMBER para 'FLOAT' do SQL Server
    status VARCHAR2(50 CHAR) DEFAULT 'pendente',
    CONSTRAINT fk_tarefas_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- 4. Tabela de Reuniões
CREATE TABLE reunioes (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL,
    titulo VARCHAR2(255 CHAR) NOT NULL,
    descricao CLOB,
    data_reuniao TIMESTAMP NOT NULL, -- Renomeado de 'data' para 'data_reuniao' (evitar palavra reservada)
    link VARCHAR2(255 CHAR),
    CONSTRAINT fk_reunioes_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- 5. Tabela de Eventos (A tabela que faltava)
CREATE TABLE analytics_evento (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL,
    tarefa_id NUMBER NULL,
    reuniao_id NUMBER NULL,
    tipo_evento VARCHAR2(100 CHAR) NOT NULL, -- ex: 'FOCO_INICIO', 'TAREFA_CONCLUIDA'
    timestamp TIMESTAMP NOT NULL,
    CONSTRAINT fk_evento_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_evento_tarefa FOREIGN KEY (tarefa_id) REFERENCES tarefas(id),
    CONSTRAINT fk_evento_reuniao FOREIGN KEY (reuniao_id) REFERENCES reunioes(id)
);

-- 6. Tabela de Métricas (Sumarização dos eventos)
CREATE TABLE analytics_metrica (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL,
    data_metrica DATE NOT NULL, -- Renomeado de 'data'
    minutos_foco NUMBER DEFAULT 0,
    minutos_reuniao NUMBER DEFAULT 0,
    tarefas_concluidas_no_dia NUMBER DEFAULT 0,
    periodo_mais_produtivo VARCHAR2(100 CHAR),
    CONSTRAINT fk_metrica_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT uk_usuario_data_metrica UNIQUE (usuario_id, data_metrica) -- Garante 1 métrica/dia/usuário
);

-- 7. Tabela de Relatórios (Insights da IA)
CREATE TABLE relatorios (
    id NUMBER PRIMARY KEY,
    usuario_id NUMBER NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    tarefas_concluidas NUMBER,
    tarefas_pendentes NUMBER,
    reunioes_realizadas NUMBER,
    minutos_foco_total NUMBER,
    percentual_conclusao NUMBER(5, 2), -- Ajustado de FLOAT para precisão
    risco_burnout NUMBER(3, 2), -- Ajustado de FLOAT para precisão (0.00 a 1.00)
    tendencia_produtividade VARCHAR2(100 CHAR),
    tendencia_foco VARCHAR2(100 CHAR),
    insights CLOB,
    recomendacaoIA CLOB,
    resumo_geral VARCHAR2(255 CHAR),
    criado_em TIMESTAMP DEFAULT SYSTIMESTAMP,
    relatorio_anterior_id NUMBER NULL,
    CONSTRAINT fk_relatorio_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id),
    CONSTRAINT fk_relatorio_anterior FOREIGN KEY (relatorio_anterior_id) REFERENCES relatorios(id)
);

-- 8. Tabela de Auditoria (Requisito da GS) 
CREATE TABLE auditoria_log (
    id_log NUMBER PRIMARY KEY,
    tabela_afetada VARCHAR2(100) NOT NULL,
    id_registro_afetado NUMBER NOT NULL,
    operacao VARCHAR2(10) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    usuario_db VARCHAR2(50),
    data_ocorrencia TIMESTAMP DEFAULT SYSTIMESTAMP,
    dados_antigos CLOB,
    dados_novos CLOB
);