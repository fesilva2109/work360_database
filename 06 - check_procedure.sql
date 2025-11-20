-- Calcular as métricas de HOJE (TRUNC(SYSDATE)) para a Ana (Usuário 1)
BEGIN
    PKG_ANALYTICS.PRC_CALCULAR_METRICAS_DIARIAS(p_usuario_id => 1, p_data => TRUNC(SYSDATE));
END;
/

-- Verificar o resultado
SELECT * FROM analytics_metrica WHERE usuario_id = 1;
