@echo off
title Memoria Flash 
color 07
@echo ----------------------------------------------
@echo ---- REPARACION DE FICHEROS MEMORIA FLASH ----
@echo ----------------------------------------------
@echo Cambiando Atributo de Carpetas
Attrib /d /s -r -h -s *.* 
@echo ----------------------------------------------
@echo Eliminado Accesos Directos
if exist *.lnk del *.lnk 
@echo ----------------------------------------------
@echo Eliminado Autorun
if exist autorun.inf del autorun.inf 
@echo ----------------------------------------------
@echo autorrun se a duplicado..
@echo ----------------------------------------------
@echo ----------------------------------------------
color 0f
@echo Saludos... A todos ;)
pause