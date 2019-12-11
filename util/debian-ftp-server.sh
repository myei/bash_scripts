#!/bin/bash
# Basic script for installing and configuring a ftp server in Debian
# 
# Includes:
#  - Enabling anonymous access for given path
#  - Disabling root access
# 
# usage: debian-ftp-server.sh [PATH]
# 
#                                                                  @myei


# validations
[[ -z $1 ]] && echo "usage: debian-ftp-server.sh [PATH]" && exit 1
[[ ! -d $1 ]] && echo "error: path doesn't exists" && exit 2

if [[ ! -d /etc/proftpd ]]; then
        printf "[BAD]: Validando paquete proftpd \n"

        printf "Actualizando repositorios: \n"
        apt-get update
        printf "Instalando proftpd: \n"
        apt-get install proftpd -y
fi

printf "[OK]: Validando paquete proftpd \n"

printf "Habilitando usuario anonimo y deshabilitando acceso root: \n"

echo -e "
# Disabling root access
<Global>
        RootLogin off
        RequireValidShell off
</Global>

# Enabling anonymous access
<Anonymous $1>
        user ftp
        Group nogroup
                <Limit LOGIN>
                        AllowAll
                </Limit>
        UserAlias anonymous ftp
        DirFakeUser on ftp
        DirFakeGroup on ftp
        RequireValidShell off
        MaxClients 20
                <Directory *>
                        <Limit WRITE>
                                DenyAll
                        </Limit>
                </Directory>
</Anonymous>" >> /etc/proftpd/proftpd.conf

printf "Estado del servicio: \n"
/etc/init.d/proftpd restart
