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
# mkdir -p $HOME/.ssh
# ssh-keygen -t ed25519 -N "" -f $HOME/.ssh/id_ed25519
# cat $HOME/.ssh/id_ed25519.pub >> /home/vagrant/.ssh/authorized_keys

# Configurar sudo sin contraseña
#echo "ALL ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopasswd_sudo > /dev/null

# Agregar referencias a /etc/hosts para la resolución de nombres
echo "192.168.56.4 test" | sudo tee -a /etc/hosts > /dev/null
echo "192.168.56.5 prod" | sudo tee -a /etc/hosts > /dev/null
