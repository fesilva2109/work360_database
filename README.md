# 📊 Work360: Solução de Banco de Dados

Bem-vindo à documentação da arquitetura de banco de dados do projeto Work360. Esta seção detalha a estratégia de persistência de dados que suporta a API backend, garantindo performance, escalabilidade e a capacidade de gerar insights complexos através de uma abordagem híbrida.

## 📜 Visão Geral

A aplicação Work360 utiliza uma **arquitetura de banco de dados híbrida**, combinando o melhor dos mundos relacional (SQL) e não relacional (NoSQL). Essa abordagem nos permite usar a ferramenta certa para cada tipo de dado e carga de trabalho, otimizando desde as operações transacionais do dia a dia até a análise de grandes volumes de dados e o armazenamento de documentos flexíveis.

A solução é composta por três tecnologias principais:

1.  **Azure SQL Server**: Banco de dados relacional principal para operações transacionais.
2.  **Oracle Database**: Banco de dados secundário focado em analytics e relatórios.
3.  **MongoDB**: Banco de dados NoSQL para armazenar os relatórios gerados por Inteligência Artificial.

---

## 🏗️ Arquitetura e Componentes

A seguir, detalhamos o papel de cada banco de dados no ecossistema Work360.

### 1. Azure SQL Server (Banco de Dados Relacional Principal)

O Azure SQL Server é a espinha dorsal transacional da aplicação. Ele é responsável por armazenar os dados estruturados e essenciais para o funcionamento diário do Work360.

*   **Propósito**: Servir como o banco de dados primário para operações **CRUD (Create, Read, Update, Delete)**, garantindo consistência, integridade e confiabilidade dos dados (ACID).
*   **Dados Gerenciados**:
    *   `Usuarios`: Informações de perfil, credenciais e configurações.
    *   `Tarefas`: Detalhes das tarefas, incluindo status, prioridade e prazos.
    *   `Reunioes`: Agendamentos, participantes e detalhes das reuniões.
*   **Justificativa**: A natureza relacional do SQL Server é ideal para dados com esquema bem definido e relacionamentos claros. O Azure oferece escalabilidade, segurança e gerenciamento simplificado na nuvem.

### 2. Oracle Database (Banco de Dados Analítico)

O Oracle Database atua como nosso data warehouse secundário, otimizado para processamento analítico e geração de relatórios complexos que demandam alta performance.

*   **Propósito**: Armazenar e processar grandes volumes de dados de eventos para **análise de performance e produtividade**.
*   **Dados Gerenciados**:
    *   `Eventos de Foco`: Registros de início e fim das sessões de foco (`FOCO_INICIO`, `FOCO_FIM`).
    *   `Metricas Agregadas`: Dados pré-processados sobre a atividade do usuário para alimentar os relatórios.
*   **Justificativa**: A robustez e as capacidades analíticas avançadas do Oracle o tornam a escolha ideal para consultas complexas e agregações de dados que seriam custosas para o banco de dados transacional principal.

### 3. MongoDB (Banco de Dados NoSQL Documental)

O MongoDB é utilizado para armazenar os resultados do processamento de Inteligência Artificial. Sua natureza flexível e baseada em documentos é perfeita para os dados semi-estruturados gerados pela IA.

*   **Propósito**: Persistir os **relatórios de produtividade** gerados pela integração com a OpenAI.
*   **Dados Gerenciados**:
    *   `Relatorios`: Documentos JSON contendo a análise completa da produtividade do usuário, incluindo métricas, tendências, resumos e recomendações personalizadas.
*   **Justificativa**: O esquema flexível do MongoDB permite armazenar relatórios complexos e aninhados (como o `relatorios.json`) em um único documento, simplificando o armazenamento e a recuperação desses dados. A estrutura do JSON gerado pela IA pode evoluir sem a necessidade de migrações de esquema rígidas.

#### Exemplo de Documento de Relatório (`relatorios.json`):

```json
[
  {
    "idRelatorio": 1,
    "usuario": {
      "nome": "Felipe Silva Maciel",
      "email": "felipe.silva@work360.com"
    },
    "periodo": {
      "inicio": "2025-11-01T00:00:00",
      "fim": "2025-11-23T04:57:35"
    },
    "metricasAgregadas": {
      "tarefasConcluidas": 25,
      "minutosFocoTotal": null,
      "riscoBurnout": 0.65,
      "tendenciaProdutividade": "alta"
    },
    "recomendacaoIA": "Recomendamos blocos de foco \"deep work\" nas terças.",
    "resumo": "Produtividade alta, risco de burnout moderado."
  }
]
```

---

## 🔄 Fluxo de Dados

1.  **Operações Diárias**: O usuário interage com o aplicativo móvel. A API Java processa requisições CRUD (criar tarefa, agendar reunião) que são persistidas no **Azure SQL Server**.
2.  **Coleta de Analytics**: Quando o usuário inicia ou termina uma sessão de foco, um evento é enviado para a API e registrado no **Oracle Database** para análise posterior.
3.  **Geração de Relatório**:
    *   O usuário solicita um relatório de produtividade.
    *   A API consulta os dados transacionais no **Azure SQL Server** (ex: tarefas concluídas) e os dados de eventos no **Oracle Database** (ex: tempo de foco).
    *   Esses dados agregados são enviados para a API da OpenAI.
    *   A IA retorna uma análise completa com insights, resumo e recomendações.
    *   Este resultado é formatado como um documento JSON e salvo na coleção `relatorios` no **MongoDB**.
    *   O relatório é retornado ao usuário.

## 🛠️ Tecnologias e Ferramentas

*   **Linguagem de Acesso**: Java 17
*   **Framework de Acesso a Dados**: Spring Data JPA, Hibernate
*   **Bancos de Dados**:
    *   Microsoft Azure SQL Server
    *   Oracle Database
    *   MongoDB

---

👨‍💻 **Integrantes**
*   Eduardo Henrique Strapazzon Nagado - RM558158
*   Felipe Silva Maciel - RM555307
*   Gustavo Ramires Lazzuri - RM556772