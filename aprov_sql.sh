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
