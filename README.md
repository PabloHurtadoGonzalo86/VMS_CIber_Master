# VMS Cyber Master - Cybersecurity Lab Environment

## Project Overview

This repository provides a complete cybersecurity laboratory environment designed for hands-on penetration testing education and practice. The lab consists of two main components deployed as containerized services in a Kubernetes environment:

- **Kali Linux** - A fully-featured penetration testing distribution serving as the attacker machine
- **Metasploitable2** - A deliberately vulnerable Ubuntu-based target system for practice

The environment is specifically designed for cybersecurity students and professionals to practice ethical hacking techniques, vulnerability assessment, and penetration testing methodologies in a controlled, isolated environment.

## Architecture Explanation

### Container Architecture
The lab utilizes a microservices architecture with two distinct containers:

1. **Kali Linux Container**: 
   - Based on `kalilinux/kali-rolling:latest`
   - Includes XFCE4 desktop environment
   - Provides VNC and noVNC access for remote desktop functionality
   - Pre-installed with penetration testing tools including Metasploit Framework

2. **Metasploitable2 Container**:
   - Based on Ubuntu 20.04 with ARM64 compatibility
   - Configured with multiple vulnerable services
   - Simulates a real-world target environment with security flaws

### Network Architecture
```
┌─────────────────┐    ┌─────────────────┐
│   Kali Linux    │    │  Metasploitable2│
│  (Attacker)     │────│    (Target)     │
│                 │    │                 │
│ Port 6080: noVNC│    │ Port 80: HTTP   │
│ Port 5901: VNC  │    │ Port 22: SSH    │
└─────────────────┘    │ Port 21: FTP    │
                       │ Port 23: Telnet │
                       │ Port 3306: MySQL│
                       └─────────────────┘
```

### Kubernetes Deployment
- **Namespace**: `cyber-lab` - Isolated namespace for lab resources
- **Services**: NodePort services for external access
- **Deployments**: Managed container lifecycle and scaling
- **Resource Management**: Configured resource limits and requests

## File Structure with Descriptions

### Core Container Files

#### `Dockerfile`
The main Dockerfile for building the Kali Linux container:
- **Base Image**: `kalilinux/kali-rolling:latest`
- **Desktop Environment**: XFCE4 with VNC server configuration
- **Key Features**:
  - X11VNC server for remote desktop access
  - noVNC web-based VNC client
  - Pre-configured VNC password authentication
  - Metasploit Framework and penetration testing tools
- **Exposed Ports**: 5901 (VNC), 6080 (noVNC web interface)

#### `startup.sh`
Initialization script for the Kali Linux container:
- **Purpose**: Starts all necessary services for the desktop environment
- **Key Functions**:
  - Configures X11 display environment
  - Starts Xvfb virtual framebuffer
  - Launches XFCE4 desktop environment
  - Initializes X11VNC server with authentication
  - Starts noVNC web proxy
- **Logging**: Comprehensive startup logging to `/var/log/startup.log`

#### `DOckerFile-metaex/Dockerfile`
Dockerfile for building the Metasploitable2 ARM64-compatible target:
- **Base Image**: `ubuntu:20.04`
- **Vulnerable Services**:
  - SSH server with weak authentication
  - Apache web server
  - MySQL database with default credentials
  - FTP, Telnet, Samba services
  - DNS (bind9) and mail (postfix) services
- **Security Misconfigurations**: Intentionally insecure settings for educational purposes
- **Default Credentials**: Multiple weak user accounts (root:toor, msfadmin:msfadmin)

#### `DOckerFile-metaex/start_services.sh`
Service initialization script for Metasploitable2:
- **Purpose**: Starts all vulnerable services in the target container
- **Services Managed**:
  - SSH, Apache, MySQL
  - FTP (vsftpd), Samba (smbd)
  - DNS (bind9), Mail (postfix)
  - xinetd super-server

### Kubernetes Configuration Files

#### `namespace_ciber.yaml`
- **Purpose**: Creates isolated `cyber-lab` namespace
- **Benefits**: Resource isolation and management organization

#### `kali-deploy.yaml`
Kubernetes deployment configuration for Kali Linux:
- **Strategy**: Recreate deployment for clean container restarts
- **Resources**: High-performance allocation (10-15Gi RAM, 8-10 CPU cores)
- **Security**: Privileged container access for penetration testing tools
- **Image**: `ocholoko888/kali-custom-vnc:latest`

