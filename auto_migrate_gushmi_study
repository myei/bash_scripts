#! /bin/bash

# REALIZO EL BACKUP A LA BASE DE DATOS DE PRODUCCION
mysqldump -u study --password="study" --routines --opt gushmi_study > backup.sql

# EJECUTO EL RESTORE CREADO ANTERIORMENTE EN LA BASE DE DATOS DE RESPALDO
mysql -u study --password="study" gushmi_study_backup < backup.sql

exit

