-- Pasos para crear la base de datos Personas
CREATE DATABASE personas;

-- Se debe cambiar a la nueva base de datos creada, 
-- para instalar la estensión en la base de datos
CREATE EXTENSION citus_columnar;

-- Consultar esquemas creados

SELECT schema_name
FROM information_schema.schemata
ORDER BY schema_name;
