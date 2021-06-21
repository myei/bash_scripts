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
# 														v2.3
##############################################################

# C O N F I G U R A T I O N
SCRIPT_NAME='auto-deployment'
PROJECT_USER='apache'
PHP_PATH=php
COMPOSER_PATH=/usr/local/bin/composer
COMPOSER_LOCATION='composer.json'
ENTITY_PREFIX='Entity/'

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
			printf "${YELLOW}${BOLD}\nsymfony project detected [>= v4], clearing cache...${NC} \n"
			$PHP_PATH bin/console cache:clear
		else
			printf "${YELLOW}${BOLD}\nsymfony project detected [<= v3], clearing cache...${NC} \n"
			rm -rf var/cache/* && $PHP_PATH bin/console cache:clear --env=prod --no-warmup
			$PHP_PATH bin/console assets:install --symlink --relative web 
			chown -R $PROJECT_USER:$PROJECT_USER .
			setfacl -d -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web && setfacl -dR -m u:$PROJECT_USER:rwx -m u:`whoami`:rwx var/{cache,logs,sessions} web
		fi
	fi
}

composerUpdate () {
	if echo $NEW_CHANGES | grep -q $COMPOSER_LOCATION; then
		printf "${YELLOW}${BOLD}\nRunning composer update ${NC} \n"
		$PHP_PATH $COMPOSER_PATH update

		successCU=$?
		if [ $successCU -eq 0 ]; then
			printf "${GREEN}${BOLD}Composer update executed successfully ${NC} \n"
		else
			printf "${RED}${BOLD}Something went wrong! Composer update not executed ${NC} \n"
		fi
	else
		printf "${GREEN}${BOLD}Composer update not needed... ${NC} \n"
	fi
}

schemaUpdate () {
	if echo $NEW_CHANGES | grep -q $ENTITY_PREFIX; then
		printf "${YELLOW}${BOLD}\nRunning schema update ${NC} \n"
		$PHP_PATH bin/console doctrine:schema:update --force

		successUDB=$?
		if [ $successUDB -eq 0 ]; then
			printf "${GREEN}${BOLD}Database schema update executed successfully ${NC} \n"
		else
			printf "${RED}${BOLD}Something went wrong! Database schema update not executed ${NC} \n"
		fi
	else
		printf "${GREEN}${BOLD}Schema update not needed... ${NC} \n"
	fi
}
# / F U N C T  I O N S

# M A I N
src=`pwd $(readlink -f "$0")`

for project in $@; do

	if [[ -d `realpath $project`"/.git" ]]; then

		cd $project

		printf "updating -> ${CYAN}${BOLD}$(basename $(realpath $project))${NC} listening on: ${YELLOW}${BOLD}${I}`git rev-parse --abbrev-ref HEAD`${NC}... \n"
		git remote update

		UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u})
	    LOCAL=$(git rev-parse @)
	    REMOTE=$(git rev-parse $UPSTREAM)
	    BASE=$(git merge-base @ $UPSTREAM)
		WD_CHANGES=$(git status --untracked-files=no --porcelain)
		NEW_CHANGES=$(git diff --name-only --merge-base $LOCAL $REMOTE)

		printf "\nstatus: "
		if [[ $LOCAL = $REMOTE ]]; then
		    printf "${GREEN}${BOLD}up-to-date${NC} \n\n"
		elif [[ $LOCAL = $BASE ]]; then
		    printf "${YELLOW}${BOLD}pulling...${NC} \n"
			
			if [[ ${#WD_CHANGES} = 0 ]]; then
		    	printf "${GREEN}${BOLD}working directory clean...${NC} \n"
			else
		    	printf "${YELLOW}${BOLD}\nworking directory is dirty, stashing...${NC} \n"
				git stash
			fi

			git pull
			PULL_STATUS=$?

			composerUpdate

			schemaUpdate

			if [[ ${#WD_CHANGES} > 0 ]]; then
		    	printf "${YELLOW}${BOLD}\nbringing back stashed changes...${NC} \n"
				git stash pop
			fi

			clearCache

			if [[ $PULL_STATUS = 0 ]]; then 
				printf "status: ${GREEN}${BOLD}updated${NC} \n\n"
			else
				printf "status: ${RED}${BOLD}not-updated${NC} \n\n"
			fi

		elif [[ $REMOTE = $BASE ]]; then
		    printf "${RED}${BOLD}need to push${NC} \n\n"
		else
		    printf "${REED}${BOLD}diverged${NC} \n\n"
		fi

		cd $src
	else
		printf "[${RED}${BOLD}ERROR${NC}] `realpath $project`: doesn't exists or it's not a git project\n\n"
	fi
done

