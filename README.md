# VMS Cyber Master - Laboratorio de Ciberseguridad Educativo

## ¿Qué es este proyecto? (Explicación para principiantes)

Imagina que quieres aprender sobre ciberseguridad, pero no sabes por dónde empezar. Este proyecto es como un gimnasio virtual donde puedes practicar técnicas de seguridad informática de manera segura y legal.

**VMS Cyber Master** es un laboratorio virtual completo que simula un entorno real de ciberseguridad. Piensa en él como un videojuego educativo donde tienes:

1. **Una máquina atacante** (Kali Linux) - Es como tu "personaje principal" equipado con todas las herramientas de hacking ético
2. **Una máquina objetivo** (Metasploitable2) - Es como el "enemigo" que has creado intencionalmente para ser vulnerable y poder practicar sin dañar sistemas reales
3. **Un orquestador** (Kubernetes) - Es como el "motor del juego" que gestiona y controla todo el entorno

**⚠️ AVISO IMPORTANTE**: Este entorno está diseñado ÚNICAMENTE para fines educativos y pruebas de penetración autorizadas. Solo usa estas herramientas en entornos controlados con permiso explícito. El acceso no autorizado a sistemas informáticos es ilegal.

## ¿Qué tecnologías necesitas conocer? (Conceptos fundamentales)

Antes de comenzar, necesitas entender algunos conceptos básicos:

### 1. ¿Qué es un Contenedor (Docker)?

Un **contenedor** es como una caja virtual que contiene todo lo necesario para ejecutar una aplicación:
- El sistema operativo base
- Las herramientas y programas necesarios
- Las configuraciones específicas
- Las dependencias y librerías

**Docker** es la tecnología que crea y gestiona estos contenedores. Piensa en Docker como una fábrica que produce estas "cajas virtuales" de forma consistente y reproducible.

**Ventajas de usar contenedores:**
- **Portabilidad**: Funciona igual en cualquier máquina
- **Aislamiento**: No afecta al sistema principal
- **Reproducibilidad**: Siempre obtienes el mismo resultado
- **Eficiencia**: Usa menos recursos que una máquina virtual completa

### 2. ¿Qué es Kubernetes?

**Kubernetes** (también llamado K8s) es como un director de orquesta para contenedores. Si Docker crea las "cajas virtuales", Kubernetes las organiza, gestiona y coordina.

**¿Qué hace Kubernetes en este proyecto?**
- **Despliegue**: Lanza los contenedores en el momento adecuado
- **Escalado**: Puede crear más copias si es necesario
- **Networking**: Conecta los contenedores entre sí
- **Monitorización**: Vigila que todo funcione correctamente
- **Recuperación**: Reinicia contenedores si fallan

### 3. ¿Qué es VNC y noVNC?

**VNC (Virtual Network Computing)** es una tecnología que te permite controlar remotamente una computadora con interfaz gráfica, como si estuvieras sentado frente a ella.

**noVNC** es una versión web de VNC que funciona directamente en tu navegador web, sin necesidad de instalar software adicional.

**¿Por qué es importante?**
En este laboratorio, Kali Linux ejecuta un entorno de escritorio completo (XFCE4), pero está dentro de un contenedor sin pantalla física. VNC/noVNC nos permite "ver" y controlar este escritorio de forma remota.

### 4. ¿Qué es Kali Linux?

**Kali Linux** es una distribución de Linux especializada en ciberseguridad y hacking ético. Viene preinstalada con cientos de herramientas para:
- Análisis de vulnerabilidades
- Pruebas de penetración
- Análisis forense digital
- Ingeniería inversa

**¿Por qué usamos Kali Linux?**
Es la herramienta estándar en la industria para profesionales de ciberseguridad y es completamente gratuita.

### 5. ¿Qué es Metasploitable?

**Metasploitable** es una máquina virtual intencionalmente vulnerable creada con fines educativos. Es como un "muñeco de práctica" para hackers éticos.

**Características importantes:**
- Contiene vulnerabilidades conocidas y documentadas
- Incluye servicios mal configurados intencionalmente
- Usuarios con contraseñas débiles
- Servicios obsoletos con fallos de seguridad

