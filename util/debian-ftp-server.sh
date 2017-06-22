#!/bin/bash

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
<Anonymous /var/www/html/images>
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
