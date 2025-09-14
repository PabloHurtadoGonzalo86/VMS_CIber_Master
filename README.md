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

#### 4. `DOckerFile-metaex/start_services.sh` - Vulnerable Services Launcher

```bash
#!/bin/bash
service ssh start      # Start SSH server
service apache2 start  # Start web server
service mysql start    # Start database
service xinetd start   # Start super-server
service vsftpd start   # Start FTP server
service smbd start     # Start Samba services
service bind9 start    # Start DNS server
service postfix start  # Start mail server
```

Each service represents a different attack surface for practice.

### Kubernetes Files - The Orchestration

#### 5. `namespace_ciber.yaml` - Workspace Creator

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cyber-lab
```

**What is a Namespace?**
A namespace in Kubernetes is like a virtual room inside the cluster. It separates resources and avoids conflicts with other applications.

**Why do we need this?**
- **Isolation**: Our laboratory doesn't interfere with other applications
- **Organization**: All related resources are grouped together
- **Security**: We can apply specific policies to this space

#### 6. `kali-deploy.yaml` - Kali Deployment Configuration

```yaml
apiVersion: apps/v1
kind: Deployment
```
- **Deployment**: Type of resource that manages pods (running containers)

```yaml
metadata:
  name: kali
  namespace: cyber-lab
```
- **name**: Unique identifier for this deployment
- **namespace**: Specifies in which namespace to create this resource

```yaml
spec:
  strategy:
    type: Recreate
  replicas: 1
```
- **strategy: Recreate**: If it needs to update, kill the old pod before creating a new one
- **replicas: 1**: Only keep one instance running

```yaml
selector:
  matchLabels:
    app: kali
template:
  metadata:
    labels:
      app: kali
```
- **selector/labels**: Labeling system that connects the Deployment with the pods

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
- **image**: Specifies which container image to use
- **ports**: Defines which ports the container exposes

```yaml
securityContext:
  privileged: true
```
- **privileged: true**: Gives special access to the container (necessary for hacking tools)

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
- **limits**: Maximum resources it can use
- **requests**: Minimum guaranteed resources
- Kali needs many resources because it runs heavy tools

#### 7. `kali-service.yaml` - Kali Network Configuration

```yaml
apiVersion: v1
kind: Service
metadata:
  name: kali-service
  namespace: cyber-lab
spec:
  type: NodePort
```
- **Service**: Resource that exposes pods to the network
- **NodePort**: Type of service that opens ports on all cluster nodes

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
- **selector**: Connects this service with pods labeled as "kali"
- **port**: Internal service port
- **targetPort**: Container port
- **nodePort**: External port accessible from outside the cluster

#### 8. `meta-deploy.yaml` and `meta-service.yaml` - Metasploitable Configuration

Similar to the Kali files, but with specific configurations for the vulnerable machine:
- Fewer resources (the victim machine doesn't need as much power)
- Different ports (80 for web, 22 for SSH)
- No special privileges (doesn't need low-level access)

## How Everything Works Together (The Complete Flow)

### Phase 1: Image Building (Build Time)

1. **Docker reads the Kali Dockerfile**:
   - Downloads the Kali Linux base image
   - Installs XFCE4, VNC, noVNC and hacking tools
   - Configures passwords and permissions
   - Copies the startup script
   - Creates the final image

2. **Docker reads the Metasploitable Dockerfile**:
   - Downloads Ubuntu 20.04
   - Installs vulnerable services
   - Configures insecure users
   - Copies service startup scripts
   - Creates the vulnerable image

### Phase 2: Kubernetes Deployment (Deploy Time)

1. **Kubernetes reads namespace_ciber.yaml**:
   - Creates the "cyber-lab" namespace
   - Establishes the isolated workspace

2. **Kubernetes reads kali-deploy.yaml**:
   - Schedules the creation of a Kali pod
   - Allocates resources (15GB RAM, 10 CPUs, etc.)
   - Downloads the Kali image if it doesn't exist locally

3. **Kubernetes reads kali-service.yaml**:
   - Creates a service that exposes Kali externally
   - Maps internal ports to external ones (6080→31000, 5901→31001)

4. **Kubernetes reads meta-deploy.yaml and meta-service.yaml**:
   - Does the same for Metasploitable
   - Exposes web ports (80→31002) and SSH (22→31003)

### Phase 3: Container Startup (Runtime)

1. **The Kali container starts**:
   - Executes `/root/startup.sh`
   - The script cleans previous processes
   - Starts Xvfb (virtual display)
   - Starts XFCE4 (desktop environment)
   - Starts x11vnc (VNC server)
   - Starts noVNC (web proxy)

2. **The Metasploitable container starts**:
   - Executes `/start_services.sh`
   - Starts SSH, Apache, MySQL, FTP, etc.
   - All services become available

### Phase 4: Access and Usage (User Time)

1. **User accesses Kali via web**:
   - Navigates to `http://cluster-ip:31000`
   - noVNC displays the XFCE4 desktop
   - User can use graphical tools

