#!/bin/bash
service ssh start
service apache2 start
service mysql start
service xinetd start
service vsftpd start
service smbd start
service bind9 start
service postfix start
# Añade aquí otros servicios que desees iniciar
# Mantén el contenedor en ejecución
tail -f /dev/null
