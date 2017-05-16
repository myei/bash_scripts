#! /bin/bash
##########################################################
#
#									Creado por: Manuel Gil
#
#	Este script genera el backup (.sql) de una serie de bases
# 	de datos pasadas como argumentos al script. Después de 
# 	generado el .sql se aplica el restore en una base de datos
# 	espejo, ejemplo de uso:
# 	
# 	mongo-backup [ dbname1 dbname2 ... dbnameN ]
# 
# 	dbnameX: nombre de las bases de datos a respaldar
#
##########################################################

DIR="/home/mgil/testing-||/"
PORT="27050"
HOST="demo.lorebi.com"

if [[ $# -eq 0 ]]; then
	printf "error: Argumentos inválidos \n\n"

	printf 'mongo-backup usage: mongo-backup [ OPTIONS ] DB-LIST: [ "dbname1 dbname2 ... dbnameN" ] \n\n'

    printf "    OPTIONS: \n\n"
    printf "    -p, --port: Puerto, por defecto 27017 \n"
    printf "    -h, --host: Nombre de las bases de datos a respaldar \n"
    printf "    -d, --db:   DB-LIST -> Nombre de las bases de datos a respaldar, deben ir dentro de comillas (\") y separados por espacios \n"

	exit
fi

# O B T E N I E N D O   A R G U M E N T O S
while [[ $# -gt 1 ]]
do
key=$1

case $key in
    -p|--port)
    PORT=$2
    shift
    ;;
    -h|--host)
    HOST=$2
    shift
    ;;
    -d|--db)
    DB=$2
    shift
    ;;
    *)
    ;;
    esac
    shift
done

mkdir -p $DIR

for db in ${DB[*]}; do

	printf "Respaldando ${db} en ${DIR}${db}_`date +%d-%m-%Y` \n"
	
	# REALIZO EL BACKUP A LA BASE DE DATOS
	mongodump --host $HOST --port $PORT --db $db --user superman --authenticationDatabase "admin" --out $DIR$db'_'`date +%d-%m-%Y`

	printf "Restaurando respaldo en ${db}_backup \n"

	# EJECUTO EL RESTORE CREADO ANTERIORMENTE EN LA BASE DE DATOS DE RESPALDO
	mongorestore --host $HOST --port $PORT --db $db"_backup" --user superman --authenticationDatabase "admin" $DIR$db'_'`date +%d-%m-%Y`"/$db"

done

exit