2. **User performs reconnaissance**:
   - Opens terminal in Kali
   - Runs `nmap` to find Metasploitable
   - Identifies vulnerable services

3. **User practices attacks**:
   - Uses Metasploit to exploit vulnerabilities
   - Accesses via SSH with weak credentials
   - Explores the vulnerable web server

## System Requirements (What do you need?)

### Hardware Requirements

**Why do we need so many resources?**

- **Memory (RAM)**: 
  - Kali Linux with graphical environment: 4-8GB
  - Metasploitable with multiple services: 2-4GB
  - Kubernetes overhead: 2-4GB
  - **Minimum total**: 16GB (recommended: 32GB)

- **CPU**:
  - Hacking tools are CPU-intensive
  - Multiple containers running simultaneously
  - **Minimum**: 4 cores (recommended: 8+ cores)

- **Storage**:
  - Docker images: 10-15GB
  - Logs and temporary data: 10-20GB
  - Space for additional tools: 20GB+
  - **Minimum**: 50GB (recommended: 100GB)

### Required Software

#### Docker
**What is it?** Container engine that runs isolated applications.
**How to install?** Depends on your operating system:
- **Ubuntu/Debian**: `sudo apt install docker.io`
- **CentOS/RHEL**: `sudo yum install docker`
- **Windows/Mac**: Docker Desktop

#### Kubernetes
**Options for beginners:**

1. **minikube** (Recommended for learning):
   - Complete Kubernetes on a single machine
   - Easy to install and use
   - Perfect for development and learning

2. **kind** (Kubernetes in Docker):
   - Creates clusters using Docker containers
   - Very lightweight and fast
   - Ideal for testing

3. **k3s** (Lightweight Kubernetes):
   - Simplified version of Kubernetes
   - Lower resource usage
   - Good for resource-limited systems

#### kubectl
**What is it?** Command-line tool for interacting with Kubernetes.
**Installation**: Included with minikube, or can be downloaded separately.

## Step-by-Step Installation Guide (For Beginners)

### Step 1: Prepare the Base System

#### On Ubuntu/Debian:
```bash
# Update the system
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and log back in

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl
```

### Step 2: Start the Kubernetes Cluster

```bash
# Start minikube with adequate resources
minikube start --memory=16384 --cpus=8 --disk-size=50g

# Verify it works
kubectl cluster-info
kubectl get nodes
```

**What's happening?**
- minikube creates a virtual machine with Kubernetes
- Allocates 16GB RAM, 8 CPUs and 50GB disk
- kubectl automatically connects to this cluster

### Step 3: Download the Project

```bash
# Clone the repository
git clone https://github.com/PabloHurtadoGonzalo86/VMS_CIber_Master.git

# Enter the directory
cd VMS_CIber_Master

# List files to verify
ls -la
```

### Step 4: Deploy the Laboratory

```bash
# Create the namespace
kubectl apply -f namespace_ciber.yaml

# Verify it was created
kubectl get namespaces

# Deploy Kali Linux
kubectl apply -f kali-deploy.yaml
kubectl apply -f kali-service.yaml

# Deploy Metasploitable
kubectl apply -f meta-deploy.yaml
kubectl apply -f meta-service.yaml
```

### Step 5: Verify the Deployment

```bash
# See the status of the pods
kubectl get pods -n cyber-lab

# Wait until both pods are "Running"
# This can take several minutes the first time

# See the services
kubectl get services -n cyber-lab

# Get access URLs
minikube service list -n cyber-lab
```

### Step 6: Access the Laboratory

1. **Get the cluster IP**:
   ```bash
   minikube ip
   ```

2. **Access Kali Linux**:
   - Open web browser
   - Navigate to `http://MINIKUBE_IP:31000`
   - Click "Connect"
   - You now have access to Kali Linux!

3. **Verify Metasploitable**:
   - In browser: `http://MINIKUBE_IP:31002`
   - You should see the Metasploitable web page

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