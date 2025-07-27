# Configuración de pg_duckdb
En este tutorial se explican los pasos dados para montar **PostgreSQL 17** sobre **Ubuntu Server 24.04 LTS**, e instalar la extensión **pg_duckdb** para poder trabajar con Postgres como un motor columnar.

Todos los comandos que se muestran en este tutorial se han lanzado con usuario **root** para el caso de los comandos a nivel de sistema operativo, y con el usuario **postgres** para los comandos lanzados contra Postgres, salvo que se diga lo contrario.

## Pasos para instalar PostgreSQL
Partimos de que se asigna un disco específico para almacenar los datos de Postgres. Se busca el dispositivo que se ha añadido a la máquina para utilizarlo como disco LVM:

```bash
# fdisk -l
Disk /dev/sda: 50 GiB, 53687091200 bytes, 104857600 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 7FACEE98-7C45-47C6-8376-31222F20355D

Device       Start       End   Sectors Size Type
/dev/sda1     2048      4095      2048   1M BIOS boot
/dev/sda2     4096   4198399   4194304   2G Linux filesystem
/dev/sda3  4198400 104855551 100657152  48G Linux filesystem


Disk /dev/sdb: 50 GiB, 53687091200 bytes, 104857600 sectors
Disk model: QEMU HARDDISK   
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/mapper/ubuntu--vg-ubuntu--lv: 48 GiB, 51535413248 bytes, 100655104 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
```

En este caso, el disco se trata de **/dev/sdb**. Lo configuramos para  trabajar con él a través de LVM, de esta manera, podremos ampliar la capacidad de este almacenamiento en cualquier momento. Lo marcamos para trabajar con LVM:

```bash
# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```

Se crea el volume group y el logical volume 
```bash
# vgcreate postgres /dev/sdb
  Volume group "postgres" successfully created
# lvcreate -L 49.9G -n data postgres
  Rounding up size to full physical extent 49,90 GiB
  Logical volume "data" created.
```

Se le da formato:
```bash
# mkfs.xfs /dev/mapper/postgres-data 
meta-data=/dev/mapper/postgres-data isize=512    agcount=4, agsize=3270400 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=1
         =                       reflink=1    bigtime=1 inobtcount=1 nrext64=0
data     =                       bsize=4096   blocks=13081600, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=16384, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
Discarding blocks...Done.
```
Se crea el punto de montaje:
```bash
# mkdir -p /var/lib/postgresql
```

Se incluye la entrada siguiente al archivo **/etc/fstab**:
```bash
/dev/mapper/postgres-data /var/lib/postgresql xfs defaults 0 1
```
Por útlimo, montamos el nuevo filesystem:
```bash
# mount -a 
```

Ya tenemos el disco listo para que PostgreSQL lo use para los datos, y podamos ampliar a futuro, ampliando el tamaño del volume Group.

## Instalar PostgreSQL 17

Lo primero es actualizar la lista de respositorios, para ponernos al día:
```bash
# apt update
```

Lo siguiente que haremos es instalar las referencias del repositorio de postgreSQL con la actualización a la versión 17 (Ubuntu tiene en sus repos la versión 16 de PostgreSQL, en la fecha en la que se hizo este documento). Y se descarga también la firma del repositorio. Por último, se vuelve a actualizar el listado de repositorios
```bash
# sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
# apt update
```

Se instala PostgreSQL, se arranca el servicio y se habilita para que arranque con el sistema operativo:
```bash
# apt install postgresql-17
# systemctl start postgresql
# systemctl enable postgresql
Synchronizing state of postgresql.service with SysV service script with /usr/lib/systemd/systemd-sysv-install.
Executing: /usr/lib/systemd/systemd-sysv-install enable postgresql
```

Se puede ver el estado del servcio:
```bash
# systemctl status postgresql
● postgresql.service - PostgreSQL RDBMS
     Loaded: loaded (/usr/lib/systemd/system/postgresql.service; enabled; preset: enabled)
     Active: active (exited) since Sun 2025-07-27 15:52:24 UTC; 34s ago
   Main PID: 4849 (code=exited, status=0/SUCCESS)
        CPU: 4ms

jul 27 15:52:24 tbl-postgres-01 systemd[1]: Starting postgresql.service - PostgreSQL RDBMS...
jul 27 15:52:24 tbl-postgres-01 systemd[1]: Finished postgresql.service - PostgreSQL RDBMS.
```