#### `kali-service.yaml`
Service configuration for Kali Linux external access:
- **Type**: NodePort service for external cluster access
- **Port Mappings**:
  - `31000` → `6080` (noVNC web interface)
  - `31001` → `5901` (VNC direct connection)

#### `meta-deploy.yaml`
Kubernetes deployment for Metasploitable2:
- **Purpose**: Deploys vulnerable target environment
- **Image**: `ocholoko888/metasploitable2-arm64:latest`
- **Ports**: HTTP (80) and SSH (22) services exposed

#### `meta-service.yaml`
Service configuration for Metasploitable2 access:
- **Port Mappings**:
  - `31002` → `80` (HTTP web services)
  - `31003` → `22` (SSH access)

## Prerequisites and Setup

### System Requirements
- **Kubernetes Cluster**: Version 1.20+ with ARM64 support
- **Node Resources**: Minimum 16GB RAM, 12 CPU cores per node
- **Storage**: 30GB+ available ephemeral storage
- **Network**: NodePort access capability (ports 31000-31003)

### Required Tools
```bash
# Kubernetes CLI
kubectl version --client

# Docker (for local builds)
docker --version

# Access to Docker registry
docker login
```

### Cluster Configuration
Ensure your Kubernetes cluster supports:
- Privileged containers (for Kali penetration testing tools)
- NodePort services (for external access)
- Resource limits and requests enforcement

## Usage Examples

### 1. Deploy the Complete Lab Environment

```bash
# Create the cyber-lab namespace
kubectl apply -f namespace_ciber.yaml

# Deploy Metasploitable2 target
kubectl apply -f meta-deploy.yaml
kubectl apply -f meta-service.yaml

# Deploy Kali Linux attacker
kubectl apply -f kali-deploy.yaml
kubectl apply -f kali-service.yaml
```

### 2. Verify Deployment Status

```bash
# Check namespace resources
kubectl get all -n cyber-lab

# Monitor pod startup
kubectl logs -f deployment/kali -n cyber-lab
kubectl logs -f deployment/metasploitable -n cyber-lab
```

### 3. Access the Lab Environment

#### Kali Linux Access (Attacker Machine)
```bash
# Get cluster node IP
kubectl get nodes -o wide

# Access via web browser (noVNC)
# http://<NODE_IP>:31000
# Password: kali12345

# Direct VNC connection
# <NODE_IP>:31001
```

#### Metasploitable2 Access (Target Machine)
```bash
# Get target IP within cluster
kubectl get svc metasploitable-service -n cyber-lab

# Web interface access
# http://<NODE_IP>:31002

# SSH access
ssh msfadmin@<NODE_IP> -p 31003
# Password: msfadmin
```

### 4. Example Penetration Testing Workflow

1. **Access Kali Linux**: Open browser to `http://<NODE_IP>:31000`
2. **Network Discovery**: Use nmap to scan Metasploitable2
   ```bash
   nmap -sV <METASPLOITABLE_IP>
   ```
3. **Vulnerability Assessment**: Identify vulnerable services
4. **Exploitation**: Use Metasploit to exploit identified vulnerabilities
   ```bash
   msfconsole
   use exploit/multi/samba/usermap_script
   set RHOSTS <METASPLOITABLE_IP>
   exploit
   ```

### 5. Clean Up Environment

```bash
# Remove all lab resources
kubectl delete namespace cyber-lab
```

## Security Considerations

⚠️ **Important Security Notes**:

- This lab contains **intentionally vulnerable systems** - use only in isolated environments
- **Never deploy** on production networks or internet-accessible infrastructure
- **Default passwords** are used throughout - change them in production scenarios
- The Kali container runs with **privileged access** - restrict cluster access appropriately
- Monitor resource usage as the lab requires significant compute resources

## Troubleshooting

### Common Issues

1. **Kali VNC Connection Failed**
   ```bash
   kubectl logs deployment/kali -n cyber-lab
   # Check startup.sh execution logs
   ```

2. **Metasploitable Services Not Starting**
   ```bash
   kubectl exec -it deployment/metasploitable -n cyber-lab -- bash
   systemctl status <service-name>
   ```

3. **NodePort Access Issues**
   ```bash
   kubectl get svc -n cyber-lab
   # Verify NodePort assignments and firewall rules
   ```

## Contributing

When contributing to this cybersecurity lab:

1. Ensure all changes maintain the educational focus
2. Test deployments in isolated environments
3. Update documentation for any configuration changes
4. Follow security best practices for container configurations

## License

This project is intended for educational purposes in cybersecurity training. Please ensure compliance with local laws and institutional policies when using penetration testing tools.