#!/bin/bash

apt-get update
apt-get install proftpd

echo -e "
# Disabling root access
<Global>
        RootLogin off
        RequireValidShell off
</Global>

# Enabling anonymous access
<Anonymous /home/content>
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
