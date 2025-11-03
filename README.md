# PilaLAMP
Este documento recoge la práctica de montaje de una infraestructura en dos niveles, la cual contiene una maquina Apache y otra con MariaDB

---

## Configuración con Vagrant

Se usa Vagrant con un Box de Debian 12 para desplegar dos máquinas:
- Máquinas:
  - `DanielRodApache` (servidor web Apache)
  - `DanielRodSQL` (servidor MariaDB)

- La máquina Apache tiene acceso a Internet por NAT.
- La máquina SQL no tiene acceso a Internet.
- Acceso a la aplicación mediante port forwarding.

### Vagrantfile

```ruby
Vagrant.configure("2") do |config|

  config.vm.box = "debian/bookworm64"

  config.vm.define "apache" do |apache|
    apache.vm.box = "debian/bookworm64" # Box Debian 12
    apache.vm.network "private_network", ip:"192.168.50.10", virtualbox__intnet: "red1" # Red interna
    apache.vm.hostname = "DanielRodApache" # Nombre del host
    apache.vm.network "forwarded_port", guest: 80, host: 8080 # Redirección del puerto 80 de la maquina al 8080 del host
    apache.vm.provision "shell", path: "aprov_apache.sh" # Script de aprovisionamiento
  end
  
  config.vm.define "sql" do |sql|
    sql.vm.box = "debian/bookworm64"  # Box Debian 12
    sql.vm.network "private_network", ip:"192.168.50.11", virtualbox__intnet: "red1"  # Red interna
    sql.vm.hostname = "DanielRodSQL"  # Nombre del host
    sql.vm.provision "shell", path: "aprov_sql.sh"  # Script de aprovisionamiento
  end
end
```

---

## Aprovisionamiento con scripts bash

Cada máquina será aprovisionada mediante un script bash que automatiza la instalación y configuración.

### Script de aprovisionamiento Apache y PHP (`aprov_apache.sh`)
```ruby
#!/bin/bash
# Actualización de los repositorios
sudo apt update
# Instalación de apache y php5
apt install -y apache2 php libapache2-mod-php php-mysql
sudo systemctl enable php
echo "PHP se ha instalado correctamente y está activo."

#Clonación del repositorio
apt install -y git
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
sudo cp -r iaw-practica-lamp/src /var/www/html/php

# Eliminación de los restos del repositorio clonado 
sudo rm -r iaw-practica-lamp
echo "Repositorio clonado eliminado."

#Configuración de la conexión a la base de datos
sudo sed -i "s|'localhost'|'192.168.50.11'|g; s|'database_name_here'|'interfaz'|g; s|'username_here'|'daniel'|g; s|'password_here'|'123456789'|g" /var/www/html/php/config.php

# Creación del archivo de configuración del sitio web
cd /etc/apache2/sites-available/
cp 000-default.conf interfaz.conf
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/php|' interfaz.conf
sudo a2ensite interfaz.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
echo "Sitio web habilitado."
```
**Este script realiza lo siguiente:**

- Actualiza los repositorios.
- Instala Apache2 y PHP.
- Instala Git y clona el repositorio con la aplicación.
- Copia el código php a `/var/www/html/php`.
- Modifica el archivo `config.php` para crear la configuración entre Apache y MariaDB.
- Configura un nuevo sitio en Apache para la aplicación.

**Explicación de comandos:**

- `apt update`: Actualiza los paquetes.
- `apt install apache2 php libapache2-mod-php php-mysql`: Instala Apache, PHP y sus módulos.
- `git clone`: Descarga el código de PHP desde GitHub.
- `cp -r`: Copia los archivos de la aplicación al directorio web de Apache.
- `sed -i`: Modifica el archivo de configuración PHP para conectar con el servidor MySQL remoto.
- `a2ensite` y `a2dissite`: Habilita el nuevo sitio y deshabilita el sitio por defecto, respectivamente.

---

### Script para MariaDB (`mysql_provision.sh`)

```ruby
#!/bin/bash

# Instalar MariaDB
sudo apt update
sudo apt install -y mariadb-serverç
echo "MariaDB se ha instalado correctamente."

# Iniciar, activar y configurar el servicio de MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo sed -i "s|bind-address\s*=.*|bind-address = 0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
echo "MariaDB se ha instalado correctamente, se ha configurado y está activo."


#Clonar el repositorio para añadir el script de sql
sudo apt install -y git
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
echo "Repositorio clonado."


# Crear base de datos, usuario y asignar permisos
sudo mysql -u root -e "create database if not exists interfaz;"
sudo mysql -u root -e "CREATE USER 'daniel'@'192.168.50.%' IDENTIFIED BY '123456789';"
sudo mysql -u root -e "GRANT update, insert, delete, select ON interfaz.* TO 'daniel'@'192.168.50.%';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
echo "Base de datos y usuario daniel creados con permisos asignados."
echo "Usuario admin con contraseña '123456789'."
# Importar el script SQL
mysql -u root interfaz < iaw-practica-lamp/db/database.sql
echo "Base de datos importada correctamente."

# Eliminar el repositorio clonado 
sudo rm -r iaw-practica-lamp
echo "Restos del repositorio clonado eliminado."

# Inhabilitar la red NAT
sudo route del

echo "Configuración de MariaDB y de la base de datos completado."
```

**Este script realiza:**
- Actualiza repositorios.
- Instala MariaDB.
- Modifica la configuración para permitir conexiones remotas.
- Instala Git y clona el repositorio que contiene el script SQL.
- Crea la base de datos `interfaz` y un usuario `daniel`, en este caso solo con acceso desde la red interna.
- Importa el script SQL para crear tablas y datos iniciales.
- Deshabilita el acceso a Internet de esta máquina.

**Explicación de órdenes:**
- `apt install mariadb-server`: Instalación de MariaDB.
- `sed -i`: Cambia `bind-address` para aceptar conexiones remotas.
- `git clone`: Obtiene el script SQL del repositorio de GitHub.
- Sentencias SQL en `mysql -e`: Crea base de datos, usuario y asigna permisos.
- `interfaz < database.sql`: Importa los datos del script database.sql a la base de datos interfaz.
- `route del default`: Elimina la gateway para inhabilitar la salida a internet.


## Acceso a la Aplicación Web
1. Hacer un `vagrant up` del fichero ***Vagrantfile*** para desplegar y aprovisionar la maquina.
2. Introducir en tu nvegador la dirección <http://localhost:8080/> para acceder a la aplicación a través del puerto 8080.

## Capturas de pantalla y Screencast

**Navegador mostrando la aplicación operativa vía port forwarding.**
![Captura Aplicación web](/src/Captura_pantalla.png)
**Screen cast**
[Video de demostración](src/Video.mp4)


---


