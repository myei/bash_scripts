#!/bin/bash
#########################################################
# Init script for Ubuntu 22.04
#
#                                          @author: myei
#########################################################

USER=
USER_EMAIL=
SSH_KEY_FILE_NAME=

#########################################################
# Config files
#########################################################

echo -e "Setting: Do not ask for password to sudo"
echo "${USER}    ALL=NOPASSWD: ALL" >> /etc/sudoers # do not ask password to sudo


#########################################################
# Dependencies
#########################################################
echo -e "Adding microsoft key"
wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -

echo -e "Adding repositories"
add-apt-repository universe
add-apt-repository ppa:daniruiz/flat-remix # flat-remix
add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main"

# google chrome
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmour -o /usr/share/keyrings/google_linux_signing_key.gpg
sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google_linux_signing_key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list'

# symfony
curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | sudo -E bash

# insomnia
echo "deb [trusted=yes arch=amd64] https://download.konghq.com/insomnia-ubuntu/ default all"     | tee -a /etc/apt/sources.list.d/insomnia.list


#########################################################
# Installing
#########################################################

# python3
echo -e "Installing python3"
bash -c "$(curl -sLo- https://git.io/JvvDs)"

# Updating repos and installing
echo -e "Upating repos and upgrading"
apt update && apt upgrade

echo -e "Installing apt packages..."
apt install curl git zsh openssh-server terminator google-chrome-stable unrar htop discus flat-remix-gtk flat-remix flat-remix-gnome neofetch \
    gnome-tweaks gnome-shell-extension-prefs gnome-shell-extension-manager \
    symfony-cli insomnia mysql-server nodejs npm apache2 php php-cli php-zip php-dom php-xml php-gd php-mysql microsoft-edge-stable docker docker-compose python3-pip \
    gromit-mpx
    
echo -e "Installing snap packages"
snap install code gitkraken skype --classic
snap install firefox spotify

# oh-my-zsh
echo -e "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k\necho 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/plugins/zsh-syntax-highlighting

# terminator
echo -e "Installing terminator themes plugin"
wget https://git.io/v5Zww -O $HOME"/.config/terminator/plugins/terminator-themes.py"

# composer
echo -e "Installing composer"
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# generating ssh key
echo -e "Generating ssh key for: ${USER_EMAIL}"
HOSTNAME=`hostname` ssh-keygen -t rsa -C "${USER_EMAIL}" -b 4096 -f "$HOME/.ssh/${SSH_KEY_FILE_NAME}" -P "" && cat ~/.ssh/${SSH_KEY_FILE_NAME}.pub

