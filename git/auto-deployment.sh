#!/bin/bash

###############################################################################
#
# 														Creado por: Manuel Gil
#
# 	Este script facilita/automatiza la gestión de despliegues:
#
# 		- Permite la actualización de múltiples aplicaciones manejadas por Git
# 			- Se permiten rutas relativas o absolutas
#		- Manejo de errores
#		- Implementa archivos de Logs diarios para revisión post-ejecución
#		- Auto limpieza de logs, parametrizable por días
#		- Comunicación vía email de errores y despliegues exitosos
#		- Automatizaciones inteligentes de symfony y git
#			- Limpieza de cache
#			- Actualiación de dependencias (composer y npm)
#			- Actualizacion de Base de Datos
#			- Previene conflictos con cambios locales
#			- Gulp implementado
# 		- Permite auto instalación (-i --install)
# 	
#
# 																		v2.5
##############################################################################

# C O N F I G U R A T I O N
SCRIPT_NAME='auto-deployment'
PROJECT_USER='apache'
PROJECT_GROUP='apache'
PHP_PATH=php
COMPOSER_PATH=/usr/local/bin/composer
COMPOSER_LOCATION='composer.lock'
ENTITY_PREFIX='Entity/'
LOG_FILE=~/.${SCRIPT_NAME}-$(date +'%d-%m-%Y').log
MAX_LOG_FILES=5
MAIL_DEST=(mgil@initiumsoft.com vpoeta@initiumsoft.com eacevedo@initiumsoft.com)
SERVER_NAME=`hostname`
INSTALLATION_PATH=/bin/

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
	printf "error: Invalid arguments \n\n"

	printf "auto-deployment usage: auto-deployment [ dir1 dir2 ... dirN ] \n\n"

	printf "	dirX: directories to watch, it could be full or relatives paths \n\n"

	exit
elif [[ $1 = "-i" || $1 = "--install" ]]; then
	if [[ $(echo $(readlink -f $0) | grep '${INSTALLATION_PATH}') = '' ]]; then
		if [[ -f $INSTALLATION_PATH$SCRIPT_NAME || -L $INSTALLATION_PATH$SCRIPT_NAME ]]; then
			sudo rm $INSTALLATION_PATH$SCRIPT_NAME
		fi
		
		sudo cp $(readlink -f $0) $INSTALLATION_PATH$SCRIPT_NAME && chmod +x $INSTALLATION_PATH$SCRIPT_NAME

		echo -e "[${GREEN}${BOLD}SUCCESS${NC}] instalar script"
	else
		echo -e "[${RED}${BOLD}ERROR${NC}] instalar script: ya esta instalado"
	fi

	exit
fi


# F U N C T I O N S 
clearCache () {
	if [[ -f bin/console ]]; then
		printf "${YELLOW}${BOLD}running cache:clear ${NC} \n"
		logger 'INFO' 'running cache:clear'

		if [[ -f .env ]]; then
			printf "${YELLOW}${BOLD} > symfony project detected [>= v4]${NC} \n"
			logger 'INFO' 'symfony project detected [>= v4]'

			cmd_result=`$PHP_PATH bin/console cache:clear 2>&1 > /dev/null`
			wasSuccessful=$?
			chown -R $PROJECT_USER:$PROJECT_GROUP .
			setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,log} public
		else
			printf "${YELLOW}${BOLD} > symfony project detected [<= v3]${NC} \n"
			logger 'INFO' 'symfony project detected [<= v3]'

			cmd_result=`rm -rf var/cache/* && $PHP_PATH bin/console cache:clear --env=prod --no-warmup 2>&1 > /dev/null`
			wasSuccessful=$?
			$PHP_PATH bin/console assets:install --symlink --relative web 
			chown -R $PROJECT_USER:$PROJECT_GROUP .
			setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web
		fi

		if [ $wasSuccessful -eq 0 ];then
			printf "${GREEN}${BOLD} > cache:clear executed successfully${NC} \n"
			logger 'INFO' ' > cache:clear executed successfully'
		else
			printf "${RED}${BOLD} > something went wrong! cache:clear not executed${NC} \n" 
			logger 'ERROR' ' > something went wrong! cache:clear not executed' ${cmd_result// /_}
		fi
	fi
}

