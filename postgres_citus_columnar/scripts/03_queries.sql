-- Ver tamaño de las tablas
SELECT pg_size_pretty(pg_total_relation_size('personas')) AS total_size;
SELECT pg_size_pretty(pg_total_relation_size('personas_columnar')) AS total_size;

-- Comparativa de sentencia COUNT
EXPLAIN ANALYZE
SELECT COUNT(nombre) FROM personas;

EXPLAIN ANALYZE
SELECT COUNT(nombre) FROM personas_columnar;

--Comparativa obteniendo un solo campo
EXPLAIN analyze
SELECT nombre FROM personas;

EXPLAIN analyze
SELECT nombre FROM personas_columnar;

-- Comparativa consulta por campos
EXPLAIN analyze
SELECT nombre, edad, calle FROM personas;

EXPLAIN analyze
SELECT nombre, edad, calle FROM personas_columnar;