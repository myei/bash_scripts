#!/bin/bash
# 
# Basic script for installing the basics packages for Arch based distros
# 
# Includes:
# 
#  - Yaourt
#  - My pacman packages
#  - My yaourt packages
#  - oh-my-zsh with some plugins and dotfiles
#       - plugin z
#       - powerlevel10k
#       - basic plugins
#
#                                                                  @myei


[[ $USER == 'root' ]] && echo "error: must execute this file as a regular user" && exit 1

SCRIPT_DIR=`pwd`
TMP_DIR=/tmp
ERROR_LOG=$SCRIPT_DIR/errors.log

exit_on_error() {
    echo -e $1
    exit 1
}


# install Yaourt
echo -e '\n > Installing Yaourt...' 
if [[ ! -f /usr/bin/yaourt ]]; then
    sudo pacman --noconfirm -S --needed base-devel git wget yajl 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong building package-query... Exiting...'
    cd $TMP_DIR
    git clone https://aur.archlinux.org/package-query.git 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong cloning... Exiting...'
    cd package-query/
    makepkg -si && cd /tmp/ || exit_on_error 'Somewhing wrong building package-query... Exiting...'
    git clone https://aur.archlinux.org/yaourt.git 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong cloning... Exiting...'
    cd yaourt/
    makepkg -si || exit_on_error 'Somewhing wrong building yaourt... Exiting...'

    rm -r $TMP_DIR/package-query $TMP_DIR/yaourt.git  
    echo -e ' > Yaourt installed successfully...' 

    cd $SCRIPT_DIR
else
    echo -e ' -- Skiping yaourt, already installed!'
fi

# install packages
echo -e ' > Installing pacman packages...'
sudo pacman --noconfirm -S - < $SCRIPT_DIR/pacman-packages.txt 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong... Exiting...'
echo -e ' > Pacman packages installed successfully...'
echo -e ' > Installing yaourt packages...'
yaourt --noconfirm -S - < $SCRIPT_DIR/yaourt-packages.txt 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong... Exiting...'
echo -e ' > Yaourt packages installed successfully...'

cd ~

# install oh-my-zsh
echo -e ' > Installing oh-my-zsh...'
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong installing oh-my-zsh... Exiting...'
# install plugin z
echo -e ' > Installing plugin z...'
wget -O ~/.z.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/z/z.sh 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong installing plugin z... Exiting...'
# install powerlevel10k
echo -e ' > Installing plugin powerlevel10k...'
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong installing powerlevel10k... Exiting...'
# install some plugins
echo -e ' > Installing other plugins...'
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong isntalling zsh-syntax-highlighting... Exiting...'
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions 1>/dev/null 2>$ERROR_LOG || exit_on_error 'Somewhing wrong installing zsh-autosuggestions... Exiting...'

echo -e ' > Mounting .zshrc file...'
cp $SCRIPT_DIR/dotfiles/.zshrc ~/
echo -e ' > Mounting .p10k.zsh file...'
cp $SCRIPT_DIR/dotfiles/.p10k.zsh ~/
echo -e ' > Compiling .zshrc...'
source ~/.zshrc
echo -e ' > oh-my-zsh installed successfully...'


echo -e '\n\nInstallation complete!!"
