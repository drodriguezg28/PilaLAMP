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









