#!/bin/bash

# Verificar si el demonio de Docker está activo
if ! docker info > /dev/null 2>&1; then
    echo "Docker no está corriendo. Por favor, inicia Docker antes de ejecutar este script."
    exit 1
fi

# Lista de volúmenes esperados basados en el compose.yml
EXPECTED_VOLUMES=("couchdb3_data" "minio_data" "redis_data")

# Crear una carpeta para almacenar los backups
BACKUP_DIR="./data/volumes_backup"
mkdir -p $BACKUP_DIR

# Detectar si estamos en un sistema Windows o Linux
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Convertir ruta para Docker en Windows al formato /c/... en lugar de C:\...
    BACKUP_DIR_ABS="/$(pwd | sed 's|C:/|c/|' | sed 's|/|/|g')/$BACKUP_DIR"
else
    # Si es Linux/Unix, usar la ruta tal como está
    BACKUP_DIR_ABS=$(pwd)/$BACKUP_DIR
fi

# Mostrar la ruta final que Docker usará para montar
echo "Ruta de backup: $BACKUP_DIR_ABS"

# Buscar los volúmenes reales que coincidan con los volúmenes esperados
for expected_volume in "${EXPECTED_VOLUMES[@]}"; do
    VOLUME_NAME=$(docker volume ls --format '{{.Name}}' | grep "$expected_volume")

    if [ -n "$VOLUME_NAME" ]; then
        echo "Respaldo del volumen: $VOLUME_NAME"
        
        # Verificar si el volumen existe en el sistema de Docker
        if docker volume inspect $VOLUME_NAME > /dev/null 2>&1; then
            # Crear el backup del volumen en un archivo tar.gz
            docker run --rm -v ${VOLUME_NAME}:/data -v ${BACKUP_DIR_ABS}:/backup busybox tar czf /backup/${VOLUME_NAME}.tar.gz -C /data .
            if [ $? -eq 0 ]; then
                echo "Volumen $VOLUME_NAME respaldado correctamente en $BACKUP_DIR"
            else
                echo "Error al respaldar el volumen $VOLUME_NAME"
            fi
        else
            echo "El volumen $VOLUME_NAME no existe en el demonio Docker."
        fi
    else
        echo "No se encontró ningún volumen que coincida con $expected_volume"
    fi
done

echo "Todos los volúmenes han sido respaldados en la carpeta $BACKUP_DIR"
