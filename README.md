# PilaLAMP
### En esta práctica se realizará una pila LAMP en dos niveles, la cual estará organizada, por una parte el servidor apache, que será el que tendrá conexión a internet y contendrá la parte del PHP, y otro servidor SQL, el cual solo contendrá la base de datos, y no estará conectado a internet.

Lo primero que se deberá hacer es hacer un `vagrant up` del siguiente fichero ***vagrant.file***:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64"

  
  config.vm.define "apache" do |apache|
    apache.vm.box = "debian/bookworm64"
    apache.vm.network "private_network", ip:"192.168.50.10", virtualbox__intnet: "red1"
    apache.vm.hostname = "DanielRodApache"
    apache.vm.network "forwarded_port", guest: 80, host: 8080
    apache.vm.provision "shell", path: "aprov_apache.sh"
  end
  
  config.vm.define "sql" do |sql|
    sql.vm.box = "debian/bookworm64"
    sql.vm.network "private_network", ip:"192.168.50.11", virtualbox__intnet: "red1"
    sql.vm.hostname = "DanielRodSQL"
    sql.vm.provision "shell", path: "aprov_sql.sh"
  end
end
```

