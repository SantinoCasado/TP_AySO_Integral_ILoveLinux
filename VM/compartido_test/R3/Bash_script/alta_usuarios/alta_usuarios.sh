#!/bin/bash


# Verificar si se pasó un archivo como argumento
if [ -z "$1" ]; then
  echo "Error: No se especificó el archivo de lista de usuarios."
  echo "Uso: $0 <archivo_de_usuarios>"
  exit 1
fi

# Ruta de la lista de usuarios (primer argumento del script)
LISTA="$1"

# Obtener el nombre de usuario actual y su contraseña
USUARIO_BASE=$(whoami)
CLAVE=$(sudo grep "$(whoami)" /etc/shadow | awk -F ':' '{print $2}')

# Guardar el valor original de IFS
ANT_IFS=$IFS
IFS=$'\n'

# Iterar sobre cada línea en la lista de usuarios
for line in $(grep -v '^#' "$LISTA"); do
    # Dividir la línea en campos (Nombre_Usuario, Grupo_Primario, Directorio_Home)
    IFS=',' read -r Nombre_Usuario Grupo_Primario Directorio_Home <<< "$line"

    # Crear el grupo si no existe
    if ! grep -q "^$Grupo_Primario:" /etc/group; then
        echo "Creando el grupo: $Grupo_Primario"
        if ! sudo groupadd "$Grupo_Primario"; then
            echo "Error al crear el grupo $Grupo_Primario"
            exit 1
        fi
    fi

    # Crear el directorio de inicio si no existe
    if [ ! -d "$Directorio_Home" ]; then
        echo "Creando el directorio de inicio: $Directorio_Home"
        sudo mkdir -p "$Directorio_Home"
    else
        echo "El directorio de inicio $Directorio_Home ya existe."
    fi

    # Crear el usuario con su grupo y directorio
    # Verificar si el usuario ya existe
    if id "$Nombre_Usuario" &>/dev/null; then
        echo "El usuario $Nombre_Usuario ya existe. Omitiendo creación."
    else
        echo "Creando el usuario: $Nombre_Usuario en el grupo: $Grupo_Primario con directorio de inicio: $Directorio_Home"
        sudo useradd -m -s /bin/bash -g "$Grupo_Primario" -d "$Directorio_Home" "$Nombre_Usuario"

        # Asignar la misma contraseña que el usuario base
        echo "$Nombre_Usuario:$CLAVE" | sudo chpasswd
        echo "Usuario $Nombre_Usuario creado exitosamente con la misma clave que $USUARIO_BASE"
    fi

    # Cambiar la propiedad del directorio al usuario y grupo
    sudo chown "$Nombre_Usuario:$Grupo_Primario" "$Directorio_Home"
done

# Restaurar el valor original de IFS
IFS=$ANT_IFS

##############################
#   Verificamos que todos los usuarios se hayan creado
echo "Usuarios creados:"
cat /etc/passwd | grep TP_

#   Verificamos que estén todos los grupos creados
echo "Grupos creados:"
cat /etc/group | grep TP

#   Verificamos que las contraseñas estén asignadas correctamente
echo "Contraseñas de usuarios TP_ en /etc/shadow:"
sudo grep -E 'TP_' /etc/shadow | awk -F ':' '{print $2}'
