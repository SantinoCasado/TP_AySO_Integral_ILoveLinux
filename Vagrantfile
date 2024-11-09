Vagrant.configure("2") do |config|
  # Definir las dos máquinas virtuales: una para Ubuntu (para testing) y una para Fedora (para producción)
  
  # VM1: Ubuntu (para testing) con 1GB de memoria
  config.vm.define "VM1-Grupo-I_Love_Linux" do |vm|
    vm.vm.box = "ubuntu/bionic64"  # Especificar la caja de Ubuntu

    vm.vm.network "private_network", ip: "192.168.56.10"  # IP estática

    # Configuración de recursos (1GB de memoria)
    vm.vm.provider "virtualbox" do |v|
      v.memory = 1024  # 1GB de memoria
      v.cpus = 2
    end

    # Aprovisionamiento: Instalación de Docker, Ansible, Git, LVM y particiones
    vm.vm.provision "shell", inline: <<-SHELL
      # Actualizar el sistema
      sudo apt-get update -y
      sudo apt-get upgrade -y

      # Instalar las herramientas necesarias
      sudo apt-get install -y lvm2 docker.io ansible git

      # Crear los volúmenes físicos (PV)
      sudo pvcreate /dev/sdc /dev/sdd /dev/sdb

      # Crear los grupos de volúmenes (VG)
      sudo vgcreate vg_datos /dev/sdc /dev/sdd
      sudo vgcreate vgTemp /dev/sdb

      # Crear los volúmenes lógicos (LV)
      sudo lvcreate -L 10M -n lv_docker vg_datos
      sudo lvcreate -L 2.5G -n lv_Workareas vg_datos
      sudo lvcreate -L 2.5G -n lv_swap vgTemp

      # Crear los sistemas de archivos en los volúmenes lógicos
      sudo mkfs.ext4 /dev/vg_datos/lv_docker
      sudo mkfs.ext4 /dev/vg_datos/lv_Workareas
      sudo mkswap /dev/vgTemp/lv_swap

      # Montar los volúmenes lógicos
      sudo mount /dev/vg_datos/lv_docker /var/lib/docker
      sudo mount /dev/vg_datos/lv_Workareas /work

      # Activar el swap
      sudo swapon /dev/vgTemp/lv_swap

      # Verificar que todo esté correctamente montado y configurado
      sudo df -h
      sudo swapon -s

      # Instalar Docker Compose
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose

      # Verificar las versiones de las herramientas
      docker --version
      docker-compose --version
      ansible --version
      git --version
    SHELL
  end

  # VM2: Fedora (para producción)
  config.vm.define "VM2-Grupo-I_Love_Linux" do |vm|
    vm.vm.box = "generic/fedora37"  # Caja de Fedora
    vm.vm.network "private_network", ip: "192.168.56.11"  # IP estática

    # Configuración de recursos
    vm.vm.provider "virtualbox" do |v|
      v.memory = 2048  # 2GB de memoria para producción
      v.cpus = 2
    end

    # Aprovisionamiento similar a VM1 pero con Fedora
    vm.vm.provision "shell", inline: <<-SHELL
      # Actualizar el sistema
      sudo dnf update -y

      # Instalar las herramientas necesarias
      sudo dnf install -y lvm2 docker ansible git

      # Crear los volúmenes físicos (PV)
      sudo pvcreate /dev/sdc /dev/sdd /dev/sdb

      # Crear los grupos de volúmenes (VG)
      sudo vgcreate vg_datos /dev/sdc /dev/sdd
      sudo vgcreate vgTemp /dev/sdb

      # Crear los volúmenes lógicos (LV)
      sudo lvcreate -L 10M -n lv_docker vg_datos
      sudo lvcreate -L 2.5G -n lv_Workareas vg_datos
      sudo lvcreate -L 2.5G -n lv_swap vgTemp

      # Crear los sistemas de archivos en los volúmenes lógicos
      sudo mkfs.ext4 /dev/vg_datos/lv_docker
      sudo mkfs.ext4 /dev/vg_datos/lv_Workareas
      sudo mkswap /dev/vgTemp/lv_swap

      # Montar los volúmenes lógicos
      sudo mount /dev/vg_datos/lv_docker /var/lib/docker
      sudo mount /dev/vg_datos/lv_Workareas /work

      # Activar el swap
      sudo swapon /dev/vgTemp/lv_swap

      # Verificar que todo esté correctamente montado y configurado
      sudo df -h
      sudo swapon -s

      # Instalar Docker Compose
      sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      sudo chmod +x /usr/local/bin/docker-compose

      # Verificar las versiones de las herramientas
      docker --version
      docker-compose --version
      ansible --version
      git --version
    SHELL
  end

  # Aumenta el tiempo de espera para el arranque de la máquina (en caso de que sea necesario)
  config.vm.boot_timeout = 1200
end