## Arquitectura del Sistema (Cómo funciona todo junto)

### Visión General del Flujo de Trabajo

```
[Tu Computadora] 
       ↓ (navegador web)
[Kubernetes Cluster] 
       ↓
[Namespace: cyber-lab] 
    ↙         ↘
[Contenedor Kali]  [Contenedor Metasploitable]
(Máquina Atacante)    (Máquina Víctima)
       ↓                    ↓
[noVNC: puerto 31000]  [Servidor Web: puerto 31002]
[VNC: puerto 31001]    [SSH: puerto 31003]
```

### ¿Cómo interactúan los componentes?

1. **Tu navegador** se conecta al puerto 31000 para acceder a Kali Linux
2. **Kali Linux** ejecuta herramientas de hacking contra Metasploitable
3. **Metasploitable** responde a los ataques de manera predecible (está diseñado para ser vulnerable)
4. **Kubernetes** mantiene ambos contenedores funcionando y los conecta entre sí

## Estructura de Archivos Detallada (Qué hace cada archivo)

### Archivos del Directorio Principal

#### 1. `Dockerfile` - Constructor de la Máquina Atacante

**¿Qué es un Dockerfile?**
Un Dockerfile es como una receta de cocina que le dice a Docker exactamente cómo construir un contenedor. Cada línea es una instrucción específica.

**Análisis línea por línea:**

```dockerfile
FROM kalilinux/kali-rolling:latest
```
- **FROM**: Esta línea dice "empezar con la imagen oficial de Kali Linux más reciente"
- Es como decir "toma una instalación limpia de Kali Linux como base"

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
- **RUN**: Ejecuta comandos durante la construcción del contenedor
- **apt-get update**: Actualiza la lista de paquetes disponibles
- **DEBIAN_FRONTEND=noninteractive**: Evita que el sistema pregunte cosas durante la instalación
- **xfce4**: Instala el entorno de escritorio XFCE4 (la interfaz gráfica)
- **x11vnc**: Instala el servidor VNC para acceso remoto
- **xvfb**: Instala un servidor X virtual (pantalla virtual)
- **metasploit-framework**: Instala el framework de explotación más usado en el mundo

```dockerfile
RUN mkdir -p /root/.vnc /root/.config && \
    printf "kali12345\nkali12345\n\n" | vncpasswd && \
    chmod 600 /root/.vnc/passwd
```
- **mkdir -p**: Crea directorios necesarios para VNC
- **printf "kali12345\nkali12345\n\n" | vncpasswd**: Establece la contraseña de VNC automáticamente
- **chmod 600**: Establece permisos de seguridad para el archivo de contraseña

```dockerfile
COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh
```
- **COPY**: Copia el script de inicio desde tu computadora al contenedor
- **chmod +x**: Hace que el script sea ejecutable

```dockerfile
EXPOSE 5901 6080
```
- **EXPOSE**: Informa que el contenedor usará estos puertos
- **5901**: Puerto para VNC directo
- **6080**: Puerto para noVNC (acceso web)

```dockerfile
CMD ["/root/startup.sh"]
```
- **CMD**: Define qué comando ejecutar cuando se inicie el contenedor

#### 2. `startup.sh` - El Cerebro del Sistema de Kali

Este script es fundamental porque orquesta todo el proceso de inicio del entorno gráfico dentro del contenedor.

**¿Por qué necesitamos este script?**
Los contenedores Docker están diseñados para ejecutar una sola aplicación, pero nosotros necesitamos ejecutar múltiples servicios (servidor X, VNC, noVNC, entorno de escritorio). Este script los coordina todos.

**Análisis detallado:**

```bash
#!/bin/bash
set -e  # Detener en caso de error
exec 1> >(tee -a /var/log/startup.log) 2>&1  # Logging
```
- **set -e**: Si cualquier comando falla, el script se detiene inmediatamente
- **exec 1> >(tee -a /var/log/startup.log) 2>&1**: Registra toda la salida en un archivo de log

