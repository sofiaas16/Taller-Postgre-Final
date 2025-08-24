-- Obtén el “Top 10” de productos por unidades vendidas y su ingreso total, usando `JOIN ... USING`, agregación con `SUM()`, agrupación con `GROUP BY`, ordenamiento descendente con `ORDER BY` y paginado con `LIMIT`.

SELECT p.nombre,
       SUM(cp.cantidad) AS unidades_vendidas,
       SUM(cp.total)    AS ingreso_total
FROM miscompras.compras_productos cp
JOIN miscompras.productos p USING (id_producto)
GROUP BY p.nombre
ORDER BY unidades_vendidas DESC, ingreso_total DESC
LIMIT 10;


-- Calcula el total pagado promedio por compra y la mediana aproximada usando una subconsulta agregada y la función de ventana ordenada `PERCENTILE_CONT(...) WITHIN GROUP`, además de `AVG()` y `ROUND()` para formateo.
SELECT 
    ROUND(AVG(total_compra)::numeric, 2) AS promedio,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_compra)::numeric, 2) AS mediana
FROM (
    SELECT SUM(cp.total) AS total_compra
    FROM miscompras.compras_productos cp
    GROUP BY cp.id_compra
) sub;

-- Lista compras por cliente con gasto total y un ranking global de gasto empleando funciones de ventana (`RANK() OVER (ORDER BY SUM(...) DESC)`), concatenación de texto y `COUNT(DISTINCT ...)`.

SELECT c.id,
       c.nombre || ' ' || c.apellidos AS cliente,
       COUNT(DISTINCT co.id_compra)   AS num_compras,
       SUM(cp.total)                  AS gasto_total,
       RANK() OVER (ORDER BY SUM(cp.total) DESC) AS ranking
FROM miscompras.clientes c
JOIN miscompras.compras co ON co.id_cliente = c.id
JOIN miscompras.compras_productos cp USING (id_compra)
GROUP BY c.id, c.nombre, c.apellidos
ORDER BY gasto_total DESC;

