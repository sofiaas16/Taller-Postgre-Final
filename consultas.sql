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

-- Calcula por día el número de compras, ticket promedio y total, usando un `CTE (WITH) o (Common Table Expression)“subconsulta con nombre”`, conversión de `fecha ::date`, y agregaciones (`COUNT, AVG, SUM`) con `ORDER BY`.

WITH compras_dia AS (
  SELECT co.fecha::date AS dia,
         COUNT(co.id_compra) AS num_compras,
         SUM(cp.total)       AS total_dia,
         ROUND(AVG(cp.total),2) AS ticket_promedio
  FROM miscompras.compras co
  JOIN miscompras.compras_productos cp USING (id_compra)
  GROUP BY co.fecha::date
)
SELECT *
FROM compras_dia
ORDER BY dia;

-- Realiza una búsqueda estilo e-commerce de productos activos y con stock cuyo nombre empiece por “caf”, usando filtros en `WHERE`, comparación numérica y búsqueda case-insensitive con `ILIKE 'caf%'`.

SELECT id_producto, nombre, precio_venta, cantidad_stock
FROM miscompras.productos
WHERE estado = 1
  AND cantidad_stock > 0
  AND nombre ILIKE 'caf%';

-- Devuelve los productos con el precio formateado como texto monetario usando concatenación `('||')` y `TO_CHAR(numeric, 'FM999G999G999D00')`, ordenando de mayor a menor precio.

SELECT nombre,
       '$' || TO_CHAR(precio_venta, 'FM999G999G999D00') AS precio_formateado
FROM miscompras.productos
ORDER BY precio_venta DESC;

-- Arma el “resumen de canasta” por compra: subtotal, `IVA al 19%` y total con IVA, mediante `SUM()` y `ROUND()` sobre el total por ítem, agrupado por compra.
SELECT id_compra,
       ROUND(SUM(total),2) AS subtotal,
       ROUND(SUM(total)*0.19,2) AS iva,
       ROUND(SUM(total)*1.19,2) AS total_con_iva
FROM miscompras.compras_productos
GROUP BY id_compra
ORDER BY id_compra;

-- Calcula la participación (%) de cada categoría en las ventas usando agregaciones por categoría y una ventana sobre el total (`SUM(SUM(total)) OVER ()`), más `ROUND()` para el porcentaje.

SELECT cat.descripcion AS categoria,
       ROUND(SUM(cp.total),2) AS ventas_categoria,
       ROUND(100.0 * SUM(cp.total) / SUM(SUM(cp.total)) OVER (),2) AS participacion_pct
FROM miscompras.compras_productos cp
JOIN miscompras.productos p USING (id_producto)
JOIN miscompras.categorias cat USING (id_categoria)
GROUP BY cat.descripcion
ORDER BY ventas_categoria DESC;


-- Clasifica el nivel de stock de productos activos (`CRÍTICO/BAJO/OK`) usando `CASE` sobre el campo `cantidad_stock` y ordena por el stock ascendente.
SELECT nombre,
       cantidad_stock,
       CASE
         WHEN cantidad_stock < 50  THEN 'CRÍTICO'
         WHEN cantidad_stock < 200 THEN 'BAJO'
         ELSE 'esta OK'
       END AS nivel_stock
FROM miscompras.productos
WHERE estado = 1
ORDER BY cantidad_stock ASC;

-- Obtén la última compra por cliente utilizando`DISTINCT ON (id_cliente)` combinado con `ORDER BY ... fecha DESC` y una agregación del total de la compra.
SELECT DISTINCT ON (c.id) 
       c.id,
       c.nombre || ' ' || c.apellidos AS cliente,
       co.fecha,
       SUM(cp.total) AS total_compra
FROM miscompras.clientes c
JOIN miscompras.compras co ON co.id_cliente = c.id
JOIN miscompras.compras_productos cp USING (id_compra)
GROUP BY c.id, c.nombre, c.apellidos, co.id_compra, co.fecha
ORDER BY c.id, co.fecha DESC;

-- Devuelve los 2 productos más vendidos por categoría usando una subconsulta con `ROW_NUMBER() OVER (PARTITION BY ... ORDER BY SUM(...) DESC)` y luego filtrando `ROW_NUMBER` <= 2.
SELECT categoria, nombre, unidades_vendidas
FROM (
    SELECT cat.descripcion AS categoria,
           p.nombre, SUM(cp.cantidad) AS unidades_vendidas, ROW_NUMBER() OVER (PARTITION BY cat.descripcion ORDER BY SUM(cp.cantidad) DESC) AS rn
    FROM miscompras.compras_productos cp
    JOIN miscompras.productos p USING (id_producto)
    JOIN miscompras.categorias cat USING (id_categoria)
    GROUP BY cat.descripcion, p.nombre
) sub
WHERE rn <= 2
ORDER BY categoria, unidades_vendidas DESC;

-- Calcula ventas mensuales: agrupa por mes truncando la fecha con `DATE_TRUNC('month', fecha)`, cuenta compras distintas (`COUNT(DISTINCT ...)`) y suma ventas, ordenando cronológicamente.
SELECT DATE_TRUNC('month', co.fecha) AS mes, COUNT(DISTINCT co.id_compra) AS num_compras, ROUND(SUM(cp.total),2) AS total_ventas
FROM miscompras.compras co
JOIN miscompras.compras_productos cp USING (id_compra)
GROUP BY DATE_TRUNC('month', co.fecha)
ORDER BY mes;

-- Lista productos que nunca se han vendido mediante un anti-join con `NOT EXISTS`, comparando por id_producto.
SELECT p.id_producto, p.nombre
FROM miscompras.productos p
WHERE NOT EXISTS(
   SELECT 1
   FROM miscompras.compras_productos cp
   WHERE cp.id_producto = p.id_producto 
);

-- Identifica clientes que, al comprar “café”, también compran “pan” en la misma compra, usando un filtro con `ILIKE` y una subconsulta correlacionada con `EXISTS`.
SELECT DISTINCT c.id, c.nombre, c.apellidos AS cliente
FROM miscompras.clientes c
JOIN miscompras.compras co ON co.id_cliente = c.id
WHERE EXISTS (
    SELECT 1
    FROM miscompras.compras_productos cp
    JOIN miscompras.productos p USING (id_producto)
    WHERE cp.id_compra = co.id_compra
      AND p.nombre ILIKE 'café%'
)
AND EXISTS (
    SELECT 1
    FROM miscompras.compras_productos cp
    JOIN miscompras.productos p USING (id_producto)
    WHERE cp.id_compra = co.id_compra
      AND p.nombre ILIKE 'pan%'
);


-- Estima el margen porcentual “simulado” de un producto aplicando operadores aritméticos sobre precio_venta y formateo con `ROUND()` a un decimal.
SELECT nombre, precio_venta, ROUND(((precio_venta-(precio_venta * 10))/precio_venta)*100) AS margen
FROM miscompras.productos;

-- Filtra clientes de un dominio dado usando expresiones regulares con el operador `~*` (case-insensitive) y limpieza con `TRIM()` sobre el correo electrónico.
