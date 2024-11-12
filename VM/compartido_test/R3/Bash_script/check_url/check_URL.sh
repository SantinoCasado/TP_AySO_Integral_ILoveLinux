#!/bin/bash

# Verificar si se pasó un archivo como argumento
if [ -z "$1" ]; then
  echo "Error: No se especificó el archivo de URLs."
  echo "Uso: $0 <archivo_de_urls>"
  exit 1
fi

# Ruta de la lista de URL (primer argumento del script)
LISTA="$1"

# Archivo de log general
LOG_FILE="/var/log/status_url.log"

# Guardar el IFS actual y cambiarlo a salto de línea
ANT_IFS=$IFS
IFS=$'\n'

# Directorio base para almacenar los logs de cada dominio
BASE_DIR="/tmp/headh-check"

# Crear la estructura de directorios
mkdir -p "$BASE_DIR"/{Error/{cliente,servidor},OK}

# Iterar sobre cada línea de la lista de URLs
for LINE in $(grep -v '^#' "$LISTA"); do
  # Ignorar líneas vacías o comentarios (líneas que empiezan con '#')
  if [[ -z "$LINE" || "$LINE" =~ ^# ]]; then
    continue
  fi

  # Extraer dominio y URL
  DOMINIO=$(echo "$LINE" | awk '{print $1}')
  URL=$(echo "$LINE" | awk '{print $2}')

  # Obtener el código de estado HTTP
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  # Fecha y hora actual en formato yyyymmdd_hhmmss
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Registrar en el archivo de log general
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a "$LOG_FILE" > /dev/null

  # Determinar la carpeta donde guardar el log individual
  if [ "$STATUS_CODE" -eq 200 ]; then
    DIR="$BASE_DIR/OK"
  elif [ "$STATUS_CODE" -ge 400 ] && [ "$STATUS_CODE" -le 499 ]; then
    DIR="$BASE_DIR/Error/cliente"
  elif [ "$STATUS_CODE" -ge 500 ] && [ "$STATUS_CODE" -le 599 ]; then
    DIR="$BASE_DIR/Error/servidor"
  else
    # Manejo de códigos no esperados
    DIR="$BASE_DIR/Otros"
    mkdir -p "$DIR"
  fi

  # Guardar la entrada en el archivo de log individual en la carpeta correspondiente
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" > "${DIR}/${DOMINIO}.log"
done

# Restaurar el valor original de IFS
IFS=$ANT_IFS

# Mostrar el contenido del archivo de log general
cat /var/log/status_url.log

