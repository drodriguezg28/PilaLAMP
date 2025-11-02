#!/bin/bash
set -x
# Instalar Apache 
sudo apt update
# Instalar php5
apt-get install -y apache2 php libapache2-mod-php php-mysql git
sudo systemctl enable php5
echo "PHP5 se ha instalado correctamente y está activo."


#Clonar el repositorio
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git
sudo cp -r iaw-practica-lamp/src /var/www/html/php


# Eliminar el repositorio clonado 
sudo rm -r iaw-practica-lamp
echo "Repositorio clonado eliminado."

# Crear el archivo de configuración del sitio web
cd /etc/apache2/sites-available/
cp 000-default.conf interfaz.conf
sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/php|' interfaz.conf
sudo a2ensite interfaz.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
echo "Sitio web habilitado." 
sudo sed -i "s|'localhost'|'192.168.50.11'|g; s|'database_name_here'|'interfaz'|g; s|'username_here'|'daniel'|g; s|'password_here'|'123456789'|g" /var/www/html/php/config.php









