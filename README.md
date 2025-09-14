# VMS Cyber Master - Educational Cybersecurity Laboratory

## What is this project? (Beginner's Guide)

Imagine you want to learn cybersecurity but don't know where to start. This project is like a virtual gym where you can safely and legally practice computer security techniques.

**VMS Cyber Master** is a complete virtual laboratory that simulates a real cybersecurity environment. Think of it as an educational video game where you have:

1. **An attacking machine** (Kali Linux) - Like your "main character" equipped with all ethical hacking tools
2. **A target machine** (Metasploitable2) - Like the "enemy" you've intentionally created to be vulnerable so you can practice without damaging real systems
3. **An orchestrator** (Kubernetes) - Like the "game engine" that manages and controls the entire environment

**⚠️ IMPORTANT WARNING**: This environment is designed ONLY for educational purposes and authorized penetration testing. Only use these tools in controlled environments with explicit permission. Unauthorized access to computer systems is illegal.

## What technologies do you need to know? (Fundamental concepts)

Before starting, you need to understand some basic concepts:

### 1. What is a Container (Docker)?

A **container** is like a virtual box that contains everything needed to run an application:
- The base operating system
- Necessary tools and programs
- Specific configurations
- Dependencies and libraries

**Docker** is the technology that creates and manages these containers. Think of Docker as a factory that produces these "virtual boxes" consistently and reproducibly.

**Advantages of using containers:**
- **Portability**: Works the same on any machine
- **Isolation**: Doesn't affect the main system
- **Reproducibility**: Always get the same result
- **Efficiency**: Uses fewer resources than a complete virtual machine

### 2. What is Kubernetes?

**Kubernetes** (also called K8s) is like an orchestra conductor for containers. If Docker creates the "virtual boxes", Kubernetes organizes, manages, and coordinates them.

**What does Kubernetes do in this project?**
- **Deployment**: Launches containers at the right time
- **Scaling**: Can create more copies if needed
- **Networking**: Connects containers to each other
- **Monitoring**: Watches that everything works correctly
- **Recovery**: Restarts containers if they fail

### 3. What is VNC and noVNC?

**VNC (Virtual Network Computing)** is a technology that allows you to remotely control a computer with a graphical interface, as if you were sitting in front of it.

**noVNC** is a web version of VNC that works directly in your web browser, without needing to install additional software.

**Why is this important?**
In this laboratory, Kali Linux runs a complete desktop environment (XFCE4), but it's inside a container without a physical display. VNC/noVNC allows us to "see" and control this desktop remotely.

### 4. What is Kali Linux?

**Kali Linux** is a Linux distribution specialized in cybersecurity and ethical hacking. It comes pre-installed with hundreds of tools for:
- Vulnerability analysis
- Penetration testing
- Digital forensics
- Reverse engineering

**Why do we use Kali Linux?**
It's the industry standard tool for cybersecurity professionals and is completely free.

### 5. What is Metasploitable?

**Metasploitable** is an intentionally vulnerable virtual machine created for educational purposes. It's like a "practice dummy" for ethical hackers.

**Important characteristics:**
- Contains known and documented vulnerabilities
- Includes intentionally misconfigured services
- Users with weak passwords
- Outdated services with security flaws

## System Architecture (How everything works together)

### Workflow Overview

```
[Your Computer] 
       ↓ (web browser)
[Kubernetes Cluster] 
       ↓
[Namespace: cyber-lab] 
    ↙         ↘
[Kali Container]  [Metasploitable Container]
(Attacking Machine)    (Victim Machine)
       ↓                    ↓
[noVNC: port 31000]  [Web Server: port 31002]
[VNC: port 31001]    [SSH: port 31003]
```

### How do the components interact?

