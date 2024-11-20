#!/bin/bash

# Lista de usuarios a crear
USERS=("Colo" "Santi" "Lean" "Roman")

# Definir contraseñas
PASSWORDS=("colo" "santi" "lean" "roman")

# Crear cada usuario y asignar su contraseña
for i in "${!USERS[@]}"; do
  USER=${USERS[$i]}
  PASSWORD=${PASSWORDS[$i]}

  # Crear el usuario (requiere sudo)
  echo "Creando el usuario $USER..."
  sudo useradd -m -s /bin/bash $USER

  # Establecer la contraseña del usuario (requiere sudo)
  echo "$USER:$PASSWORD" | sudo chpasswd

  # Agregar el usuario al grupo sudo (requiere sudo)
  sudo usermod -aG sudo $USER

  # Crear el directorio .ssh para el usuario (requiere sudo)
  sudo mkdir -p /home/$USER/.ssh
  sudo chmod 700 /home/$USER/.ssh
  sudo chown $USER:$USER /home/$USER/.ssh

  # Copiar la clave pública de vagrant (si existe) a la lista de claves autorizadas
  if [ -f /home/vagrant/.ssh/authorized_keys ]; then
    sudo cp /home/vagrant/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys
    sudo chmod 600 /home/$USER/.ssh/authorized_keys
    sudo chown $USER:$USER /home/$USER/.ssh/authorized_keys
  else
    echo "No se encontró la clave SSH de vagrant, se omite la copia."
  fi

  echo "Usuario $USER creado con éxito."
done

# Generar las claves SSH si no existen (para evitar la sobrescritura)
for USER in "${USERS[@]}"; do
  if [ ! -f /home/$USER/.ssh/id_rsa ]; then
    echo "Generando claves SSH para el usuario $USER..."
    sudo -u $USER ssh-keygen -t rsa -b 2048 -f /home/$USER/.ssh/id_rsa -N ""
    sudo chown -R $USER:$USER /home/$USER/.ssh
  fi
done

# Copiar las claves públicas de cada usuario a los otros usuarios (cruzar las claves)
for USER1 in "${USERS[@]}"; do
  for USER2 in "${USERS[@]}"; do
    if [ "$USER1" != "$USER2" ]; then
      # Copiar la clave pública de USER1 a USER2
      echo "Copiando la clave pública de $USER1 a $USER2..."
      sudo cp /home/$USER1/.ssh/id_rsa.pub /home/$USER2/.ssh/authorized_keys
      sudo chmod 600 /home/$USER2/.ssh/authorized_keys
      sudo chown $USER2:$USER2 /home/$USER2/.ssh/authorized_keys
    fi
  done
done

echo "Usuarios y claves SSH cruzadas configuradas correctamente."
