# PilaLAMP
Este documento recoge la práctica de montaje de una infraestructura en dos niveles

---

## Configuración del entorno con Vagrant

Se usa Vagrant con un Box oficial de Debian 12 para desplegar dos máquinas virtuales:
- Máquinas:
  - `MiNombreApache` (servidor web Apache)
  - `MiNombreMysql` (servidor MariaDB)

- La máquina Apache tiene acceso a Internet por NAT.
- La máquina MySQL no tiene acceso a Internet.
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

Lo primero que se deberá hacer es hacer un `vagrant up` del fichero ***Vagrantfile***

---

## Aprovisionamiento con scripts bash

Cada máquina será aprovisionada mediante un script bash que automatiza la instalación y configuración.

### Script de aprovisionamiento Apache (`apache_provision.sh`)
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
Este script:

- Actualiza el sistema.
- Instala Apache2 y PHP.
- Configura la aplicación de gestión de usuarios.
- Configura el firewall (ufw) para permitir solo el puerto necesario.
- Otras configuraciones específicas.




