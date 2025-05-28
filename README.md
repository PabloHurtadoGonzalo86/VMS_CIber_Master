# VMS Cyber Master - Cybersecurity Lab Environment

## Overview

This repository contains a complete cybersecurity lab environment designed for penetration testing, vulnerability assessment, and security training. The lab consists of two main components:

1. **Kali Linux Container** - A fully-featured attacker machine with GUI access
2. **Metasploitable2 Container** - A deliberately vulnerable target machine

The entire environment can be deployed using Docker or Kubernetes, providing a safe, isolated environment for cybersecurity education and testing.

## Architecture

```
┌─────────────────────┐    ┌─────────────────────┐
│   Kali Linux        │    │  Metasploitable2    │
│   (Attacker)        │    │   (Target)          │
│                     │    │                     │
│ ┌─────────────────┐ │    │ ┌─────────────────┐ │
│ │ XFCE Desktop    │ │    │ │ Vulnerable      │ │
│ │ via VNC/noVNC   │ │    │ │ Services:       │ │
│ │                 │ │    │ │ - SSH (22)      │ │
│ │ Security Tools: │ │    │ │ - HTTP (80)     │ │
│ │ - Metasploit    │ │    │ │ - MySQL (3306)  │ │
│ │ - Nmap          │ │    │ │ - FTP (21)      │ │
│ │ - Python3       │ │    │ │ - Samba (445)   │ │
│ └─────────────────┘ │    │ │ - And more...   │ │
│                     │    │ └─────────────────┘ │
│ Ports: 5901, 6080   │    │ Multiple Ports      │
└─────────────────────┘    └─────────────────────┘
```

## Repository Structure and File Explanations

### Root Directory Files

#### `Dockerfile`
**Purpose**: Creates the Kali Linux attacker container with GUI capabilities.

**Detailed Explanation**:
- **Base Image**: Uses `kalilinux/kali-rolling:latest` as the foundation
- **GUI Components**: Installs XFCE4 desktop environment for a full graphical interface
- **VNC Setup**: Configures both X11VNC and noVNC for remote desktop access
  - X11VNC: Traditional VNC server on port 5901
  - noVNC: Web-based VNC client accessible via browser on port 6080
- **Security Tools**: Installs comprehensive penetration testing tools:
  - `metasploit-framework`: Exploitation framework
  - `nmap`: Network scanning and discovery
  - `python3` and `python3-pip`: For custom scripts and tools
  - `curl`, `wget`: Network utilities
  - `net-tools`: Network configuration utilities
- **VNC Authentication**: Sets up VNC password (`kali12345`) for secure access
- **Display Configuration**: Configures virtual display server (Xvfb) for headless operation
- **Startup Script**: Copies and executes `startup.sh` to initialize all services

**Key Configuration Details**:
```dockerfile
# VNC password setup
printf "kali12345\nkali12345\n\n" | vncpasswd

# noVNC web interface setup
git clone https://github.com/novnc/noVNC.git /opt/noVNC
git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify

# Exposed ports for VNC access
EXPOSE 5901 6080
```

#### `startup.sh`
**Purpose**: Comprehensive service initialization script for the Kali Linux container.

**Detailed Explanation**:
This bash script orchestrates the startup of all necessary services in the correct order:

1. **Environment Setup**:
   - Sets `DISPLAY=:1` for X11 applications
   - Configures XDG runtime directories
   - Sets up X11 authority files

2. **Process Management**:
   - Kills any existing VNC or X11 processes to prevent conflicts
   - Cleans temporary X11 files

3. **Service Initialization Sequence**:
   - **Xvfb**: Starts virtual framebuffer for headless display (1920x1080x24)
   - **XFCE4**: Launches the desktop environment
   - **X11VNC**: Starts VNC server with authentication and optimization flags
   - **noVNC**: Launches web-based VNC proxy

4. **Error Handling**:
   - Includes process verification after each service start
   - Exits with error codes if critical services fail
   - Provides detailed logging to `/var/log/startup.log`

5. **Logging and Monitoring**:
   - All output is logged for debugging
   - Keeps container running with `tail -f /var/log/startup.log`

**Critical Service Parameters**:
```bash
# Xvfb configuration for optimal performance
Xvfb :1 -screen 0 1920x1080x24 &

# X11VNC with security and optimization
x11vnc -display :1 -forever -shared -rfbport 5901 -rfbauth /root/.vnc/passwd -noxdamage -noxfixes -noxrecord &

# noVNC proxy for web access
./utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6080 &
```

### DOckerFile-metaex Directory

#### `DOckerFile-metaex/Dockerfile`
**Purpose**: Creates a Metasploitable2-like vulnerable target container optimized for ARM64 architecture.

**Detailed Explanation**:
- **Base Image**: Uses `ubuntu:20.04` for broad compatibility and ARM64 support
- **Vulnerable Services Installation**: Installs multiple services commonly found in vulnerable systems:
  - `openssh-server`: SSH service with weak configuration
  - `apache2`: Web server with default configuration
  - `mysql-server`: Database server with default credentials
  - `vsftpd`: FTP server
  - `samba`: SMB/CIFS file sharing
  - `bind9`: DNS server
  - `postfix`: Mail server
  - `xinetd`: Internet superserver for legacy services

