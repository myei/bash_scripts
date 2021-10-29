#!/bin/bash

##############################################################
#
# 										Creado por: Manuel Gil
#
# Este script permite:
#
# - Este script permite el autodeploy de múltiples 
#   aplicaciones manejadas por GIT especificadas como argumentos
# 
# - Se permiten rutas relativas o absolutas
# 
# - Permite auto instalación (-i --install)
# 	
#
# 														v2.3.1
##############################################################

# C O N F I G U R A T I O N
SCRIPT_NAME='auto-deployment'
PROJECT_USER='apache'
PROJECT_GROUP='apache'
PHP_PATH=php
COMPOSER_PATH=/usr/local/bin/composer
COMPOSER_LOCATION='composer.json'
ENTITY_PREFIX='Entity/'
LOG_FILE=~/.${SCRIPT_NAME}-$(date +'%d-%m-%Y').log
MAX_LOG_FILES=5
MAIL_DEST=
SERVER_NAME=`hostname`

# C O L O R S
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
PURPLE='\e[95m'
WHITE='\e[97m'
YELLOW='\e[93m'
NC='\033[0m'
I='\e[3m'

# F O N T S
BOLD='\e[1m'

[ ! -f $LOG_FILE ] && touch $LOG_FILE

if [[ $# -eq 0 ]]; then
	printf "error: Argumentos inválidos \n\n"

	printf "auto-deployment usage: auto-deployment [ dir1 dir2 ... dirN ] \n\n"

	printf "	dirX: Ruta de los directorios a actualizar, pueden ser relativas o absolutas \n\n"

	exit
elif [[ $1 = "-i" || $1 = "--install" ]]; then
	if [[ $(echo $(readlink -f $0) | grep '/usr/bin/') = '' ]]; then
		if [[ -f /usr/bin/$SCRIPT_NAME || -L /usr/bin/$SCRIPT_NAME ]]; then
			sudo rm /usr/bin/$SCRIPT_NAME
		fi
		
		sudo cp $(readlink -f $0) /usr/bin/$SCRIPT_NAME

		echo -e "[${GREEN}${BOLD}OK${NC}] instalar script"
	else
		echo -e "[${RED}${BOLD}ERROR${NC}] instalar script: ya esta instalado"
	fi

	exit
fi


# F U N C T I O N S 
clearCache () {
	if [[ -f bin/console ]]; then
		if [[ -f .env ]]; then
			printf "${YELLOW}${BOLD}\nsymfony project detected [>= v4], running cache:clear...${NC} \n"
			logger 'INFO' 'symfony project detected [>= v4], running cache:clear...'

			cmd_result=`$PHP_PATH bin/console cache:clear 2>&1 > /dev/null`
			wasSuccessful=$?
			chown -R $PROJECT_USER:$PROJECT_GROUP .
			setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public
		else
			printf "${YELLOW}${BOLD}\nsymfony project detected [<= v3], running cache:clear...${NC} \n"
			logger 'INFO' 'symfony project detected [<= v3], running cache:clear...'

			cmd_result=`rm -rf var/cache/* && $PHP_PATH bin/console cache:clear --env=prod --no-warmup 2>&1 > /dev/null`
			wasSuccessful=$?
			$PHP_PATH bin/console assets:install --symlink --relative web 
			chown -R $PROJECT_USER:$PROJECT_GROUP .
			setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web
		fi

		if [ $wasSuccessful -eq 0 ];then
			printf "${GREEN}${BOLD}\ncache:clear executed successfully${NC} \n"
			logger 'INFO' 'cache:clear executed successfully'
		else
			printf "${RED}${BOLD}\nSomething went wrong! cache:clear not executed${NC} \n" 
			logger 'ERROR' 'Something went wrong! cache:clear not executed' ${cmd_result// /_}
		fi
	fi
}

composerUpdate () {
	if echo $NEW_CHANGES | grep -q $COMPOSER_LOCATION; then
		printf "${YELLOW}${BOLD}\nrunning composer:update ${NC} \n"
		logger 'INFO' 'running composer:update'

		cmd_result=`$PHP_PATH $COMPOSER_PATH update 2>&1 > /dev/null`
		wasSuccessful=$?

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD}composer:update executed successfully ${NC} \n"
			logger 'INFO' 'composer:update executed successfully'
		else
			printf "${RED}${BOLD}Something went wrong! composer:update not executed ${NC} \n"
			logger 'ERROR' 'Something went wrong! composer:update not executed' ${cmd_result// /_}
		fi
	else
		printf "${GREEN}${BOLD}composer:update not needed... ${NC} \n"
		logger 'INFO' 'composer:update not needed...'
	fi
}

schemaUpdate () {
	if echo $NEW_CHANGES | grep -q $ENTITY_PREFIX; then
		printf "${YELLOW}${BOLD}\nrunning schema:update ${NC} \n"
		logger 'INFO' 'running schema:update'
		
		cmd_result=`$PHP_PATH bin/console doctrine:schema:update --force 2>&1 > /dev/null`
		wasSuccessful=$?

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD}schema:update executed successfully ${NC} \n"
			logger 'INFO' 'schema:update executed successfully'
		else
			printf "${RED}${BOLD}Something went wrong! schema:update not executed ${NC} \n"
			logger 'ERROR' 'Something went wrong! schema:update not executed' ${cmd_result// /_}
		fi
	else
		printf "${GREEN}${BOLD}schema:update not needed... ${NC} \n"
		logger 'INFO' 'schema:update not needed...'
	fi
}

communicate () {
	echo 'implement your own mailsender...'
}

logger () {
	echo $(date +'[%d-%m-%Y %H:%M:%S']) [$1] [$CURRENT_PROJECT] $2 $3 >> $LOG_FILE

	[ $1 == 'ERROR' ] && communicate ${2// /_} ${3// /_}
}

clearLogFiles () {
	OLD_LOGS=(`find ~/ -maxdepth 1 -mtime +${MAX_LOG_FILES} -type f -name ".${SCRIPT_NAME}-*"`)
	
	if [ ${#OLD_LOGS[@]} -gt 0 ]; then
		rm -f ${OLD_LOGS[@]}
		logger 'INFO' 'old log files were auto cleared...'
	else
		logger 'INFO' 'auto-clearing not needed...'
	fi
}

# / F U N C T  I O N S

# M A I N
src=`pwd $(readlink -f "$0")`

for project in $@; do
	CURRENT_PROJECT_PATH=`realpath $project`
	if [[ -d "${CURRENT_PROJECT_PATH}/.git" ]]; then

		cd $project
		CURRENT_PROJECT=$(basename $CURRENT_PROJECT_PATH)

		printf "updating -> ${CYAN}${BOLD}$CURRENT_PROJECT${NC} listening on: ${YELLOW}${BOLD}${I}`git rev-parse --abbrev-ref HEAD`${NC}... \n"
		
		logger 'INFO' "updating -> $CURRENT_PROJECT listening on: `git rev-parse --abbrev-ref HEAD`..."
		git remote update

		UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
	    LOCAL=$(git rev-parse @)
	    REMOTE=$(git rev-parse $UPSTREAM)
	    BASE=$(git merge-base @ $UPSTREAM)
		WD_CHANGES=$(git status --untracked-files=no --porcelain)
		# NEW_CHANGES=$(git diff --name-only --merge-base $LOCAL $REMOTE) # Works on git >= 2.33
		NEW_CHANGES=$(git diff --name-only $LOCAL $REMOTE)


		printf "\nstatus: "
		if [[ $LOCAL = $REMOTE ]]; then
		    printf "${GREEN}${BOLD}up-to-date${NC} \n\n"
			logger 'INFO' 'up-to-date...'
		elif [[ $LOCAL = $BASE ]]; then
		    printf "${YELLOW}${BOLD}pulling...${NC} \n"
			logger 'INFO' 'pulling...'
			
			if [[ ${#WD_CHANGES} = 0 ]]; then
		    	printf "${GREEN}${BOLD}working directory clean...${NC} \n"
				logger 'INFO' 'working directory clean...'
			else
		    	printf "${YELLOW}${BOLD}\nworking directory is dirty, stashing...${NC} \n"
				logger 'INFO' 'working directory is dirty, stashing...'
				git stash
			fi

			git pull
			PULL_STATUS=$?

			composerUpdate

			schemaUpdate

			if [[ ${#WD_CHANGES} > 0 ]]; then
		    	printf "${YELLOW}${BOLD}\nbringing back stashed changes...${NC} \n"
				logger 'INFO' 'bringing back stashed changes...'
				git stash pop
			fi

			clearCache

			if [[ $PULL_STATUS = 0 ]]; then 
				printf "status: ${GREEN}${BOLD}updated${NC} \n\n"
				logger 'INFO' 'updated...'
				communicate 'Successfully updated'
			else
				printf "status: ${RED}${BOLD}not-updated${NC} \n\n"
				logger 'INFO' 'not-updated...'
			fi

		elif [[ $REMOTE = $BASE ]]; then
		    printf "${RED}${BOLD}need to push${NC} \n\n"
			logger 'INFO' 'need to push...'
		else
		    printf "${REED}${BOLD}diverged${NC} \n\n"
			logger 'INFO' 'diverged...'
		fi

		cd $src
		logger 'INFO' '_________________________________________________________________'
	else
		printf "[${RED}${BOLD}ERROR${NC}] `realpath $project`: doesn't exists or it's not a git project\n\n"
	fi
done

