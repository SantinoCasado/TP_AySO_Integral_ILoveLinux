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

# Verificar si la carpeta .ssh existe, si no, crearla
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
fi

# Generar la clave SSH si no existe
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N "" -f "$HOME/.ssh/id_ed25519"
fi

# Agregar la clave pública al archivo authorized_keys si no está presente
if ! grep -q "$(cat $HOME/.ssh/id_ed25519.pub)" "$HOME/.ssh/authorized_keys"; then
    cat "$HOME/.ssh/id_ed25519.pub" >> "$HOME/.ssh/authorized_keys"
fi

# Configurar permisos
chmod 700 "$HOME/.ssh"
chmod 600 "$HOME/.ssh/authorized_keys"

# Configurar sudo sin contraseña
#echo "%I_Love_Linux ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopasswd_sudo > /dev/null

# Agregar referencias a /etc/hosts para la resolución de nombres
echo "192.168.56.4 test" | sudo tee -a /etc/hosts > /dev/null
echo "192.168.56.5 prod" | sudo tee -a /etc/hosts > /dev/null