- **Security Misconfigurations** (Intentional vulnerabilities):
  - **SSH**: Enables root login and password authentication
  - **MySQL**: Sets weak root password (`toor`)
  - **System Users**: Creates vulnerable user `msfadmin:msfadmin`
  - **Apache**: Basic HTML page indicating it's a vulnerable target

- **Network Exposure**: Opens multiple ports commonly targeted in penetration testing:
  - `21` (FTP), `22` (SSH), `23` (Telnet), `25` (SMTP)
  - `53` (DNS), `80` (HTTP), `139/445` (SMB)
  - `3306` (MySQL), `5432` (PostgreSQL), `8009/8180` (Tomcat)

**Security Configuration Examples**:
```dockerfile
# Intentionally insecure SSH configuration
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Weak database credentials
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor';"

# Vulnerable system user
useradd -ms /bin/bash msfadmin && echo 'msfadmin:msfadmin' | chpasswd
```

#### `DOckerFile-metaex/start_services.sh`
**Purpose**: Service initialization script for the vulnerable target container.

**Detailed Explanation**:
This script starts all vulnerable services that attackers can target:

1. **Service Startup Sequence**:
   - `ssh`: Remote shell access
   - `apache2`: Web server
   - `mysql`: Database server
   - `xinetd`: Legacy service daemon
   - `vsftpd`: FTP server
   - `smbd`: Samba file sharing
   - `bind9`: DNS server
   - `postfix`: Mail server

2. **Container Persistence**: Uses `tail -f /dev/null` to keep container running

3. **Extensibility**: Includes comments for adding additional vulnerable services

### Kubernetes Deployment Files

#### `namespace_ciber.yaml`
**Purpose**: Creates an isolated Kubernetes namespace for the cybersecurity lab.

**Detailed Explanation**:
- **Namespace**: `cyber-lab` provides logical separation from other cluster resources
- **Isolation**: Ensures lab components don't interfere with other applications
- **Resource Management**: Allows for namespace-specific resource quotas and policies

#### `kali-deploy.yaml`
**Purpose**: Kubernetes deployment configuration for the Kali Linux attacker container.

**Detailed Explanation**:
- **Deployment Strategy**: Uses `Recreate` to ensure clean container restarts
- **Resource Allocation**: Configured for resource-intensive penetration testing:
  - **Memory**: 10-15 GB for large security tools and databases
  - **CPU**: 8-10 cores for parallel scanning and exploitation
  - **Storage**: 10-20 GB ephemeral storage for temporary files and logs
- **Security Context**: Runs as privileged container for advanced network operations
- **Container Image**: References pre-built image `ocholoko888/kali-custom-vnc:latest`
- **Environment Variables**: Sets DISPLAY for X11 applications

**Resource Configuration Rationale**:
```yaml
resources:
  limits:
    memory: "15Gi"      # Large tools like Metasploit require significant RAM
    cpu: "10"           # Parallel operations in penetration testing
    ephemeral-storage: "20Gi"  # Temporary files, logs, and downloaded exploits
```

#### `kali-service.yaml`
**Purpose**: Kubernetes service to expose Kali Linux container VNC ports.

**Detailed Explanation**:
- **Service Type**: NodePort for external cluster access
- **Port Mappings**:
  - `31000`: Web-based noVNC access (port 6080 internally)
  - `31001`: Traditional VNC access (port 5901 internally)
- **Access Method**: External users connect via `<cluster-ip>:31000` for web GUI

#### `meta-deploy.yaml`
**Purpose**: Kubernetes deployment for the Metasploitable2 vulnerable target.

**Detailed Explanation**:
- **Single Replica**: One instance sufficient for training purposes
- **Container Image**: Uses pre-built ARM64 compatible image `ocholoko888/metasploitable2-arm64:latest`
- **Exposed Ports**: Primary attack vectors (HTTP-80, SSH-22)
- **Resource Efficiency**: Minimal resources as it's a target, not a tool

#### `meta-service.yaml`
**Purpose**: Kubernetes service to expose Metasploitable2 vulnerable services.

**Detailed Explanation**:
- **NodePort Configuration**:
  - `31002`: HTTP web interface access
  - `31003`: SSH access for remote shell attacks
- **Target Accessibility**: Allows Kali container and external access to vulnerable services

## Prerequisites

### System Requirements
- **Docker**: Version 20.0+ with buildx support for multi-architecture builds
- **Kubernetes** (optional): Version 1.20+ for cluster deployment
- **Hardware**: Minimum 16GB RAM, 4 CPU cores (recommended: 32GB RAM, 8+ cores)
- **Network**: Isolated network environment (VM or dedicated hardware)

### Security Prerequisites
- **Isolated Environment**: Never deploy on production networks
- **Legal Authorization**: Ensure you have permission to conduct security testing
- **Educational Purpose**: Intended for learning and authorized testing only

## Installation and Usage