composerUpdate () {
	if echo $NEW_CHANGES | grep -q $COMPOSER_LOCATION; then
		printf "${YELLOW}${BOLD}running composer:install ${NC} \n"
		logger 'INFO' 'running composer:install'

		cmd_result=`$PHP_PATH $COMPOSER_PATH install -n 2>&1 > /dev/null`
		wasSuccessful=$?

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD} > composer:install executed successfully ${NC} \n"
			logger 'INFO' ' > composer:install executed successfully'
		else
			printf "${RED}${BOLD} > something went wrong! composer:install not executed ${NC} \n"
			logger 'ERROR' ' > something went wrong! composer:install not executed' ${cmd_result// /_}
		fi
	else
		printf "${BLUE}${BOLD}[skipped] composer:install not needed... ${NC} \n"
		logger 'INFO' '[skipped] composer:install not needed...'
	fi
}

schemaUpdate () {
	if echo $NEW_CHANGES | grep -q $ENTITY_PREFIX; then
		printf "${YELLOW}${BOLD}running schema:update ${NC} \n"
		logger 'INFO' 'running schema:update'
		
		cmd_result=`$PHP_PATH bin/console doctrine:schema:update --force 2>&1 > /dev/null`
		wasSuccessful=$?

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD} > schema:update executed successfully ${NC} \n"
			logger 'INFO' ' > schema:update executed successfully'
		else
			printf "${RED}${BOLD} > something went wrong! schema:update not executed ${NC} \n"
			logger 'ERROR' ' > something went wrong! schema:update not executed' ${cmd_result// /_}
		fi
	else
		printf "${BLUE}${BOLD}[skipped] schema:update not needed... ${NC} \n"
		logger 'INFO' '[skipped] schema:update not needed...'
	fi
}

npmUpdate () {
	if echo $NEW_CHANGES | grep -q 'package.json' || echo $NEW_CHANGES | grep -q 'package-lock.json'; then

		printf "${YELLOW}${BOLD}running npm:install ${NC} \n"
		logger 'INFO' 'running npm:install'
		
		cd public
		cmd_result=`npm i --include=dev 2>&1 > /dev/null`
		wasSuccessful=$?
		cd ..

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD} > npm:install executed successfully ${NC} \n"
			logger 'INFO' ' > npm:install executed successfully'
		else
			printf "${RED}${BOLD} > something went wrong! npm:install not executed ${NC} \n"
			logger 'ERROR' ' > something went wrong! npm:install not executed' ${cmd_result// /_}
		fi
	else
		printf "${BLUE}${BOLD}[skipped] npm:install not needed... ${NC} \n"
		logger 'INFO' '[skipped] npm:install not needed...'
	fi
}