```bash
export DISPLAY=:1
export HOME=/root
export XDG_RUNTIME_DIR=/tmp/xdg
export XAUTHORITY=/root/.Xauthority
```
- **DISPLAY=:1**: Le dice a las aplicaciones gráficas que usen la pantalla virtual número 1
- Estas variables de entorno son necesarias para que el sistema gráfico funcione correctamente

```bash
mkdir -p /tmp/xdg /tmp/.X11-unix
chmod 700 /tmp/xdg
chmod 1777 /tmp/.X11-unix
```
- Crea directorios temporales necesarios para el sistema X11
- Establece permisos específicos para la seguridad

```bash
pkill -9 -f Xvfb || true
pkill -9 -f x11vnc || true
pkill -9 -f xfce4 || true
```
- **pkill -9**: Mata cualquier proceso previo que pueda estar ejecutándose
- **|| true**: Evita errores si no hay procesos que matar

```bash
Xvfb :1 -screen 0 1920x1080x24 &
```
- **Xvfb**: Inicia el servidor X virtual (pantalla virtual)
- **:1**: Usa el display número 1
- **-screen 0 1920x1080x24**: Crea una pantalla virtual de 1920x1080 píxeles con 24 bits de color
- **&**: Ejecuta en segundo plano

```bash
startxfce4 &
```
- Inicia el entorno de escritorio XFCE4 en segundo plano

```bash
x11vnc -display :1 -forever -shared -rfbport 5901 -rfbauth /root/.vnc/passwd -noxdamage -noxfixes -noxrecord &
```
- **x11vnc**: Inicia el servidor VNC
- **-display :1**: Se conecta al display virtual número 1
- **-forever**: Mantiene el servidor VNC ejecutándose indefinidamente
- **-shared**: Permite múltiples conexiones simultáneas
- **-rfbport 5901**: Usa el puerto 5901 para VNC
- **-rfbauth**: Usa el archivo de contraseña que creamos antes

```bash
cd /opt/noVNC
./utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6080 &
```
- Inicia noVNC, que actúa como un proxy web para VNC
- **--vnc 0.0.0.0:5901**: Se conecta al servidor VNC local
- **--listen 0.0.0.0:6080**: Escucha en el puerto 6080 para conexiones web

### Directorio `DOckerFile-metaex/` - La Máquina Víctima

#### 3. `DOckerFile-metaex/Dockerfile` - Constructor de la Máquina Vulnerable

Este Dockerfile crea una máquina intencionalmente insegura para practicar.

**Filosofía de diseño:**
A diferencia de Kali (que debe ser seguro y robusto), Metasploitable debe ser vulnerable y fácil de explotar.

**Análisis detallado:**

```dockerfile
FROM ubuntu:20.04
```
- Usa Ubuntu 20.04 como base (más antiguo = más vulnerable)

```dockerfile
ENV DEBIAN_FRONTEND=noninteractive
```
- Evita preguntas durante la instalación automatizada

```dockerfile
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        apache2 \
        mysql-server \
        ...
```
- **openssh-server**: Servidor SSH para acceso remoto
- **apache2**: Servidor web Apache
- **mysql-server**: Base de datos MySQL
- **vsftpd**: Servidor FTP vulnerable
- **samba**: Servicios de archivos compartidos
- **bind9**: Servidor DNS
- **telnet**: Protocolo inseguro de acceso remoto
- **xinetd**: Súper-servidor que gestiona otros servicios

```dockerfile
RUN mkdir /var/run/sshd && \
    echo 'root:toor' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
```
- **mkdir /var/run/sshd**: Crea directorio necesario para SSH
- **echo 'root:toor' | chpasswd**: Establece una contraseña DÉBIL para root
- **sed -i 's/...': Permite login directo como root via SSH (INSEGURO)

```dockerfile
RUN useradd -ms /bin/bash msfadmin && \
    echo 'msfadmin:msfadmin' | chpasswd
```
- Crea un usuario con usuario y contraseña idénticos (INSEGURO)

```dockerfile
EXPOSE 21 22 23 25 53 80 139 445 3306 5432 8009 8180
```
- Expone múltiples puertos para diferentes servicios vulnerables

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