### Option 1: Docker Deployment (Recommended for beginners)

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/PabloHurtadoGonzalo86/VMS_CIber_Master.git
   cd VMS_CIber_Master
   ```

2. **Build Kali Linux Container**:
   ```bash
   docker build -t kali-custom-vnc .
   ```

3. **Build Metasploitable2 Container**:
   ```bash
   cd DOckerFile-metaex
   docker build -t metasploitable2-arm64 .
   cd ..
   ```

4. **Run the Lab Environment**:
   ```bash
   # Start Metasploitable2 (vulnerable target)
   docker run -d --name metasploitable \
     -p 8080:80 -p 2222:22 \
     metasploitable2-arm64

   # Start Kali Linux (attacker machine)
   docker run -d --name kali \
     -p 6080:6080 -p 5901:5901 \
     --privileged \
     kali-custom-vnc
   ```

5. **Access the Lab**:
   - **Kali GUI**: Open browser to `http://localhost:6080` (password: `kali12345`)
   - **Metasploitable Web**: Open browser to `http://localhost:8080`
   - **Metasploitable SSH**: `ssh msfadmin@localhost -p 2222` (password: `msfadmin`)

### Option 2: Kubernetes Deployment (For advanced users)

1. **Create Namespace**:
   ```bash
   kubectl apply -f namespace_ciber.yaml
   ```

2. **Deploy Services**:
   ```bash
   kubectl apply -f kali-deploy.yaml
   kubectl apply -f kali-service.yaml
   kubectl apply -f meta-deploy.yaml
   kubectl apply -f meta-service.yaml
   ```

3. **Access Services**:
   ```bash
   # Get cluster IP
   kubectl get nodes -o wide
   
   # Access via NodePort
   # Kali GUI: http://<cluster-ip>:31000
   # Metasploitable Web: http://<cluster-ip>:31002
   # Metasploitable SSH: ssh msfadmin@<cluster-ip> -p 31003
   ```

## Usage Examples

### Basic Penetration Testing Workflow

1. **Network Discovery**:
   ```bash
   # From Kali container
   nmap -sn 172.17.0.0/16  # Discover containers
   nmap -sS -sV <target-ip>  # Service scan
   ```

2. **Vulnerability Assessment**:
   ```bash
   # Using Metasploit
   msfconsole
   use auxiliary/scanner/http/dir_scanner
   set RHOSTS <target-ip>
   run
   ```

3. **Exploitation**:
   ```bash
   # Example SSH brute force
   use auxiliary/scanner/ssh/ssh_login
   set RHOSTS <target-ip>
   set USERNAME msfadmin
   set PASSWORD msfadmin
   run
   ```

## Security Considerations and Warnings

### ⚠️ CRITICAL SECURITY WARNINGS

1. **NEVER USE IN PRODUCTION**: This lab contains intentionally vulnerable systems
2. **ISOLATED NETWORKS ONLY**: Deploy only in isolated, non-production environments
3. **LEGAL COMPLIANCE**: Ensure compliance with local laws and regulations
4. **AUTHORIZED TESTING**: Only test systems you own or have explicit permission to test

### Recommended Security Measures

1. **Network Isolation**:
   - Use dedicated VLANs or isolated networks
   - Implement proper firewall rules
   - Monitor network traffic

2. **Container Security**:
   - Regularly update base images
   - Scan containers for known vulnerabilities
   - Use container runtime security tools

3. **Access Control**:
   - Change default passwords
   - Implement strong authentication
   - Limit user access to authorized personnel

## Troubleshooting

### Common Issues and Solutions

1. **VNC Connection Failed**:
   - Check if ports 5901 and 6080 are accessible
   - Verify container is running: `docker ps`
   - Check logs: `docker logs kali`

2. **Services Not Starting in Metasploitable**:
   - Check container logs: `docker logs metasploitable`
   - Verify service status inside container: `docker exec -it metasploitable service --status-all`

3. **Performance Issues**:
   - Increase allocated memory and CPU
   - Ensure sufficient disk space
   - Monitor resource usage: `docker stats`

4. **Kubernetes Deployment Issues**:
   - Check pod status: `kubectl get pods -n cyber-lab`
   - View logs: `kubectl logs -n cyber-lab <pod-name>`
   - Describe resources: `kubectl describe deployment -n cyber-lab`

## Educational Value

This lab environment provides hands-on experience with:

- **Network Security**: Understanding network protocols and vulnerabilities
- **System Administration**: Learning secure configuration practices
- **Penetration Testing**: Practical application of security testing methodologies
- **Incident Response**: Recognizing attack patterns and indicators
- **Tool Proficiency**: Mastering industry-standard security tools

## Contributing

To contribute to this project:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly in an isolated environment
5. Submit a pull request with detailed description

## License and Legal

This project is intended for educational and authorized security testing purposes only. Users are responsible for:

- Complying with applicable laws and regulations
- Obtaining proper authorization before testing
- Using the lab responsibly and ethically
- Not using the vulnerable components in production environments

## Support and Resources

- **Documentation**: This README and inline code comments
- **Community**: Security training forums and communities
- **Updates**: Monitor repository for security updates and improvements

Remember: With great power comes great responsibility. Use these tools ethically and legally.