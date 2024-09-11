#!/bin/bash

# Verificar si el demonio de Docker está activo
if ! docker info > /dev/null 2>&1; then
    echo "Docker no está corriendo. Por favor, inicia Docker antes de ejecutar este script."
    exit 1
fi

# Ruta a la carpeta donde están los backups
BACKUP_DIR="./data/volumes_backup"

# Verificar si la carpeta de backups existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo "No se encontró la carpeta $BACKUP_DIR con los volúmenes respaldados."
    exit 1
fi

# Detectar si estamos en un sistema Windows o Linux
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    # Convertir ruta para Docker en Windows al formato /d/... en lugar de C:/...
    BACKUP_DIR_ABS="/$(pwd | sed 's|^/c/|c:/|' | sed 's|^/d/|d:/|')/$BACKUP_DIR"
    BACKUP_DIR_ABS=$(echo "$BACKUP_DIR_ABS" | sed 's|//|/|g')  # Eliminar dobles barras si aparecen
else
    # Si es Linux/Unix, usar la ruta tal como está
    BACKUP_DIR_ABS=$(pwd)/$BACKUP_DIR
fi

# Mostrar la ruta final para verificación
echo "Ruta de backup: $BACKUP_DIR_ABS"

# Nombres de los volúmenes a restaurar (basado en los nombres de los archivos tar.gz)
VOLUMES=$(ls $BACKUP_DIR/*.tar.gz | xargs -n 1 basename | sed 's/.tar.gz//')

# Restaurar cada volumen
for volume in $VOLUMES; do
    echo "Restaurando el volumen: $volume"
    
    # Crear el volumen en Docker
    docker volume create $volume
    
    # Verificar si la creación fue exitosa
    if [ $? -ne 0 ]; then
        echo "Error al crear el volumen $volume"
        exit 1
    fi
    
    # Descomprimir el backup en el volumen correspondiente
    docker run --rm -v ${volume}:/data -v "$BACKUP_DIR_ABS":/backup busybox sh -c "tar xzf /backup/${volume}.tar.gz -C /data"
    
    if [ $? -eq 0 ]; then
        # Verificar el contenido del volumen restaurado
        echo "Validando el contenido del volumen restaurado $volume:"
        docker run --rm -v ${volume}:/data busybox sh -c "du -sh /data && ls -la /data"
        echo "Volumen $volume restaurado correctamente."
    else
        echo "Error al restaurar el volumen $volume"
        exit 1
    fi
done

echo "Todos los volúmenes han sido restaurados correctamente."
