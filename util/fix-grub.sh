#!/bin/bash

##############################################
#											 #
#	Sencillo script para recuperar el grub   #
#											 #
##############################################

sudo grub-install /dev/sda
sudo grub-mkconfig -o /boot/grub/grub.cfg