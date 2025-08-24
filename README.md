# PostgreSQL con Docker

## Creación del Contenedor 🙏🏻

```bash
docker run -d --name postgres_container -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=admin -e POSTGRES_DB=campus -p 5433:5432 -v pgdata:/var/lib/postgresql/data --restart=unless-stopped postgres:15
```

## Conectar al Contenedor de Docker
```bash
docker exec -it postgres_container bash
```

## Conectar con PostgreSQL bajo Consola
```bash
psql --host=localhost --username=admin -d campus --password


psql -h localhost -U admin -d campus -W
```
### Para usuario por defecto
```bash
psql ... --username=postgres ...
```

## Comandos PSQL
- `\l` : Lista las bases de datos
- `\c {db_name}` : Cambiar a una base de datos existente
- `\d` : Describe las tablas de la base de datos actual
- `\d {table_name}` : Describe de la tabla
- `\dt` : Listado de las tablas de la base de datos actual
- `\ds` : Secuencias, que se crean con el tipo de datos `serial`
- `\di` : Listar los indices
- `\dp \z`: Listado de privilegios de las tablas
- `\dn` : Listar los schema de la base de datos
- `\dv` : Listar las vistas del schema de la base de datos

## Tipos de datos
### Tipos de Datos Numéricos

| Name               | Storage Size | Description                     | Range                                                        |
| ------------------ | ------------ | ------------------------------- | ------------------------------------------------------------ |
| `smallint`         | 2 bytes      | small-range integer             | -32768 to +32767                                             |
| `integer`          | 4 bytes      | typical choice for integer      | -2147483648 to +2147483647                                   |
| `bigint`           | 8 bytes      | large-range integer             | -9223372036854775808 to +9223372036854775807                 |
| `decimal`          | variable     | user-specified precision, exact | up to 131072 digits before the decimal point; up to 16383 digits after the decimal point |
| `numeric`          | variable     | user-specified precision, exact | up to 131072 digits before the decimal point; up to 16383 digits after the decimal point |
| `real`             | 4 bytes      | variable-precision, inexact     | 6 decimal digits precision                                   |
| `double precision` | 8 bytes      | variable-precision, inexact     | 15 decimal digits precision                                  |
| `smallserial`      | 2 bytes      | small autoincrementing integer  | 1 to 32767                                                   |
| `serial`           | 4 bytes      | autoincrementing integer        | 1 to 2147483647                                              |
| `bigserial`        | 8 bytes      | large autoincrementing integer  | 1 to 9223372036854775807                                     |

### Tipos de Datos de Caracteres

| Name                                               | Description                              |
| -------------------------------------------------- | ---------------------------------------- |
| `character varying(*`n`*)`, `varchar(*`n`*)`       | variable-length with limit               |
| `character(*`n`*)`, `char(*`n`*)`, `bpchar(*`n`*)` | fixed-length, blank-padded               |
| `bpchar`                                           | variable unlimited length, blank-trimmed |
| `text`                                             | variable unlimited length                |

### Tipos de Datos Booleanos

| Name      | Storage Size | Description            |
| --------- | ------------ | ---------------------- |
| `boolean` | 1 byte       | state of true or false |

### [Tipos de Datos de Fecha y Hora](https://www.postgresql.org/docs/current/datatype-datetime.html)

| Name                                          | Storage Size | Description                           | Low Value        | High Value      | Resolution    |
| --------------------------------------------- | ------------ | ------------------------------------- | ---------------- | --------------- | ------------- |
| `timestamp [ (*`p`*) ] [ without time zone ]` | 8 bytes      | both date and time (no time zone)     | 4713 BC          | 294276 AD       | 1 microsecond |
| `timestamp [ (*`p`*) ] with time zone`        | 8 bytes      | both date and time, with time zone    | 4713 BC          | 294276 AD       | 1 microsecond |
| `date`                                        | 4 bytes      | date (no time of day)                 | 4713 BC          | 5874897 AD      | 1 day         |
| `time [ (*`p`*) ] [ without time zone ]`      | 8 bytes      | time of day (no date)                 | 00:00:00         | 24:00:00        | 1 microsecond |
| `time [ (*`p`*) ] with time zone`             | 12 bytes     | time of day (no date), with time zone | 00:00:00+1559    | 24:00:00-1559   | 1 microsecond |
| `interval [ *`fields`* ] [ (*`p`*) ]`         | 16 bytes     | time interval                         | -178000000 years | 178000000 years | 1 microsecond |

### Tipos de Datos Monetarios

| Name    | Storage Size | Description     | Range                                          |
| ------- | ------------ | --------------- | ---------------------------------------------- |
| `money` | 8 bytes      | currency amount | -92233720368547758.08 to +92233720368547758.07 |

