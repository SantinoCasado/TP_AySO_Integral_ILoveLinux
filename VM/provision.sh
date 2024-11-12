#!/bin/bash

# Actualizar y configurar la máquina
if [ -f /etc/debian_version ]; then
    # Ubuntu
    sudo apt-get update -y
    sudo apt-get install -y lvm2 ansible docker.io tree git
elif [ -f /etc/fedora-release ]; then
    # Fedora
    sudo dnf update -y
    sudo dnf install -y lvm2 ansible docker tree git
fi

# Configuración de SSH sin contraseña
mkdir -p /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
ssh-keygen -t rsa -b 4096 -N "" -f /home/vagrant/.ssh/id_rsa
cat /home/vagrant/.ssh/id_rsa.pub >> /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys

# Configurar sudo sin contraseña
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers > /dev/null

# Agregar referencias a /etc/hosts para la resolución de nombres
echo "192.168.56.10 test" | sudo tee -a /etc/hosts > /dev/null
echo "192.168.56.11 prod" | sudo tee -a /etc/hosts > /dev/null
