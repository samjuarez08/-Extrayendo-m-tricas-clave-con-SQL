-- =====================================================
-- Pre-entrega M4: Consultas SQL de negocio
-- Base: Ventas_Tech_DB (TechStore / RetailPro)
-- Motor: SQL Server (T-SQL)
-- =====================================================

USE Ventas_Tech_DB;
GO

-- -----------------------------------------------------
-- Consulta 1 — Resumen ejecutivo mensual
-- -----------------------------------------------------
SELECT
    MONTH(fecha_venta)                                              AS mes,
    SUM(cantidad * precio_unitario)                                 AS total_facturado,
    COUNT(*)                                                        AS cantidad_pedidos,
    AVG(CAST(cantidad * precio_unitario AS DECIMAL(12,2)))          AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes;

-- -----------------------------------------------------
-- Consulta 2 — Ranking de productos (Top 5 por facturación)
-- -----------------------------------------------------
SELECT TOP 5
    id_producto,
    SUM(cantidad)                       AS unidades_vendidas,
    SUM(cantidad * precio_unitario)     AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

-- -----------------------------------------------------
-- Consulta 3 — Clientes recurrentes (más de un pedido)
-- -----------------------------------------------------
SELECT
    id_cliente,
    COUNT(*)                            AS cantidad_pedidos,
    SUM(cantidad * precio_unitario)     AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

-- -----------------------------------------------------
-- Consulta 4 — Meses por encima / por debajo del promedio
-- -----------------------------------------------------
WITH facturacion_mensual AS (
    SELECT
        MONTH(fecha_venta)              AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY MONTH(fecha_venta)
)
SELECT
    mes,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_mensual)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS posicion_vs_promedio
FROM facturacion_mensual
ORDER BY mes;

-- =====================================================
-- HALLAZGOS
-- =====================================================
-- 1) El mes de [MES] fue el de mayor facturación con $[MONTO], un [X]% más que el promedio mensual.
-- 2) El producto [ID] concentra el [X]% de la facturación total, con [N] unidades vendidas.
-- 3) Solo [N] de [TOTAL] clientes son recurrentes y explican el [X]% de lo facturado.