### [Tipos de Datos Binarios](https://www.postgresql.org/docs/current/datatype-binary.html)

Una cadena binaria es una secuencia de octetos (o bytes). Las cadenas binarias se distinguen de las cadenas de caracteres de dos maneras. Primero, las cadenas binarias permiten específicamente almacenar octetos con valor cero y otros octetos "no imprimibles" (generalmente, octetos fuera del rango decimal de 32 a 126). Las cadenas de caracteres no permiten octetos con valor cero, ni tampoco permiten cualquier otro valor de octeto y secuencias de valores de octetos que sean inválidos según la codificación del conjunto de caracteres seleccionados en la base de datos. En segundo lugar, las operaciones en cadenas binarias procesan los bytes reales, mientras que el procesamiento de cadenas de caracteres depende de la configuración regional. En resumen, las cadenas binarias son apropiadas para almacenar datos que el programador considera como "bytes en bruto", mientras que las cadenas de caracteres son apropiadas para almacenar texto.

El tipo `bytea` soporta dos formatos para entrada y salida: el formato "hex" y el formato "escape" histórico de PostgreSQL. Ambos formatos son siempre aceptados en la entrada. El formato de salida depende del parámetro de configuración `bytea_output`; el valor predeterminado es hex. (Tenga en cuenta que el formato hex se introdujo en PostgreSQL 9.0; las versiones anteriores y algunas herramientas no lo entienden).

| Name    | Storage Size                               | Description                   |
| ------- | ------------------------------------------ | ----------------------------- |
| `bytea` | 1 or 4 bytes plus the actual binary string | variable-length binary string |

### [Tipos de Datos de Redes](https://www.postgresql.org/docs/current/datatype-net-types.html)

| Name       | Storage Size  | Description                      |
| ---------- | ------------- | -------------------------------- |
| `cidr`     | 7 or 19 bytes | IPv4 and IPv6 networks           |
| `inet`     | 7 or 19 bytes | IPv4 and IPv6 hosts and networks |
| `macaddr`  | 6 bytes       | MAC addresses                    |
| `macaddr8` | 8 bytes       | MAC addresses (EUI-64 format)    |

## [Tipos de Datos Geométricos](https://www.postgresql.org/docs/current/datatype-geometric.html)

| Name      | Storage Size | Description                      | Representation                      |
| --------- | ------------ | -------------------------------- | ----------------------------------- |
| `point`   | 16 bytes     | Point on a plane                 | (x,y)                               |
| `line`    | 32 bytes     | Infinite line                    | {A,B,C}                             |
| `lseg`    | 32 bytes     | Finite line segment              | ((x1,y1),(x2,y2))                   |
| `box`     | 32 bytes     | Rectangular box                  | ((x1,y1),(x2,y2))                   |
| `path`    | 16+16n bytes | Closed path (similar to polygon) | ((x1,y1),...)                       |
| `path`    | 16+16n bytes | Open path                        | [(x1,y1),...]                       |
| `polygon` | 40+16n bytes | Polygon (similar to closed path) | ((x1,y1),...)                       |
| `circle`  | 24 bytes     | Circle                           | <(x,y),r> (center point and radius) |



### Tipos de Datos JSON y XML

- `json`: Datos en formato JSON
- `jsonb`: Datos JSON en un formato binario más eficiente
- `xml`: Datos en formato XML

### Tipos de Datos Especiales

- `uuid`: Identificador único universal
- `array`: Arreglos de cualquier tipo de datos
- `composite`: Tipo compuesto de varios tipos de datos
- `range`: Rango de valores

### Enumeradores
```pgsql
CREATE TYPE sexo AS ENUM('Masculino', 'Femenino', 'Otro');

CREATE TABLE camper(
    name varchar(100) NOT NULL,
    sexo_camper sexo NOT NULL
);
```

## Ejemplo General de Tipos de Datos

```SQL
CREATE TABLE ejemplo (
    id serial PRIMARY KEY,
    nombre varchar(100) NOT NULL,
    descripcion text NULL,
    precio numeric(10, 2) NOT NULL,
    en_stock boolean NOT NULL,
    fecha_creacion date NOT NULL,
    hora_creacion time NOT NULL,
    fecha_hora timestamp NOT NULL,
    fecha_hora_zona timestamp with time zone,
    duracion interval,
    direccion_ip inet,
    direccion_mac macaddr,
    punto_geometrico point,
    datos_json json,
    datos_jsonb jsonb,
    identificador_unico uuid,
    cantidad_monetario money,
    rangos int4range,
    colores_preferidos varchar(20)[]
);
```

### Insert para `Ejemplo`

