#!/bin/bash

set -e  # Detener en caso de error
exec 1> >(tee -a /var/log/startup.log) 2>&1  # Logging

# Configuración de entorno
export DISPLAY=:1
export HOME=/root
export XDG_RUNTIME_DIR=/tmp/xdg
export XAUTHORITY=/root/.Xauthority

echo "Iniciando configuración..."

# Crear directorios necesarios
mkdir -p /tmp/xdg /tmp/.X11-unix
chmod 700 /tmp/xdg
chmod 1777 /tmp/.X11-unix

echo "Limpiando procesos previos..."
# Matar procesos previos
pkill -9 -f Xvfb || true
pkill -9 -f x11vnc || true
pkill -9 -f xfce4 || true
rm -rf /tmp/.X* /tmp/.x*

echo "Iniciando Xvfb..."
# Iniciar Xvfb
Xvfb :1 -screen 0 1920x1080x24 &
sleep 3

# Verificar Xvfb
if ! pgrep Xvfb > /dev/null; then
    echo "Error: Xvfb failed to start"
    exit 1
fi

echo "Iniciando XFCE4..."
# Iniciar XFCE4
startxfce4 &
sleep 3

echo "Iniciando X11VNC..."
# Iniciar X11VNC con autenticación
x11vnc -display :1 -forever -shared -rfbport 5901 -rfbauth /root/.vnc/passwd -noxdamage -noxfixes -noxrecord &
sleep 3

# Verificar X11VNC
if ! pgrep x11vnc > /dev/null; then
    echo "Error: x11vnc failed to start"
    exit 1
fi

echo "Iniciando noVNC..."
# Iniciar noVNC
cd /opt/noVNC
./utils/novnc_proxy --vnc 0.0.0.0:5901 --listen 0.0.0.0:6080 &

echo "Todos los servicios iniciados correctamente"

# Mantener el contenedor corriendo y mostrar logs
tail -f /var/log/startup.log
