#!/bin/bash
# Basic script for installing the basics packages for Arch based distros
#
#                                                                  @myei


SCRIPT_DIR=`pwd`
TMP_DIR=/tmp
ERROR_LOG=$SCRIPT_DIR/errors.log

exit_on_error() {
    echo -e $1
    exit 1
}

# install Yaourt
echo -e "\n -- Installing Yaourt..." 
sudo pacman --noconfirm -S --needed base-devel git wget yajl 1>/dev/null 2>$ERROR_LOG || exit_on_error "Somewhing wrong building package-query... Exiting..."
cd $TMP_DIR
git clone https://aur.archlinux.org/package-query.git 1>/dev/null 2>$ERROR_LOG || exit_on_error "Somewhing wrong cloning... Exiting..."
cd package-query/
makepkg -si && cd /tmp/ || exit_on_error "Somewhing wrong building package-query... Exiting..."
git clone https://aur.archlinux.org/yaourt.git 1>/dev/null 2>$ERROR_LOG || exit_on_error "Somewhing wrong cloning... Exiting..."
cd yaourt/
makepkg -si || exit_on_error "Somewhing wrong building yaourt... Exiting..."

rm -r $TMP_DIR/package-query $TMP_DIR/yaourt.git  
echo -e " -- Yaourt installed successfully..." 

cd $SCRIPT_DIR

# install packages
echo -e " -- Installing pacman packages..."
sudo pacman --noconfirm -S - < $SCRIPT_DIR/pacman-packages.txt 1>/dev/null 2>$ERROR_LOG || exit_on_error "Somewhing wrong... Exiting..."
echo -e " -- Installing yaourt Packages..."
yaourt --noconfirm -S - < $SCRIPT_DIR/yaourt-packages.txt 1>/dev/null 2>$ERROR_LOG || exit_on_error "Somewhing wrong... Exiting..."

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo -e "\n\nInstallation complete!!"
