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





