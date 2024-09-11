#!/bin/bash

# Verificar si el demonio de Docker está activo
if ! docker info > /dev/null 2>&1; then
    echo "Docker no está corriendo. Por favor, inicia Docker antes de ejecutar este script."
    exit 1
fi

# Ruta al archivo compose.yml (asegúrate de estar en el mismo directorio que tu compose.yml)
COMPOSE_FILE="compose.yml"

# Extraer los nombres de los volúmenes definidos en el archivo compose.yml
VOLUMES=$(docker compose -f $COMPOSE_FILE config --volumes)

# Verificar si hay volúmenes listados
if [ -z "$VOLUMES" ]; then
    echo "No se encontraron volúmenes definidos en el archivo $COMPOSE_FILE"
    exit 1
fi

# Crear una carpeta para almacenar los backups
BACKUP_DIR="./data/volumes_backup"
mkdir -p "$BACKUP_DIR"

# Detectar si estamos en un sistema Windows o Linux
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Convertir ruta para Docker en Windows al formato /d/... en lugar de C:/...
    BACKUP_DIR_ABS="/$(pwd | sed 's|^/c/|c:/|' | sed 's|^/d/|d:/|')/$BACKUP_DIR"
else
    # Si es Linux/Unix, usar la ruta tal como está
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
            # Crear el backup del volumen en un archivo tar.gz, sin crear un archivo .tar intermedio
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