1. **Your browser** connects to port 31000 to access Kali Linux
2. **Kali Linux** runs hacking tools against Metasploitable
3. **Metasploitable** responds to attacks predictably (it's designed to be vulnerable)
4. **Kubernetes** keeps both containers running and connects them to each other

## Detailed File Structure (What each file does)

### Main Directory Files

#### 1. `Dockerfile` - Attacking Machine Builder

**What is a Dockerfile?**
A Dockerfile is like a cooking recipe that tells Docker exactly how to build a container. Each line is a specific instruction.

**Line-by-line analysis:**

```dockerfile
FROM kalilinux/kali-rolling:latest
```
- **FROM**: This line says "start with the latest official Kali Linux image"
- It's like saying "take a clean installation of Kali Linux as the base"

```dockerfile
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xfce4 \
        xfce4-goodies \
        x11vnc \
        xvfb \
        dbus-x11 \
        python3 \
        ...
```
- **RUN**: Executes commands during container build
- **apt-get update**: Updates the list of available packages
- **DEBIAN_FRONTEND=noninteractive**: Prevents the system from asking questions during installation
- **xfce4**: Installs the XFCE4 desktop environment (the graphical interface)
- **x11vnc**: Installs the VNC server for remote access
- **xvfb**: Installs a virtual X server (virtual display)
- **metasploit-framework**: Installs the most used exploitation framework in the world

```dockerfile
RUN mkdir -p /root/.vnc /root/.config && \
    printf "kali12345\nkali12345\n\n" | vncpasswd && \
    chmod 600 /root/.vnc/passwd
```
- **mkdir -p**: Creates necessary directories for VNC
- **printf "kali12345\nkali12345\n\n" | vncpasswd**: Sets the VNC password automatically
- **chmod 600**: Sets security permissions for the password file

```dockerfile
COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh
```
- **COPY**: Copies the startup script from your computer to the container
- **chmod +x**: Makes the script executable

```dockerfile
EXPOSE 5901 6080
```
- **EXPOSE**: Informs that the container will use these ports
- **5901**: Port for direct VNC
- **6080**: Port for noVNC (web access)

```dockerfile
CMD ["/root/startup.sh"]
```
- **CMD**: Defines what command to execute when the container starts

#### 2. `startup.sh` - The Kali System Brain

This script is fundamental because it orchestrates the entire startup process of the graphical environment inside the container.

**Why do we need this script?**
Docker containers are designed to run a single application, but we need to run multiple services (X server, VNC, noVNC, desktop environment). This script coordinates them all.

**Detailed analysis:**

```bash
#!/bin/bash
set -e  # Stop on error
exec 1> >(tee -a /var/log/startup.log) 2>&1  # Logging
```
- **set -e**: If any command fails, the script stops immediately
- **exec 1> >(tee -a /var/log/startup.log) 2>&1**: Logs all output to a log file

```bash
export DISPLAY=:1
export HOME=/root
export XDG_RUNTIME_DIR=/tmp/xdg
export XAUTHORITY=/root/.Xauthority
```
- **DISPLAY=:1**: Tells graphical applications to use virtual display number 1
- These environment variables are necessary for the graphical system to work correctly

```bash
mkdir -p /tmp/xdg /tmp/.X11-unix
chmod 700 /tmp/xdg
chmod 1777 /tmp/.X11-unix
```
- Creates temporary directories needed for the X11 system
- Sets specific permissions for security

```bash
pkill -9 -f Xvfb || true
pkill -9 -f x11vnc || true
pkill -9 -f xfce4 || true
```
- **pkill -9**: Kills any previous processes that might be running
- **|| true**: Prevents errors if there are no processes to kill

```bash
Xvfb :1 -screen 0 1920x1080x24 &
```
- **Xvfb**: Starts the virtual X server (virtual display)
- **:1**: Uses display number 1
- **-screen 0 1920x1080x24**: Creates a virtual screen of 1920x1080 pixels with 24-bit color
- **&**: Runs in the background

```bash
startxfce4 &
```
- Starts the XFCE4 desktop environment in the background

```bash
x11vnc -display :1 -forever -shared -rfbport 5901 -rfbauth /root/.vnc/passwd -noxdamage -noxfixes -noxrecord &
```
- **x11vnc**: Starts the VNC server
- **-display :1**: Connects to virtual display number 1
- **-forever**: Keeps the VNC server running indefinitely
- **-shared**: Allows multiple simultaneous connections
- **-rfbport 5901**: Uses port 5901 for VNC
- **-rfbauth**: Uses the password file we created earlier

```bash
cd /opt/noVNC
./utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6080 &
```
- Starts noVNC, which acts as a web proxy for VNC
- **--vnc 0.0.0.0:5901**: Connects to the local VNC server
- **--listen 0.0.0.0:6080**: Listens on port 6080 for web connections

### Directory `DOckerFile-metaex/` - The Victim Machine

#### 3. `DOckerFile-metaex/Dockerfile` - Vulnerable Machine Builder

This Dockerfile creates an intentionally insecure machine for practice.

**Design philosophy:**
Unlike Kali (which must be secure and robust), Metasploitable must be vulnerable and easy to exploit.

**Detailed analysis:**

```dockerfile
FROM ubuntu:20.04
```
- Uses Ubuntu 20.04 as base (older = more vulnerable)

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```
- Prevents questions during automated installation

```dockerfile
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        apache2 \
        mysql-server \
        ...
```
- **openssh-server**: SSH server for remote access
- **apache2**: Apache web server
- **mysql-server**: MySQL database
- **vsftpd**: Vulnerable FTP server
- **samba**: File sharing services
- **bind9**: DNS server
- **telnet**: Insecure remote access protocol
- **xinetd**: Super-server that manages other services

```dockerfile
RUN mkdir /var/run/sshd && \
    echo 'root:toor' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```
- **mkdir /var/run/sshd**: Creates necessary directory for SSH
- **echo 'root:toor' | chpasswd**: Sets a WEAK password for root
- **sed -i 's/...'**: Allows direct root login via SSH (INSECURE)

```dockerfile
RUN useradd -ms /bin/bash msfadmin && \
    echo 'msfadmin:msfadmin' | chpasswd
```
- Creates a user with identical username and password (INSECURE)

```dockerfile
EXPOSE 21 22 23 25 53 80 139 445 3306 5432 8009 8180
```
- Exposes multiple ports for different vulnerable services

#### 4. `DOckerFile-metaex/start_services.sh` - Iniciador de Servicios Vulnerables

```bash
#!/bin/bash
service ssh start      # Inicia servidor SSH
service apache2 start  # Inicia servidor web
service mysql start    # Inicia base de datos
service xinetd start   # Inicia súper-servidor
service vsftpd start   # Inicia servidor FTP
service smbd start     # Inicia servicios Samba
service bind9 start    # Inicia servidor DNS
service postfix start  # Inicia servidor de correo
```

Cada servicio representa una superficie de ataque diferente para practicar.

### Archivos de Kubernetes - La Orquestación

#### 5. `namespace_ciber.yaml` - Creador del Espacio de Trabajo

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cyber-lab
```

**¿Qué es un Namespace?**
Un namespace en Kubernetes es como una habitación virtual dentro del cluster. Separa recursos y evita conflictos con otras aplicaciones.

**¿Por qué necesitamos esto?**
- **Aislamiento**: Nuestro laboratorio no interfiere con otras aplicaciones
- **Organización**: Todos los recursos relacionados están agrupados
- **Seguridad**: Podemos aplicar políticas específicas a este espacio

#### 6. `kali-deploy.yaml` - Configuración de Despliegue para Kali

```yaml
apiVersion: apps/v1
kind: Deployment
```
- **Deployment**: Tipo de recurso que gestiona pods (contenedores en ejecución)

```yaml
metadata:
  name: kali
  namespace: cyber-lab
```
- **name**: Identificador único para este despliegue
- **namespace**: Especifica en qué namespace crear este recurso

```yaml
spec:
  strategy:
    type: Recreate
  replicas: 1
```
- **strategy: Recreate**: Si necesita actualizar, mata el pod viejo antes de crear uno nuevo
- **replicas: 1**: Solo mantener una instancia corriendo

```yaml
selector:
  matchLabels:
    app: kali
template:
  metadata:
    labels:
      app: kali
```
- **selector/labels**: Sistema de etiquetado que conecta el Deployment con los pods

```yaml
containers:
- name: kali
  image: ocholoko888/kali-custom-vnc:latest
  ports:
  - containerPort: 6080
    name: novnc
  - containerPort: 5901
    name: vnc
```
- **image**: Especifica qué imagen de contenedor usar
- **ports**: Define qué puertos expone el contenedor

```yaml
securityContext:
  privileged: true
```
- **privileged: true**: Da acceso especial al contenedor (necesario para herramientas de hacking)

```yaml
resources:
  limits:
    memory: "15Gi"
    cpu: "10"
    ephemeral-storage: "20Gi"
  requests:
    memory: "10Gi"
    cpu: "8"
    ephemeral-storage: "10Gi"
```
- **limits**: Máximo de recursos que puede usar
- **requests**: Recursos mínimos garantizados
- Kali necesita muchos recursos porque ejecuta herramientas pesadas

#### 7. `kali-service.yaml` - Configuración de Red para Kali

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kali-service
  namespace: cyber-lab
spec:
  type: NodePort
```
- **Service**: Recurso que expone pods a la red
- **NodePort**: Tipo de servicio que abre puertos en todos los nodos del cluster

```yaml
selector:
  app: kali
ports:
- protocol: TCP
  port: 6080
  targetPort: 6080
  nodePort: 31000
  name: novnc
```
- **selector**: Conecta este servicio con los pods etiquetados como "kali"
- **port**: Puerto interno del servicio
- **targetPort**: Puerto del contenedor
- **nodePort**: Puerto externo accesible desde fuera del cluster

#### 8. `meta-deploy.yaml` y `meta-service.yaml` - Configuración para Metasploitable

Similar a los archivos de Kali, pero con configuraciones específicas para la máquina vulnerable:
- Menos recursos (la máquina víctima no necesita tanto poder)
- Puertos diferentes (80 para web, 22 para SSH)
- Sin privilegios especiales (no necesita acceso a bajo nivel)

## Cómo Todo Funciona Junto (El Flujo Completo)

### Fase 1: Construcción de Imágenes (Build Time)

1. **Docker lee el Dockerfile de Kali**:
   - Descarga la imagen base de Kali Linux
   - Instala XFCE4, VNC, noVNC y herramientas de hacking
   - Configura contraseñas y permisos
   - Copia el script de inicio
   - Crea la imagen final

2. **Docker lee el Dockerfile de Metasploitable**:
   - Descarga Ubuntu 20.04
   - Instala servicios vulnerables
   - Configura usuarios inseguros
   - Copia scripts de inicio de servicios
   - Crea la imagen vulnerable

### Fase 2: Despliegue en Kubernetes (Deploy Time)

1. **Kubernetes lee namespace_ciber.yaml**:
   - Crea el namespace "cyber-lab"
   - Establece el espacio de trabajo aislado

2. **Kubernetes lee kali-deploy.yaml**:
   - Programa la creación de un pod Kali
   - Asigna recursos (15GB RAM, 10 CPUs, etc.)
   - Descarga la imagen de Kali si no existe localmente

3. **Kubernetes lee kali-service.yaml**:
   - Crea un servicio que expone Kali al exterior
   - Mapea puertos internos a externos (6080→31000, 5901→31001)

4. **Kubernetes lee meta-deploy.yaml y meta-service.yaml**:
   - Hace lo mismo para Metasploitable
   - Expone puertos web (80→31002) y SSH (22→31003)

### Fase 3: Inicio de Contenedores (Runtime)

1. **El contenedor Kali inicia**:
   - Ejecuta `/root/startup.sh`
   - El script limpia procesos previos
   - Inicia Xvfb (pantalla virtual)
   - Inicia XFCE4 (entorno de escritorio)
   - Inicia x11vnc (servidor VNC)
   - Inicia noVNC (proxy web)

2. **El contenedor Metasploitable inicia**:
   - Ejecuta `/start_services.sh`
   - Inicia SSH, Apache, MySQL, FTP, etc.
   - Todos los servicios quedan disponibles

### Fase 4: Acceso y Uso (User Time)

1. **Usuario accede a Kali via web**:
   - Navega a `http://cluster-ip:31000`
   - noVNC muestra el escritorio XFCE4
   - Usuario puede usar herramientas gráficas

2. **Usuario realiza reconocimiento**:
   - Abre terminal en Kali
   - Ejecuta `nmap` para encontrar Metasploitable
   - Identifica servicios vulnerables

3. **Usuario practica ataques**:
   - Usa Metasploit para explotar vulnerabilidades
   - Accede via SSH con credenciales débiles
   - Explora el servidor web vulnerable

## Requisitos del Sistema (¿Qué necesitas?)

### Requisitos de Hardware

**¿Por qué necesitamos tantos recursos?**

- **Memoria (RAM)**: 
  - Kali Linux con entorno gráfico: 4-8GB
  - Metasploitable con múltiples servicios: 2-4GB
  - Kubernetes overhead: 2-4GB
  - **Total mínimo**: 16GB (recomendado: 32GB)

- **CPU**:
  - Herramientas de hacking son intensivas en CPU
  - Múltiples contenedores ejecutándose simultáneamente
  - **Mínimo**: 4 cores (recomendado: 8+ cores)

- **Almacenamiento**:
  - Imágenes de Docker: 10-15GB
  - Logs y datos temporales: 10-20GB
  - Espacio para herramientas adicionales: 20GB+
  - **Mínimo**: 50GB (recomendado: 100GB)

### Software Requerido

#### Docker
**¿Qué es?** Motor de contenedores que ejecuta las aplicaciones aisladas.
**¿Cómo instalarlo?** Depende de tu sistema operativo:
- **Ubuntu/Debian**: `sudo apt install docker.io`
- **CentOS/RHEL**: `sudo yum install docker`
- **Windows/Mac**: Docker Desktop

#### Kubernetes
**Opciones para principiantes:**

1. **minikube** (Recomendado para aprender):
   - Kubernetes completo en una sola máquina
   - Fácil de instalar y usar
   - Perfecto para desarrollo y aprendizaje

2. **kind** (Kubernetes in Docker):
   - Crea clusters usando contenedores Docker
   - Muy ligero y rápido
   - Ideal para pruebas

3. **k3s** (Kubernetes ligero):
   - Versión simplificada de Kubernetes
   - Menor uso de recursos
   - Bueno para sistemas con recursos limitados

#### kubectl
**¿Qué es?** Herramienta de línea de comandos para interactuar con Kubernetes.
**Instalación**: Se incluye con minikube, o se puede descargar por separado.

## Guía de Instalación Paso a Paso (Para Principiantes)

### Paso 1: Preparar el Sistema Base

#### En Ubuntu/Debian:
```bash
# Actualizar el sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Añadir tu usuario al grupo docker
sudo usermod -aG docker $USER
# Cerrar sesión y volver a entrar

# Instalar minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Instalar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl
```

### Paso 2: Iniciar el Cluster de Kubernetes

```bash
# Iniciar minikube con recursos adecuados
minikube start --memory=16384 --cpus=8 --disk-size=50g

# Verificar que funciona
kubectl cluster-info
kubectl get nodes
```

**¿Qué está pasando?**
- minikube crea una máquina virtual con Kubernetes
- Asigna 16GB RAM, 8 CPUs y 50GB de disco
- kubectl se conecta automáticamente a este cluster

### Paso 3: Descargar el Proyecto

```bash
# Clonar el repositorio
git clone https://github.com/PabloHurtadoGonzalo86/VMS_CIber_Master.git

# Entrar al directorio
cd VMS_CIber_Master

# Listar los archivos para verificar
ls -la
```

### Paso 4: Desplegar el Laboratorio

```bash
# Crear el namespace
kubectl apply -f namespace_ciber.yaml

# Verificar que se creó
kubectl get namespaces

# Desplegar Kali Linux
kubectl apply -f kali-deploy.yaml
kubectl apply -f kali-service.yaml

# Desplegar Metasploitable
kubectl apply -f meta-deploy.yaml
kubectl apply -f meta-service.yaml
```

### Paso 5: Verificar el Despliegue

```bash
# Ver el estado de los pods
kubectl get pods -n cyber-lab

# Esperar hasta que ambos pods estén "Running"
# Esto puede tomar varios minutos la primera vez

# Ver los servicios
kubectl get services -n cyber-lab

# Obtener las URLs de acceso
minikube service list -n cyber-lab
```

### Paso 6: Acceder al Laboratorio

1. **Obtener la IP del cluster**:
   ```bash
   minikube ip
   ```

2. **Acceder a Kali Linux**:
   - Abrir navegador web
   - Navegar a `http://IP_DE_MINIKUBE:31000`
   - Hacer clic en "Connect"
   - ¡Ya tienes acceso a Kali Linux!

3. **Verificar Metasploitable**:
   - En el navegador: `http://IP_DE_MINIKUBE:31002`
   - Deberías ver la página web de Metasploitable

## Ejemplos de Uso Educativo

### Ejercicio 1: Reconocimiento Básico (Nivel Principiante)

**Objetivo**: Aprender a descubrir sistemas en la red

**Pasos detallados**:

1. **Accede a Kali Linux**:
   - Abre `http://IP_MINIKUBE:31000` en tu navegador
   - Verás el escritorio XFCE4

2. **Abre una terminal**:
   - Clic en el icono de terminal en la barra inferior
   - O usa el menú: Aplicaciones → Terminal

3. **Descubre la red**:
   ```bash
   # Primero, encuentra tu propia IP
   ip addr show
   
   # Busca todas las IPs en tu rango de red
   nmap -sn 10.244.0.0/16
   ```
   
   **¿Qué está pasando?**
   - `ip addr show` muestra todas las interfaces de red
   - `nmap -sn` hace un "ping sweep" para encontrar máquinas activas
   - El rango 10.244.0.0/16 es típico de Kubernetes

4. **Identifica Metasploitable**:
   ```bash
   # Encuentra cuál IP es Metasploitable
   nmap -sV IP_DE_METASPLOITABLE
   ```
   
   **¿Qué verás?**
   - Puerto 22 (SSH) abierto
   - Puerto 80 (HTTP) abierto
   - Posiblemente muchos otros puertos

### Ejercicio 2: Análisis de Servicios Web (Nivel Intermedio)

**Objetivo**: Explorar aplicaciones web vulnerables

1. **Accede al sitio web**:
   - En Kali, abre Firefox
   - Navega a `http://IP_METASPLOITABLE`

2. **Enumera directorios**:
   ```bash
   # Busca directorios ocultos
   dirb http://IP_METASPLOITABLE
   
   # O usa gobuster (más moderno)
   gobuster dir -u http://IP_METASPLOITABLE -w /usr/share/wordlists/dirb/common.txt
   ```

3. **Escanea vulnerabilidades web**:
   ```bash
   # Usa nikto para análisis de vulnerabilidades
   nikto -h http://IP_METASPLOITABLE
   ```

### Ejercicio 3: Ataque SSH (Nivel Intermedio)

**Objetivo**: Practicar ataques de fuerza bruta

⚠️ **IMPORTANTE**: Solo hazlo en este laboratorio controlado

1. **Ataque manual**:
   ```bash
   # Intenta login con credenciales comunes
   ssh msfadmin@IP_METASPLOITABLE
   # Contraseña: msfadmin
   ```

2. **Ataque automatizado con Hydra**:
   ```bash
   # Crea un archivo con usuarios comunes
   echo "admin\nroot\nmsfadmin\nuser" > usuarios.txt
   
   # Crea un archivo con contraseñas comunes
   echo "admin\npassword\n123456\nmsfadmin\ntoor" > passwords.txt
   
   # Ejecuta el ataque
   hydra -L usuarios.txt -P passwords.txt ssh://IP_METASPLOITABLE
   ```

3. **Usando Metasploit**:
   ```bash
   # Abre Metasploit
   msfconsole
   
   # Dentro de Metasploit:
   use auxiliary/scanner/ssh/ssh_login
   set RHOSTS IP_METASPLOITABLE
   set USER_FILE usuarios.txt
   set PASS_FILE passwords.txt
   run
   ```

### Ejercicio 4: Explotación con Metasploit (Nivel Avanzado)

**Objetivo**: Usar exploits reales contra vulnerabilidades

1. **Buscar exploits disponibles**:
   ```bash
   msfconsole
   search type:exploit platform:linux
   ```

2. **Usar un exploit específico**:
   ```bash
   # Ejemplo con vulnerabilidad VSFTPd
   use exploit/unix/ftp/vsftpd_234_backdoor
   set RHOSTS IP_METASPLOITABLE
   exploit
   ```

3. **Post-explotación**:
   ```bash
   # Si obtienes una shell:
   whoami
   uname -a
   cat /etc/passwd
   ```

## Solución de Problemas Comunes

### Problema 1: Los pods no inician

**Síntomas**:
```bash
kubectl get pods -n cyber-lab
# Estado: Pending o CrashLoopBackOff
```

**Diagnóstico**:
```bash
# Ver eventos del pod
kubectl describe pod NOMBRE_POD -n cyber-lab

# Ver logs del pod
kubectl logs NOMBRE_POD -n cyber-lab
```

**Soluciones comunes**:
- **Recursos insuficientes**: Aumentar memoria/CPU de minikube
- **Imágenes no encontradas**: Verificar conectividad a internet
- **Permisos**: Verificar que Docker funciona sin sudo

### Problema 2: No puedo acceder via web

**Síntomas**: Navegador no carga `http://IP:31000`

**Diagnóstico**:
```bash
# Verificar servicios
kubectl get services -n cyber-lab

# Verificar que minikube expone los puertos
minikube service kali-service -n cyber-lab --url
```

**Soluciones**:
- Usar la URL exacta que da minikube
- Verificar firewall local
- Probar con port-forward: `kubectl port-forward -n cyber-lab svc/kali-service 8080:6080`

### Problema 3: VNC no funciona

**Síntomas**: Pantalla negra o conexión rechazada

**Diagnóstico**:
```bash
# Ejecutar comandos dentro del pod Kali
kubectl exec -it NOMBRE_POD_KALI -n cyber-lab -- bash

# Dentro del pod:
ps aux | grep vnc
ps aux | grep Xvfb
cat /var/log/startup.log
```

**Soluciones**:
- Reiniciar el pod: `kubectl delete pod NOMBRE_POD_KALI -n cyber-lab`
- Verificar logs de inicio
- Comprobar que los puertos están libres

### Problema 4: Metasploitable no responde

**Síntomas**: Servicios no accesibles desde Kali

**Diagnóstico**:
```bash
# Desde Kali, probar conectividad
kubectl exec -it NOMBRE_POD_KALI -n cyber-lab -- bash
ping IP_METASPLOITABLE
nmap IP_METASPLOITABLE
```

**Soluciones**:
- Verificar que ambos pods están en el mismo namespace
- Comprobar políticas de red de Kubernetes
- Reiniciar el pod Metasploitable

## Consideraciones de Seguridad y Éticas

### ¿Por qué es seguro este laboratorio?

1. **Aislamiento por contenedores**: Todo está encapsulado en contenedores
2. **Aislamiento por namespace**: Separado del resto del sistema
3. **Red privada**: Solo accesible desde tu máquina local
4. **Máquinas virtuales**: minikube corre en una VM separada

### Reglas éticas fundamentales

1. **Solo para educación**: Nunca uses estas técnicas contra sistemas reales sin autorización
2. **Entorno controlado**: Mantén siempre el laboratorio aislado
3. **Responsabilidad**: Si encuentras vulnerabilidades reales, repórtalas responsablemente
4. **Legalidad**: Asegúrate de cumplir las leyes locales sobre ciberseguridad

### Mejores prácticas

1. **Actualizaciones regulares**: Mantén las imágenes actualizadas
2. **Logs y monitorización**: Revisa logs regularmente para aprender
3. **Limpieza**: Elimina el laboratorio cuando no lo uses
4. **Documentación**: Documenta tus experimentos y hallazgos

## Limpieza y Mantenimiento

### Eliminar el laboratorio completamente

```bash
# Eliminar todos los recursos
kubectl delete namespace cyber-lab

# Detener minikube
minikube stop

# Eliminar minikube (opcional)
minikube delete
```

### Reiniciar solo los pods

```bash
# Reiniciar Kali
kubectl delete pod -l app=kali -n cyber-lab

# Reiniciar Metasploitable
kubectl delete pod -l app=metasploitable -n cyber-lab
```

### Actualizar imágenes

```bash
# Forzar descarga de nuevas imágenes
kubectl rollout restart deployment/kali -n cyber-lab
kubectl rollout restart deployment/metasploitable -n cyber-lab
```

---

**Recuerda**: El conocimiento adquirido en este laboratorio debe usarse para mejorar la seguridad, no para causar daño. Siempre practica principios de hacking ético y respeta los límites legales.

**¡Bienvenido al fascinante mundo de la ciberseguridad!** 🛡️💻