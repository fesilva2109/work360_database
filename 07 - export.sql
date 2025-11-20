-- A. Exportar Métricas
-- A. Calcular Métricas do Dia e DEPOIS Exportar
-- Este passo é crucial para garantir que os dados de hoje existam antes da exportação.
BEGIN
    PKG_ANALYTICS.PRC_CALCULAR_METRICAS_DIARIAS(p_usuario_id => 1, p_data => TRUNC(SYSDATE));
END;
/

BEGIN
    PKG_ANALYTICS.PRC_EXPORT_METRICAS_JSON(1, TRUNC(SYSDATE, 'MM'), SYSDATE);
END;
/
-- Saída JSON (Copiar este resultado para o arquivo metricas.json):
-- [
--   {"idMetrica": 4, "usuarioEmail": "ana.silva@work360.com", "data": "2025-11-11", "minutosFoco": 150, "minutosReuniao": 30, "tarefasConcluidas": 2, "periodoProdutivo": null}
-- ]


-- B. Exportar Relatórios
BEGIN
    PKG_ANALYTICS.PRC_EXPORT_RELATORIOS_JSON(1);
END;
/
-- Saída JSON (Copiar este resultado para o arquivo relatorios.json):
-- [
--   {"idRelatorio": 1, "usuario": {"nome": "Ana Silva", "email": "ana.silva@work360.com"}, "periodo": {"inicio": "2025-11-01", "fim": "2025-11-11"}, "metricasAgregadas": {"tarefasConcluidas": 25, "minutosFocoTotal": null, "riscoBurnout": 0.65, "tendenciaProdutividade": "alta"}, "recomendacaoIA": "Recomendamos blocos de foco \"deep work\" nas terças.", "resumo": "Produtividade alta, risco de burnout moderado."}
-- ]