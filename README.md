# PilaLAMP
### En esta práctica se realizará una pila LAMP en dos niveles, la cual estará organizada, por una parte el servidor apache, que será el que tendrá conexión a internet y contendrá la parte del PHP, y otro servidor SQL, el cual solo contendrá la base de datos, y no estará conectado a internet.

Lo primero que se deberá hacer es hacer un `vagrant up` del siguiente fichero ***vagrant.file***:

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


