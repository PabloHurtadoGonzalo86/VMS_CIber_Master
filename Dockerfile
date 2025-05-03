FROM kalilinux/kali-rolling:arm64

# Actualizar e instalar herramientas necesarias
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
        xfce4 \
        xfce4-goodies \
        x11vnc \
        xvfb \
        dbus-x11 \
        python3 \
        python3-pip \
        python3-numpy \
        git \
        curl \
        wget \
        net-tools \
        nmap \
        metasploit-framework \
        tigervnc-standalone-server && \
    apt-get clean

# Configurar X11 y VNC con password explícito
RUN mkdir -p /root/.vnc /root/.config && \
    printf "kali12345\nkali12345\n\n" | vncpasswd && \
    chmod 600 /root/.vnc/passwd && \
    chmod -R 755 /root/.vnc

# Configurar noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC && \
    cd /opt/noVNC && \
    git clone https://github.com/novnc/websockify /opt/noVNC/utils/websockify && \
    ln -s vnc.html index.html

# Preparar xstartup
RUN echo '#!/bin/bash\nxrdb $HOME/.Xresources\nstartxfce4 &' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

COPY startup.sh /root/startup.sh
RUN chmod +x /root/startup.sh

EXPOSE 5901 6080

CMD ["/root/startup.sh"]
