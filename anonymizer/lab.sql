-- Como postgres
CREATE DATABASE rrhh;
\c rrhh

CREATE EXTENSION anon CASCADE;
SELECT anon.init();

ALTER DATABASE rrhh SET session_preload_libraries = 'anon';
ALTER DATABASE rrhh SET anon.transparent_dynamic_masking = 'on';
ALTER DATABASE rrhh SET anon.masking_policies TO 'rrhh, financiero';
\c rrhh  -- RECONECTAR

CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    apellidos VARCHAR(150),
    dni VARCHAR(15),
    email VARCHAR(150),
    telefono VARCHAR(20),
    direccion VARCHAR(200),
    provincia VARCHAR(100),
    salario NUMERIC(10,2)
);

COPY empleados(id,nombre,apellidos,dni,email,telefono,direccion,provincia,salario)
FROM '/DATASETS/empleados.csv' DELIMITER ',' CSV HEADER;

CREATE ROLE rrhh_admin LOGIN PASSWORD 'AdminPass123';
CREATE ROLE rrhh_consulta LOGIN PASSWORD 'UserPass123';
CREATE ROLE rrhh_financiero LOGIN PASSWORD 'FinPass123';


GRANT CONNECT ON DATABASE rrhh TO rrhh_consulta, rrhh_admin, rrhh_financiero;
GRANT USAGE ON SCHEMA public TO rrhh_consulta, rrhh_admin, rrhh_financiero;
GRANT SELECT ON empleados TO rrhh_consulta, rrhh_admin, rrhh_financiero;

-----------------------------------------
--- Reconectar
-----------------------------------------

-- Reglas para el usuario de consulta RRHH
SECURITY LABEL FOR rrhh ON COLUMN empleados.dni
IS 'MASKED WITH FUNCTION anon.partial(dni, 2, ''******'', 0)';

SECURITY LABEL FOR rrhh ON COLUMN empleados.email
IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR rrhh ON COLUMN empleados.salario
IS 'MASKED WITH VALUE 0';

SECURITY LABEL FOR rrhh ON COLUMN empleados.telefono
IS 'MASKED WITH FUNCTION anon.partial(telefono, 2, ''*******'', 2)';

-- Reglas para el usuario de financiero
SECURITY LABEL FOR financiero ON COLUMN empleados.dni
IS 'MASKED WITH FUNCTION anon.partial(dni, 2, ''******'', 0)';

SECURITY LABEL FOR financiero ON COLUMN empleados.email
IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR financiero ON COLUMN empleados.telefono
IS 'MASKED WITH FUNCTION anon.partial(telefono, 2, ''*******'', 2)';


-- Se aplican las reglas a los usuarios
SECURITY LABEL FOR rrhh ON ROLE rrhh_consulta IS 'MASKED';
SECURITY LABEL FOR financiero ON ROLE rrhh_financiero IS 'MASKED';

-- Se modifican los roles para habilitar o desactivar el enmascaramiento
ALTER ROLE rrhh_admin SET anon.masking = off;
ALTER ROLE rrhh_consulta SET anon.masking = on;
ALTER ROLE rrhh_financiero SET anon.masking = on;

-- Se arranca el enmascaramiento
SELECT anon.start_dynamic_masking();


-- Exacto. El problema es que las políticas rrhh y financiero no heredan los permisos de anon.
-- Como superuser, marca esas funciones como TRUSTED:

ALTER FUNCTION anon.fake_email() SECURITY DEFINER SET search_path = anon, public;
ALTER FUNCTION anon.partial(text, integer, text, integer) SECURITY DEFINER SET search_path = anon, public;



SELECT * FROM pg_seclabel WHERE provider = 'rrhh';
SELECT * FROM pg_seclabel WHERE provider = 'financiero';





