#!/bin/bash

# Verificar si el demonio de Docker está activo
if ! docker info > /dev/null 2>&1; then
    echo "Docker no está corriendo. Por favor, inicia Docker antes de ejecutar este script."
    exit 1
fi

# Detectar si se usa docker-compose V1 o docker compose V2
if docker-compose --version > /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker-compose"
elif docker compose version > /dev/null 2>&1; then
    DOCKER_COMPOSE_CMD="docker compose"
else
    echo "Docker Compose no está instalado. Instala Docker Compose para continuar."
    exit 1
fi

# Cambiar al directorio padre si estamos dentro de DockerVaultBackup
CURRENT_DIR=$(basename "$(pwd)")
if [ "$CURRENT_DIR" == "DockerVaultBackup" ]; then
    echo "Moviendo al directorio padre para ejecutar los comandos correctamente..."
    cd ..
fi

# Ruta al archivo compose.yml
COMPOSE_FILE="compose.yml"

# Verificar si el archivo compose.yml existe en el directorio actual
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "No se encontró el archivo $COMPOSE_FILE en el directorio actual. Asegúrate de estar en el directorio correcto."
    exit 1
fi

# Crear una carpeta para almacenar los backups
BACKUP_DIR="./data/VolumesBackup"
mkdir -p "$BACKUP_DIR"

# Ajustar rutas según el sistema operativo
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    BACKUP_DIR_ABS="$(cd "$(pwd)" && pwd -W)/data/VolumesBackup"
    BACKUP_DIR_ABS=$(echo "$BACKUP_DIR_ABS" | sed 's|\\|/|g')
else
    BACKUP_DIR_ABS=$(pwd)/$BACKUP_DIR
fi

# Mostrar la ruta final que Docker usará para montar
echo "Ruta de backup: $BACKUP_DIR_ABS"

# Obtener los nombres de los contenedores activos a partir del archivo compose.yml
CONTAINERS=$($DOCKER_COMPOSE_CMD -f "$COMPOSE_FILE" ps --quiet)

if [ -z "$CONTAINERS" ]; then
    echo "No se encontraron contenedores activos definidos en $COMPOSE_FILE"
    exit 1
fi

# Obtener volúmenes montados directamente desde los contenedores activos
VOLUMES=$(docker inspect -f '{{ range .Mounts }}{{ .Name }}{{"\n"}}{{ end }}' $CONTAINERS | grep -v '^$' | sort | uniq)

# Verificar si hay volúmenes listados
if [ -z "$VOLUMES" ]; then
    echo "No se encontraron volúmenes montados en los contenedores activos."
    exit 1
fi

# Realizar un backup de cada volumen
for VOLUME_NAME in $VOLUMES; do
    echo "Respaldo del volumen: $VOLUME_NAME"

    if docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
        docker run --rm -v "${VOLUME_NAME}:/data" -v "$BACKUP_DIR_ABS:/backup" busybox sh -c "cd /data && tar czf /backup/${VOLUME_NAME}.tar.gz ."
        if [ $? -eq 0 ]; then
            echo "Volumen $VOLUME_NAME respaldado correctamente en $BACKUP_DIR"
        else
            echo "Error al respaldar el volumen $VOLUME_NAME"
        fi
    else
        echo "El volumen $VOLUME_NAME no existe en el demonio Docker."
    fi
done

echo "Todos los volúmenes han sido respaldados en la carpeta $BACKUP_DIR"
