
# **DockerVaultBackup** 🌊🚢
### **Automatic Docker Volume Backup System**

DockerVaultBackup es una herramienta sencilla y flexible para realizar backups automáticos de los volúmenes definidos en archivos `docker-compose.yml`. Este script es compatible tanto con **Linux** como con **Windows** (Git Bash) y puede ser utilizado en cualquier proyecto que utilice Docker Compose.

## **Casos de Uso** 🎯
- **Backup de volúmenes automáticos**: Automatiza la creación de backups de volúmenes de Docker definidos en `docker-compose.yml` sin la necesidad de configuraciones adicionales.
- **Compatibilidad multi-plataforma**: Funciona sin problemas en **Linux** y **Windows** (Git Bash), ajustando automáticamente las rutas de los volúmenes para Docker en ambos sistemas.
- **Fácil de integrar en cualquier proyecto**: Solo necesita un archivo `compose.yml` para funcionar y puede ser utilizado en cualquier proyecto que haga uso de Docker Compose.

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
docker-compose --version
```

### **3. Uso del Script**

Este script detecta automáticamente los volúmenes definidos en tu archivo `compose.yml` y genera backups en la carpeta `./data/volumes_backup`.

#### **Ejecutar el script en Linux:**

```bash
./BackupVolumesDocker.sh
```

#### **Ejecutar el script en Windows (Git Bash):**

```bash
./BackupVolumesDocker.sh
```

## **Restauración de Volúmenes** 🔄

Para restaurar volúmenes previamente respaldados, puedes usar el siguiente script que restaura automáticamente los volúmenes desde los backups generados.

#### **Ejecutar el script de restauración en Linux o Windows:**

```bash
./RestoreVolumes.sh
```

Este script detecta automáticamente los backups disponibles en la carpeta `./data/volumes_backup` y los restaura en los volúmenes correspondientes.

---

## **Descripción del Script** 📄

- **Detección automática de volúmenes**: Extrae los nombres de los volúmenes definidos en el archivo `compose.yml` utilizando `docker-compose config --volumes`.
- **Compatibilidad con prefijos**: Detecta y maneja correctamente los prefijos de volúmenes que Docker añade automáticamente para evitar conflictos.
- **Backup automático en `.tar.gz`**: Los backups se comprimen y almacenan en la carpeta `./data/volumes_backup`, listos para ser restaurados en caso de que sea necesario.

## **Contribuciones** 🤝

Si tienes ideas para mejorar DockerVaultBackup, ¡eres bienvenido a contribuir! Simplemente crea un **pull request** o abre un **issue** para discutir mejoras.

## **Licencia** 📝
Este proyecto está bajo la [Licencia MIT](LICENSE).

---

## **Preguntas Frecuentes (FAQ)** ❓

1. **¿Qué tipos de volúmenes soporta DockerVaultBackup?**
   DockerVaultBackup soporta volúmenes locales definidos en archivos `compose.yml`. Los volúmenes externos no son respaldados automáticamente.

2. **¿Qué sucede si un volumen ya tiene un backup previo?**
   El script sobrescribirá automáticamente el archivo `.tar.gz` si ya existe un backup anterior.

---

Con DockerVaultBackup, puedes mantener tus volúmenes seguros y realizar backups automáticos con facilidad. ¡Esperamos que esta herramienta te sea útil! Si tienes alguna pregunta o comentario, no dudes en abrir un issue.

---

## **Etiquetas para la comunidad** 🏷️
- Docker
- Docker Compose
- Backup de volúmenes
- Backups automáticos
- Docker en Linux y Windows