Si en la máquina tenéis un firewall habilitado, debéis permitir el tráfico al puerto **5432** a las máquinas desde las que se acceda a esta instancia. En Ubuntu sería:
```bash
ufw allow 5432/tcp
```

## Configuración de PostgreSQL
Tras la instalación se deberá hacer una configuración mínima, aquí cada cual que lo adapte a sus necesidades. Para ello nos vamos a **/etc/postgresql/17/main** que es en donde tenemos los archivos de configuración de PostgreSQL 17.

Aquí se modifica el archivo **postrgresql.conf para permitir que el servicio escuche en todas las IPs de la máquina. Para ello se descomenta y modifica el siguiente parámetro:
```bash
listen_addresses = '*'  
```
Ahora vamos con la autenticación, para ello editamos el archivo **pg_hba.conf** para permitir el acceso desde las máquinas de nuestra red. Se podría limitar a IPs concretas, eso a gusto del consumidor, y se marca que se use **md5** como método de cifrado para las passwords; un ejemplo de cómo quedaría la configuración:
```bash
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             192.168.50.0/24         md5
host    all             all             10.0.0.0/24             md5
```

Nos falta crear una contraseña para el usuario **postgres**:
```bash
sudo -u postgres psql
ALTER USER postgres PASSWORD 'VeryStronGPassWord';
\q
```

Reiniciamos el servicio para aplicar todos los cambios:
```bash
# systemctl restart postgresql
```

# Pasos para instalar extensión citus en Postgres

No existe todavía paquete oficial de Citus para Ubuntu 24.04 LTS así que toca compilar desde el código fuente, a la vieja usanza. Si trabajáis con una versión 22.04 LTS podéis ver cómo instalarlo a partir de paquetería siguiendo los pasos de esta URL: 
https://github.com/citusdata/citus?tab=readme-ov-file#install-citus-locally

Para compliar desde la fuente, se lanzan los siguientes comandos:

Lo primero es instalar las herramientas de compilador junto con otras librerías necesarias, incluidas las librerías de desarrollo de PostgreSQL:

```bash
# apt install -y build-essential libcurl4-openssl-dev liblz4-dev libzstd-dev postgresql-server-dev-17 libkrb5-dev
```
Se clona el repositorio del proyecto y entramos en el directorio del repositorio:
```bash
# git clone https://github.com/citusdata/citus.git
# cd citus
```

Ahora toca compilar:
```bash
# ./configure
# make install
```

Se descomenta y modifica el siguiente parámetro en el archivo **/etc/postgresql/17/main/postgresql.conf**:

```bash
shared_preload_libraries = 'citus'
```
Y se reinicia el servicio:
```bash
# systemctl restart postgresql
```

Probamos a crear la extensión en la base de datos postgres para validar la instalación:
```bash
# sudo -u postgres psql
postgres=# CREATE EXTENSION citus_columnar;
CREATE EXTENSION
```
Si lanzáis la siguiente consulta, podéis ver que se han instalado dos extensiones asociadas al proyecto **Citus**: citus y citus_columnar.
```bash
ostgres=# SELECT * FROM pg_available_extensions;
        name        | default_version | installed_version |                                comment                                 
--------------------+-----------------+-------------------+------------------------------------------------------------------------
 amcheck            | 1.4             |                   | functions for verifying relation integrity
 autoinc            | 1.0             |                   | functions for autoincre

. . . 

 citus_columnar     | 12.2-1          | 12.2-1            | Citus Columnar extension
 citus              | 13.2-1          |                   | Citus distributed database
```
Podemos asegurarnos de que se ha instalado en la base de datos postgres las extensiones asociadas a citus:
```bash
postgres=# SELECT extname, extversion, extnamespace::regnamespace AS schema
FROM pg_extension;
    extname     | extversion |   schema   
----------------+------------+------------
 plpgsql        | 1.0        | pg_catalog
 citus_columnar | 12.2-1     | pg_catalog
postgres=# \q
```


