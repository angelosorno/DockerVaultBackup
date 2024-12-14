#!/bin/bash

# Verificar si el demonio de Docker está activo
if ! docker info > /dev/null 2>&1; then
    echo "Docker no está corriendo. Por favor, inicia Docker antes de ejecutar este script."
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

# Extraer los nombres de los volúmenes definidos en el archivo compose.yml
VOLUMES=$(docker compose -f $COMPOSE_FILE config --volumes)

# Verificar si hay volúmenes listados
if [ -z "$VOLUMES" ]; then
    echo "No se encontraron volúmenes definidos en el archivo $COMPOSE_FILE"
    exit 1
fi

# Crear una carpeta para almacenar los backups
BACKUP_DIR="./data/VolumesBackup"
mkdir -p "$BACKUP_DIR"

# Ajustar rutas según el sistema operativo
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    BACKUP_DIR_ABS="$(pwd | sed 's|^/|/|')/$BACKUP_DIR"
else
    BACKUP_DIR_ABS=$(pwd)/$BACKUP_DIR
fi


# Mostrar la ruta final que Docker usará para montar
echo "Ruta de backup: $BACKUP_DIR_ABS"

# Realizar un backup de cada volumen
for volume in $VOLUMES; do
    echo "Respaldo del volumen: $volume"
    
    # Buscar el nombre del volumen en Docker (con posibles prefijos)
    VOLUME_NAME=$(docker volume ls --format '{{.Name}}' | grep "$volume")

    if [ -n "$VOLUME_NAME" ]; then
        # Verificar si el volumen existe en el sistema de Docker
        if docker volume inspect "$VOLUME_NAME" > /dev/null 2>&1; then
            # Crear el backup del volumen en un archivo tar.gz
            docker run --rm -v "${VOLUME_NAME}:/data" -v "$BACKUP_DIR_ABS:/backup" busybox sh -c "cd /data && tar czf /backup/${VOLUME_NAME}.tar.gz ."
            if [ $? -eq 0 ]; then
                echo "Volumen $VOLUME_NAME respaldado correctamente en $BACKUP_DIR"
            else
                echo "Error al respaldar el volumen $VOLUME_NAME"
            fi
        else
            echo "El volumen $VOLUME_NAME no existe en el demonio Docker."
        fi
    else
        echo "No se encontró ningún volumen que coincida con $volume"
    fi
done

echo "Todos los volúmenes han sido respaldados en la carpeta $BACKUP_DIR"
    