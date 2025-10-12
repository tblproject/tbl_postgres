# Configuracion extensión Anonymizer
Se parte de [ésta URL](https://postgresql-anonymizer.readthedocs.io/en/latest/INSTALL/#install-on-debian-ubuntu). La instalación se ha realizado sobre un sistema operativo **Ubuntu Server 24.04 LTS**. Si trabajas con PostgreSQL desplegada en otro sistema operativo, revisa la URL incluida en este apartado para instalarla. La versión de PostgreSQL que estoy utilziando es la versión **17**.

### Pasos para la instalación
#### Añadir el repositorio 
Todos los comandos mostrados se ejecutan como usuario **root**. En estos pasos lo que se busca es instalar una serie de dependencias que tiene la librería y configurar el repositorio de la extensión dentro de los repositorios de paquetes dentro del operativo.

```bash
apt install curl lsb-release
echo deb http://apt.dalibo.org/labs $(lsb_release -cs)-dalibo main > /etc/apt/sources.list.d/dalibo-labs.list
curl -fsSL -o /etc/apt/trusted.gpg.d/dalibo-labs.gpg https://apt.dalibo.org/labs/debian-dalibo.gpg
apt update
```

#### Instalar la extensión
Una vez configurado el repositorio en el sistema operativo, y actualizada la lista de paquetes disponibles, solo queda instalar la extensión tirando de **apt**. Se debe instalar el paquete específico par ala versión de PostgreSQL con la que trabajas, en mi caso, la versión 17. Se debe revisar la documentación incluida en el enlace del principio de este documento para ver los detalles de la instalación de esta extensión para otras versiones, sobre todo si son ya versiones con cierto tiempo:

```bash
apt install postgresql_anonymizer_17
```

#### Revisar que se ha instalado

```bash
postgres=# SELECT * FROM pg_available_extensions;
        name        | default_version | installed_version |                                comment                                 
--------------------+-----------------+-------------------+------------------------------------------------------------------------
 amcheck            | 1.4             |                   | functions for verifying relation integrity
 
 . . . 

 citus_columnar     | 12.2-1          | 12.2-1            | Citus Columnar extension
 citus              | 13.2-1          |                   | Citus distributed database
 anon               | 2.4.0           | 2.4.0             | Anonymization & Data Masking for PostgreSQL
(48 filas)
```

### Pasos para el uso de la extensión
#### Crear una base de datos y aplicar la extensión

```sql
-- Como postgres
CREATE DATABASE rrhh;
\c rrhh

-- Crear extensión en la base de datos rrhh
CREATE EXTENSION anon CASCADE;
-- inicio de la extensión, esto creará el esquema anon en la base de datos rrhh
SELECT anon.init();

-- Modificaciones para cargar las librerías de anonymizer al inicio de las sesiones en PostgreSQL y modificar la base de datos para habilitar dynamic data masking
ALTER DATABASE rrhh SET anon.transparent_dynamic_masking = 'on';
ALTER DATABASE rrhh SET session_preload_libraries = 'anon';

\c rrhh  -- RECONECTAR para que se apliquen los cambios en la sesión del usuario postgres para seguir con la configuración

-- Se crea la tabla empleados
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

-- Se carga set de datos en la tabla empleados
COPY empleados(id,nombre,apellidos,dni,email,telefono,direccion,provincia,salario)
FROM '/DATASETS/empleados.csv' DELIMITER ',' CSV HEADER;

-- Se crea un usuario con permisos para ver todo, y otro que verá datos enmascarados
CREATE ROLE rrhh_admin LOGIN PASSWORD 'AdminPass123';
CREATE ROLE rrhh_consulta LOGIN PASSWORD 'UserPass123';

-- Se les concede permisos de acceso a la tabla empleados
GRANT CONNECT ON DATABASE rrhh TO rrhh_consulta, rrhh_admin;
GRANT USAGE ON SCHEMA public TO rrhh_consulta, rrhh_admin;
GRANT SELECT ON empleados TO rrhh_consulta, rrhh_admin;

-- Se crean reglas de enmascarado
SECURITY LABEL FOR anon ON COLUMN empleados.dni
IS 'MASKED WITH FUNCTION anon.partial(dni, 2, ''******'', 0)';

SECURITY LABEL FOR anon ON COLUMN empleados.email
IS 'MASKED WITH FUNCTION anon.fake_email()';

SECURITY LABEL FOR anon ON COLUMN empleados.salario
IS 'MASKED WITH VALUE 0';

SECURITY LABEL FOR anon ON COLUMN empleados.telefono
IS 'MASKED WITH FUNCTION anon.partial(telefono, 2, ''*******'', 2)';

-- Se modifica el usuario rrhh_consulta para que se le apliquen las reglas de enmascarado
SECURITY LABEL FOR anon ON ROLE rrhh_consulta IS 'MASKED';
ALTER ROLE rrhh_admin SET anon.masking = off;
ALTER ROLE rrhh_consulta SET anon.masking = on;

-- Se arranca el servicio de anonimización
SELECT anon.start_dynamic_masking();

```


https://postgresql-anonymizer.readthedocs.io/en/latest/dynamic_masking/



