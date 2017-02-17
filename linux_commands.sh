				               +                   
				               #                
				              ###               
				             #####              
				             ######            
				            ; #####;            
				           +##.#####            
				          +##########           
				         #############;         
				        ###############+        
				       #######   #######        
				     .######;     ;###;`".      
				    .#######;     ;#####.       
				    #########.   .########`     
				   ######'           '######    
				  ;####                 ####;   
				  ##'                     '##   
				 #'                         `#   



-- Información del sistema --
	yaourt -S archey-plus
	archey 									#informacion detallada del sistema

	pacman -S screenfetch
	screenfetch 							#informacion detallada del sistema

	stat -c %a <FILE or DIR>				#muestra permisos del objetivo en numeors XXX

-- Instalar paquetes --
	pacman -S “paquete” 					#Instala un paquete.
	pacman -Sy “paquete”					#Sincroniza repositorios e instala el paquete.
 
-- Actualizar paquetes --
	pacman -Sy 								#Sincroniza repositorios.
	pacman -Syy 							#Fuerza la sincronización de repositorios incluso para paquetes que parecen actualizados.
	pacman -Syu 							#Sincroniza repositorios y actualiza paquetes.
	pacman -Syyu 							#Fuerza sincronización y actualiza paquetes.
	pacman -Su 								#Actualiza paquetes sin sincronizar repositorios.
 
-- Buscar paquetes --
	pacman -Ss “paquete”					#Busca un paquete.
	pacman -Si “paquete”					#Muestra información detallada de un paquete.
	pacman -Sg “grupo”  					#Lista los paquetes que pertenecen a un grupo.
	pacman -Qs “paquete”					#Busca un paquete YA instalado.
	pacman -Qi “paquete”					#Muestra información detallada de un paquete YA instalado.
	pacman -Qdt         					#Muestra paquetes huerfanos.
	pacman -Q 								#Lista paquetes instalados
	pacman -Q > file.txt					#Guarda la lista de paquetes instalados en un archivo
 
-- Eliminar paquetes --
	pacman -R “paquete” 					#Borra paquete sin sus dependencias.
	pacman -Rs “paquete”					#Borra paquete y sus dependencias no utilizadas.

-- Paquetes huerfanos: --
	pacman -Qtdq							#listar
	pacman -Rns $(pacman -Qtdq)				#remover

-- Incluir windows y otros sistemas operativos existentes en la máquina en archlinux: --
	pacman -S os-prober
	os-prober								#detectar sistemas operativos
	grub-mkconfig -o /boot/grub/grub.cfg	#actualizar grub
	reboot

-- ADD PEM PERMANENTLY --
	sudo nano /etc/ssh/ssh_config
	IdentityFile /path/to/file.pem
	save

-- PARA PODER ABRIR SUBLIME TEXT DESDE LA TERMINAL --
	sudo ln -s /opt/sublime/sublime_text /usr/bin/subl

-- Lectura y escritura de particiones ntfs --
	pacman -S ntfs-3g

-- Actualizar Keys Pacman --
	pacman-key --refresh-keys