```SQL
INSERT INTO ejemplo(nombre, descripcion, precio, en_stock, fecha_creacion, hora_creacion, fecha_hora, fecha_hora_zona, duracion, direccion_ip, direccion_mac, punto_geometrico, datos_json, datos_jsonb, identificador_unico, cantidad_monetario, rangos,
colores_preferidos)
VALUES(
'Ejemplo A', 'Lorem ipsum......', 9990.99, true, '2025-07-10','20:30:10', '2025-07-10 20:30:10', '2025-07-10 20:30:10-05', '1 day', '192.168.0.1','08:00:27:00:00:00','(10, 20)', '{"key":"value"}','{"key":"value"}','b8ac502c-7049-4ae5-aa7e-642ad77ca4f1','100.00', '[10, 20)', ARRAY['rojo','verde','azul', 'otro']
);
```
## Definicion de Contraints (Restricciones)
### Tablas de Ejemplo
```SQL
CREATE TABLE empleados(
    id serial,
    nombre varchar(100) NOT NULL,
    edad integer NOT NULL,
    salario numeric(10,2) NOT NULL,
    fecha_contrato date,
    vigente boolean DEFAULT true
);
CREATE TABLE departamentos(
    id serial,
    nombre varchar(100) NOT NULL,
    vigente boolean DEFAULT true,
    PRIMARY KEY(id)
);

ALTER TABLE empleados ADD COLUMN departamento_id integer NOT NULL;

```
## Constraints a Tablas existentes
### Primary Key
```SQL
ALTER TABLE empleados ADD PRIMARY KEY(id);
```

### Foreign Key
```SQL
ALTER TABLE empleados ADD CONSTRAINT fk_departamento FOREIGN KEY(departamento_id) REFERENCES departamentos(id); 
```
### Unique
> Agregar la restriccion de UNIQUE a `nombre`
```SQL
ALTER TABLE empleados ADD CONSTRAINT uk_nombre UNIQUE(nombre);
```
### Check
> Agregar la restriccion de CHECK para validar que la `edad` del empleado sea >= 18
```SQL
ALTER TABLE empleados ADD CONSTRAINT ck_edad CHECK(edad >= 18 );
```
### Default
> Agregar un DEFAULT para `salario` de 400.00
```SQL
ALTER TABLE empleados ALTER COLUMN salario SET DEFAULT 400.00;
```
### Not null
```SQL
ALTER TABLE empleados ALTER COLUMN salario SET NOT NULL;
```

## Taller de Constraints
> Definir los Constraints (Primary key, Foreign Key, Not null, Default) mediante ALTER TABLE
```SQL
CREATE TABLE country (
	id serial,
	name varchar(50)
);

CREATE TABLE region (
	id serial,
	name varchar(50),
    idcountry integer
);

CREATE TABLE city (
	id serial,
	name varchar(50),
    idregion integer
);
```
## Funciones y Operadores - SELECT
1. Top 10 productos más vendidos (unidades) y su ingreso total
    - `SUM()`
    - `USING`
    ```sql
    SELECT p.id_producto, p.nombre,
        SUM(cp.cantidad) AS unidades,
        SUM(cp.total) AS ingreso_total
    FROM miscompras.compras_productos cp
    JOIN miscompras.productos p USING(id_producto)
    GROUP BY p.id_producto, p.nombre
    ORDER BY unidades DESC
    LIMIT 10;
    ```
2. Venta promedio por compra y mediana aproximada
    - `PERCENTILE_CONT(..) WITHIN GROUP(ORDER BY ..)`
    - `ROUND`
    - `USING`
    ```sql
    SELECT ROUND(AVG(t.total_compra), 2) AS promedio_compra,
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY t.total_compra) AS mediana
    FROM (
        SELECT c.id_compra, SUM(cp.total) as total_compra
        FROM miscompras.compras c
        JOIN miscompras.compras_productos cp USING(id_compra)
        GROUP BY c.id_compra
    ) t;
    ```
3. Compras por cliente y ranking
    - `COUNT`
    - `SUM`
    - `RANK() OVER(ORDER BY ... ASC/DESC) ASC/DESC`
    ```sql
    SELECT cl.id, cl.nombre || ' ' || cl.apellidos AS cliente,
        COUNT(DISTINCT c.id_compra) AS compras,
        SUM(cp.total) AS gasto_total,
        RANK() OVER(ORDER BY SUM(cp.total) DESC) AS ranking_gasto
    FROM miscompras.clientes cl
    JOIN miscompras.compras c ON cl.id = c.id_cliente 
    JOIN miscompras.compras_productos cp USING(id_compra)
    GROUP BY cl.id, cliente
    ORDER BY ranking_gasto;
    ```