runGulp () {
	GULP_FILE='gulpfile-prod.js'
	if echo `ls ${PUBLIC_DIR}` | grep -q $GULP_FILE || echo $NEW_CHANGES | grep -q $GULP_FILE; then

		printf "${YELLOW}${BOLD}running gulp ${NC} \n"
		logger 'INFO' 'running gulp'
		
		cd $PUBLIC_DIR
		cmd_result=`/usr/local/bin/gulp -f ${GULP_FILE} 2>&1 > /dev/null`
		wasSuccessful=$?
		cd ..

		if [ $wasSuccessful -eq 0 ]; then
			printf "${GREEN}${BOLD} > gulp executed successfully ${NC} \n"
			logger 'INFO' ' > gulp executed successfully'
		else
			printf "${RED}${BOLD} > something went wrong! gulp not executed ${NC} \n"
			logger 'ERROR' ' > something went wrong! gulp not executed' ${cmd_result// /_}
		fi
	else
		printf "${BLUE}${BOLD}[skipped] gulp not needed... ${NC} \n"
		logger 'INFO' '[skipped] gulp not needed...'
	fi
}

communicate () {
	for recipient in "${MAIL_DEST[@]}"
	do
		$PHP_PATH /var/www/mercantilW2/smercantil.recurring/bin/console swiftmailer:email:send --from=emailsender@smarter.com.ve --to=${recipient} --body="<h1>${CURRENT_PROJECT}</h1> <h3>Branch: ${CURRENT_PROJECT_BRANCH}</h3> ${1//_/ } ${2//_/ }" --subject="[${SCRIPT_NAME}] - ${CURRENT_PROJECT} - ${SERVER_NAME}" 2>&1 > /dev/null
	done
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

setPublicDir () {
	if [ -f $1'/.env' ]; then
		PUBLIC_DIR='public'
	else
		PUBLIC_DIR='web'
	fi
}


# / F U N C T  I O N S

# M A I N
clearLogFiles
src=`pwd $(readlink -f "$0")`

for project in $@; do
	CURRENT_PROJECT_PATH=`realpath $project`
	if [[ -d "${CURRENT_PROJECT_PATH}/.git" ]]; then

		cd $project
		CURRENT_PROJECT=$(basename $CURRENT_PROJECT_PATH)
		CURRENT_PROJECT_BRANCH=`git rev-parse --abbrev-ref HEAD`
		setPublicDir $CURRENT_PROJECT_PATH

		printf "updating -> ${CYAN}${BOLD}$CURRENT_PROJECT${NC} listening on: ${YELLOW}${BOLD}${I}${CURRENT_PROJECT_BRANCH}${NC}... \n"
		logger 'INFO' "updating -> $CURRENT_PROJECT listening on: ${CURRENT_PROJECT_BRANCH}..."
		
		printf "${YELLOW}${BOLD}fetching remotes...  \n"
		logger 'INFO' 'fetching remotes...' 
		cmd_result=`git remote update 2>&1 > /dev/null`

		if [ $? -gt 0 ]; then
			printf "${RED}${BOLD} > error, aborting... ${NC} \n"
			#logger 'ERROR' ' > error fetching remotes, aborting...' ${cmd_result// /_}
			exit 1
		fi

		UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
	    LOCAL=$(git rev-parse @)
	    REMOTE=$(git rev-parse $UPSTREAM)
	    BASE=$(git merge-base @ $UPSTREAM)
		WD_CHANGES=$(git status --untracked-files=no --porcelain)
		# NEW_CHANGES=$(git diff --name-only --merge-base $LOCAL $REMOTE) # Works on git >= 2.33
		NEW_CHANGES=$(git diff --name-only $LOCAL $REMOTE)


		if [[ $LOCAL = $REMOTE ]]; then
		    printf "${GREEN}${BOLD} > up-to-date${NC} \n\n"
			logger 'INFO' 'up-to-date...'
		elif [[ $LOCAL = $BASE ]]; then
		    printf "${YELLOW}${BOLD} > pulling...${NC} \n"
			logger 'INFO' 'pulling...'
			
			if [[ ${#WD_CHANGES} = 0 ]]; then
		    	printf "${BLUE}${BOLD}working directory clean...${NC} \n"
				logger 'INFO' 'working directory clean...'
			else
		    	printf "${YELLOW}${BOLD}working directory is dirty, stashing...${NC} \n"
				logger 'INFO' 'working directory is dirty, stashing...'
				result=`git stash 2>&1 > /dev/null`
			fi

			result=`git pull 2>&1 > /dev/null`
			PULL_STATUS=$?

			if [ -f 'docker-compose.yml' ]; then
				logger 'INFO' "it's a docker project, restarting container..."
		    	printf "${YELLOW}${BOLD}it's a docker project, restarting container(s)...${NC} \n"
				result=`docker-compose restart`

				DOCKER_STATUS=$?
				if [[ $DOCKER_STATUS = 0 ]]; then 
		    		printf "${GREEN}${BOLD} > container(s) restarted successfully...${NC} \n"
				else
		    		printf "${RED}${BOLD} something went wrong, container(s) not restarted...${NC} \n"
					logger 'ERROR' 'something went wrong, container(s) not restarted...'
				fi
			else
				composerUpdate

				if echo $NEW_CHANGES | grep -q $ENTITY_PREFIX; then
					clearCache
				fi

				schemaUpdate
				npmUpdate
			fi
			
			if [[ ${#WD_CHANGES} > 0 ]]; then
		    	printf "${YELLOW}${BOLD}bringing back stashed changes...${NC} \n"
				logger 'INFO' 'bringing back stashed changes...'
				result=`git stash pop 2>&1 > /dev/null`
			fi

			if [ ! -f 'docker-compose.yml' ]; then
				clearCache
				runGulp
			fi

			if [[ $PULL_STATUS = 0 ]]; then 
				printf "${CYAN}${BOLD}$CURRENT_PROJECT${NC}: ${GREEN}${BOLD}successfully updated${NC} \n\n"
				logger 'INFO' 'updated...'
				communicate 'Successfully updated'
			else
				printf "${RED}${BOLD} > not-updated${NC} \n\n"
				logger 'ERROR' 'not-updated...'
				communicate "Not updated, can't pull, please take a look..."
			fi

		elif [[ $REMOTE = $BASE ]]; then
		    printf "${RED}${BOLD} > need to push${NC} \n\n"
			logger 'INFO' 'need to push...'
			communicate 'Error: The project is ahead from repository, requires attention!!'
		else
		    printf "${REED}${BOLD} > diverged${NC} \n\n"
			logger 'INFO' 'diverged...'
			communicate 'Error: diverged, requires attention!!'
		fi

		cd $src
		logger 'INFO' '_________________________________________________________________'
	else
		printf "[${RED}${BOLD}ERROR${NC}] ${CURRENT_PROJECT_PATH}: doesn't exists or it's not a git project\n\n"
	fi
done

