# Utilizar una imagen base de Ubuntu compatible con ARM64
FROM ubuntu:20.04

# Establecer variables de entorno para evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar herramientas necesarias
RUN apt-get update && \
    apt-get install -y \
        openssh-server \
        apache2 \
        mysql-server \
        net-tools \
        ftp \
        telnet \
        nmap \
        vim \
        xinetd \
        vsftpd \
        samba \
        bind9 \
        postfix \
        && apt-get clean

# Configurar SSH
RUN mkdir /var/run/sshd && \
    echo 'root:toor' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Configurar Apache
RUN echo '<html><body><h1>Metasploitable2 ARM64</h1></body></html>' > /var/www/html/index.html

# Configurar MySQL
RUN service mysql start && \
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'toor';" && \
    mysql -e "FLUSH PRIVILEGES;"

# Crear usuario vulnerable
RUN useradd -ms /bin/bash msfadmin && \
    echo 'msfadmin:msfadmin' | chpasswd

# Configurar servicios adicionales para simular vulnerabilidades
# (Opcional: Añade configuraciones específicas para cada servicio según tus necesidades)

# Exponer puertos comunes utilizados en Metasploitable2
EXPOSE 21 22 23 25 53 80 139 445 3306 5432 8009 8180

# Script para iniciar todos los servicios necesarios
COPY start_services.sh /start_services.sh
RUN chmod +x /start_services.sh

# Comando por defecto para iniciar servicios
CMD ["/bin/bash", "-c", "/start_services.sh && tail -f /dev/null"]
