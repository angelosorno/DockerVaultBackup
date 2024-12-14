# **DockerVaultBackup** 🌊🚢
### **Automatic Docker Volume Backup and Restore System**

DockerVaultBackup es una herramienta sencilla y flexible para realizar **backups automáticos** y restauraciones de volúmenes definidos en archivos `compose.yml`. Este script es compatible tanto con **Linux** como con **Windows** (Git Bash) y se ajusta automáticamente al entorno para facilitar su uso en cualquier proyecto.

---

## **Características Principales** 🎯
- **Backup Automático de Volúmenes:** Respalda automáticamente todos los volúmenes definidos en `compose.yml` sin configuraciones adicionales.
- **Restauración Simplificada:** Restaura volúmenes desde backups comprimidos con un solo comando.
- **Compatibilidad Multiplataforma:** Funciona tanto en **Linux** como en **Windows**, ajustando rutas automáticamente para cada sistema.
- **Independencia del Directorio:** Los scripts pueden ejecutarse dentro o fuera de la carpeta `DockerVaultBackup`, garantizando flexibilidad.

---

## **Instalación y Configuración** ⚙️

### **1. Clonar el Repositorio**
Clona este repositorio en tu máquina local:

```bash
git clone https://github.com/angelosorno/DockerVaultBackup.git
```

### **2. Configuración del Entorno**
Asegúrate de que Docker y Docker Compose estén instalados y en funcionamiento:

```bash
# Verificar Docker
docker --version

# Verificar Docker Compose
docker compose --version
```

### **3. Uso del Script de Backup**
Este script detecta automáticamente los volúmenes definidos en tu archivo `compose.yml` y genera backups en la carpeta `./data/VolumesBackup`.

#### **Ejecutar el script de backup en Linux o Windows (Git Bash):**
```bash
./BackupVolumes.sh
```

---

## **Restauración de Volúmenes** 🔄
Para restaurar volúmenes previamente respaldados, puedes usar el siguiente script. Detecta automáticamente los backups disponibles en la carpeta `./data/VolumesBackup` y los restaura en los volúmenes correspondientes.

#### **Ejecutar el script de restauración en Linux o Windows:**
```bash
./RestoreVolumes.sh
```

---

## **Funcionamiento del Sistema** 📄

### **1. Backup de Volúmenes**
- **Detección Automática:** Extrae los nombres de los volúmenes definidos en el archivo `compose.yml` utilizando `docker compose config --volumes`.
- **Compatibilidad Multiplataforma:** Ajusta rutas automáticamente para Docker en **Windows** y **Linux**.
- **Compresión Automática:** Los backups se almacenan como archivos `.tar.gz` en la carpeta `./data/VolumesBackup`.

### **2. Restauración de Volúmenes**
- **Identificación de Backups:** Detecta automáticamente los backups disponibles en la carpeta de destino.
- **Volúmenes Nuevos:** Crea volúmenes automáticamente antes de restaurar.
- **Validación de Contenido:** Verifica el contenido de los volúmenes restaurados para asegurar la integridad.

---

## **Casos de Uso Comunes** 📌
1. **Realizar Backups Periódicos:** Programa la ejecución de `BackupVolumes.sh` como tarea cron en Linux o en el Programador de Tareas en Windows.
2. **Migración de Datos:** Utiliza los backups generados para transferir volúmenes entre diferentes máquinas o entornos Docker.
3. **Recuperación de Fallos:** Restaura volúmenes rápidamente desde backups en caso de errores o pérdidas de datos.

---

## **Contribuciones** 🤝
Si tienes ideas para mejorar DockerVaultBackup, ¡eres bienvenido a contribuir! Simplemente:
- Crea un **pull request** con tus cambios.
- Abre un **issue** para discutir mejoras o reportar errores.

---

## **Licencia** 📝
Este proyecto está bajo la [Licencia MIT](LICENSE).

---

## **Preguntas Frecuentes (FAQ)** ❓
1. **¿Qué tipos de volúmenes soporta DockerVaultBackup?**
   DockerVaultBackup soporta volúmenes locales definidos en archivos `compose.yml`. Los volúmenes externos no son respaldados automáticamente.

2. **¿Qué sucede si un volumen ya tiene un backup previo?**
   El script sobrescribirá automáticamente el archivo `.tar.gz` si ya existe un backup anterior.

3. **¿Puedo usarlo en un entorno de producción?**
   Sí, DockerVaultBackup es adecuado para entornos de producción, pero te recomendamos probar los scripts en un entorno de prueba antes de implementarlos en producción.

---

Con DockerVaultBackup, puedes mantener tus volúmenes seguros, realizar backups automáticos y restauraciones de manera sencilla. ¡Esperamos que esta herramienta te sea útil! Si tienes alguna pregunta o comentario, no dudes en abrir un issue.

---

## **Etiquetas para la Comunidad** 🏷️
- Docker
- Docker Compose
- Backup de Volúmenes
- Restauración de Volúmenes
- Multiplataforma (Linux y Windows)
