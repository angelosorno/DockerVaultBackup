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

# Ruta a la carpeta donde están los backups
BACKUP_DIR="./data/VolumesBackup"

# Verificar si la carpeta de backups existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "No se encontró la carpeta $BACKUP_DIR con los backups."
    exit 1
fi

# Ajustar rutas según el sistema operativo
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    BACKUP_DIR_ABS="$(cd "$(pwd)" && pwd -W)/data/VolumesBackup"
    BACKUP_DIR_ABS=$(echo "$BACKUP_DIR_ABS" | sed 's|\\|/|g')
else
    BACKUP_DIR_ABS=$(pwd)/$BACKUP_DIR
fi

echo "Ruta de backup: $BACKUP_DIR_ABS"

# Buscar los archivos .tar.gz en la carpeta de backups
VOLUMES=$(ls "$BACKUP_DIR_ABS"/*.tar.gz | xargs -n 1 basename | sed 's/.tar.gz//')

# Verificar si hay backups disponibles
if [ -z "$VOLUMES" ]; then
    echo "No se encontraron archivos de backup en $BACKUP_DIR_ABS."
    exit 1
fi

# Restaurar cada volumen
for volume in $VOLUMES; do
    echo "Restaurando el volumen: $volume"

    # Verificar si el volumen ya existe
    if docker volume inspect "$volume" > /dev/null 2>&1; then
        echo "El volumen $volume ya existe. Omitiendo la creación..."
    else
        # Crear el volumen en Docker
        echo "Creando el volumen $volume..."
        docker volume create "$volume"
        if [ $? -ne 0 ]; then
            echo "Error al crear el volumen $volume"
            exit 1
        fi
    fi

    # Restaurar el backup en el volumen correspondiente
    echo "Restaurando contenido en el volumen $volume..."
    docker run --rm -v "${volume}:/data" -v "$BACKUP_DIR_ABS:/backup" busybox sh -c "tar xzf /backup/${volume}.tar.gz -C /data"
    
    if [ $? -eq 0 ]; then
        # Validar el contenido restaurado
        echo "Validando el contenido del volumen restaurado $volume:"
        docker run --rm -v "${volume}:/data" busybox sh -c "du -sh /data && ls -la /data"
        echo "Volumen $volume restaurado correctamente."
    else
        echo "Error al restaurar el volumen $volume"
        exit 1
    fi
done

echo "Todos los volúmenes han sido restaurados correctamente."