4. Ticket por compra
    - `COUNT`
    - `ROUND`
    - `SUM`
    - `WITH .. AS`
    ```sql
    -- CURRENT_DATE, CURRENT_TIME, CURRENT_TIMESTAMP ~ NOW, AGE, EXTRACT
    -- COLUMN_NAME::day, COLUMN_NAME::date, COLUMN_NAME::month 
    WITH t AS(
        SELECT c.id_compra, c.fecha::date as dia, SUM(cp.total) as total_compra
        FROM miscompras.compras c
        JOIN miscompras.compras_productos cp USING(id_compra)
        GROUP BY c.id_compra, c.fecha::date
    )
    SELECT dia,
        COUNT(*) as numero_compras,
        ROUND(AVG(total_compra), 2) as promedio,
        SUM(total_compra) as total_dia
    FROM t
    GROUP BY dia
    ORDER BY dia;
    ```
5.  Búsqueda “tipo e‑commerce”: productos activos, disponibles y que empiecen por 'Caf'
    - `ILIKE`
    ```sql
    SELECT p.id_producto, p.nombre, p.precio_venta, p.cantidad_stock 
    FROM miscompras.productos p
    WHERE p.estado = 1 
        AND p.cantidad_stock > 0
        AND p.nombre ILIKE 'caf%';
    ```
23. Función: total de una compra (retorna NUMERIC)
    - `COALESCE`
    - `SUM`
    ```sql
    CREATE OR REPLACE FUNCTION miscompras.fn_total_compra(p_id_compra INT)
    RETURNS NUMERIC LANGUAGE plpgsql AS $$
    DECLARE v_total NUMERIC(16,2);
    BEGIN
        SELECT COALESCE(SUM(total), 0)
        INTO v_total
        FROM miscompras.compras_productos
        WHERE id_compra = p_id_compra;

        RETURN v_total;
    END;
    $$;
    -- SELECT miscompras.fn_total_compra(1);
    ```
20. Materialized view mensual
    ```sql
    DROP VIEW IF EXISTS  miscompras.reporte_mes;

    CREATE MATERIALIZED VIEW IF NOT EXISTS miscompras.reporte_mes AS
    SELECT DATE_TRUNC('month', c.fecha) AS mes,
        SUM(cp.total) AS total_ventas
    FROM miscompras.compras c
    JOIN miscompras.compras_productos cp USING(id_compra)
    GROUP BY mes;

    SELECT * FROM miscompras.reporte_mes;

    REFRESH MATERIALIZED VIEW miscompras.reporte_mes;
    ```
24.  Trigger: al insertar detalle de compra, descuenta stock
    - `GREATEST`
    ```sql
        CREATE OR REPLACE FUNCTION miscompras.trg_descuenta_stock()
        RETURNS TRIGGER LANGUAGE plpgsql AS
        $$
        BEGIN
            UPDATE miscompras.productos
            SET cantidad_stock = GREATEST(0, cantidad_stock - NEW.cantidad)
            WHERE id_producto = NEW.id_producto;
            RETURN NEW;
        END;
        $$;

        DROP TRIGGER IF EXISTS compras_productos_descuento_stock ON miscompras.compras_productos;

        CREATE TRIGGER compras_productos_descuento_stock
        AFTER INSERT ON miscompras.compras_productos
        FOR EACH ROW EXECUTE FUNCTION miscompras.trg_descuenta_stock();
    ```
27. Fucion: Mostrar el valor total en formato moneda
    - `TO_CHAR`
    ```sql
    SELECT nombre, miscompras.toMoney(precio_venta) as precio
    FROM miscompras.productos;

    CREATE OR REPLACE FUNCTION miscompras.toMoney(p_numeric NUMERIC)
    RETURNS VARCHAR LANGUAGE plpgsql AS
    $$
    DECLARE valor VARCHAR(255);
    BEGIN
        SELECT CONCAT('$ ', TO_CHAR(p_numeric, 'FM999G999G999D00')) INTO valor;
        RETURN valor;
    END;
    $$;
    ```
## Procedimientos de Almacenado
28. Procedure: Registrar nuevos clientes
    - `INITCAP` : adrian -> Adrian
    ```sql
    -- Actualizar nombres

    CREATE OR REPLACE PROCEDURE miscompras.pc_registrar_nuevo_cliente(p_nombre VARCHAR(100), p_apellido VARCHAR(100), p_celular NUMERIC(10, 0), p_direccion VARCHAR(80), p_email VARCHAR(70))
    LANGUAGE plpgsql AS 
    $$
    BEGIN
        INSERT INTO miscompras.clientes(nombre, apellidos, celular, direccion, correo_electronico)
        VALUES(INITCAP(TRIM(p_nombre)), INITCAP(TRIM(p_apellido),p_celular,TRIM(p_direccion),TRIM(p_email)));
        RAISE NOTICE 'Se registro el usuario % exitosamente.',p_email;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION 'Error al registrar el nuevo usuario, el usaurio ya se encuentra registrado';
    END;
    $$;


    ```