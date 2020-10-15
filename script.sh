#!/bin/bash

# Versión inicial v0.1
# Descripción: Entorno de terminal para la resolución de servicios en instalaciones predefinidas
# Se recomienda utilizar bajo nuevas intalaciones

echo ''
echo '______________________________________________________________________________________'
echo '                                                                                      '
echo ' ______     ______     ______     ______     __         __   __   ______     ______   '
echo '/\  == \   /\  ___\   /\  ___\   /\  __ \   /\ \       /\ \ / /  /\  ___\   /\  == \  '
echo "\ \  __<   \ \  __\   \ \___  \  \ \ \/\ \  \ \ \____  \ \ \'/   \ \  __\   \ \  __<  "
echo ' \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_____\  \ \__|    \ \_____\  \ \_\ \_\'
echo '  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_____/   \/_/      \/_____/   \/_/ /_/'
echo '                                                                                      '
echo '                                                               𝔳0.3 𝔇𝔢𝔳𝔢𝔩𝔬𝔭𝔢𝔡 𝔟𝔶 𝔢𝔯𝔬𝔰 '
echo '______________________________________________________________________________________'
echo ''

# -------------------- #
#  Menú de navegación  #
# -------------------- #

echo 'Seleciona una opción:'
echo ---------------------------------
echo '1. Instalar Servidor DHCP (Disponible)'
echo '2. Instalar Servidor DNS'
echo '3. Instalar Servidor FTP'
echo '	4. Configurar Servidor FTP para usuarios anónimos'
echo '	5. Configurar Servidor FTP para usuarios del sistema'
echo '6. Habilitar NAT en Red Interna (Disponible)'
echo ---------------------------------

# ------------------- #
#   Funcionalidades   #
# ------------------- #

function DHCP_func {

########################
# Instalando Net-Tools #
########################

if [ -d /usr/share/doc/net-tools/ ];
then
	tput setaf 2; echo "El paquete net-tools está instalado."
	tput sgr 0
else
	tput setaf 1; echo "Se instalará el paquete Net-Tools."
	sleep 5s
	tput setaf 3;
	sudo apt-get install net-tools
	tput sgr 0
fi

########################
# Instalando ifupdown  #
########################

if [ -d /usr/share/doc/ifupdown/ ];
then
	tput setaf 2; echo "El paquete ifupdown está instalado."
	tput sgr 0
else
	tput setaf 1; echo "Se instalará el paquete ifupdown."
	sleep 5s
	tput setaf 3;
	sudo apt-get install ifupdown
	tput sgr 0
fi

########################
# Fijando IP Servidor  #
########################

# ~ Variables de interacción ~ #

tput setaf 3;echo "¿Qué interfaz de red utilizará el servidor? (Ejemplo: enp0s8)"
read DHCPint

tput setaf 3;echo "¿Qué dirección IP tendrá el servidor? (Ejemplo: 192.168.10.1)"
read DHCPip

tput setaf 3;echo "¿Qué máscara de red tendrá el servidor? (Ejemplo: 255.255.255.0)"
read DHCPmask

tput setaf 3;echo "¿Cuál será la red del servidor? (Ejemplo: 192.168.10.0)"
read DHCPnet

tput setaf 3;echo "¿Cuál es el rango de red inicial? (Ejemplo: 192.168.10.10)"
read DHCPirang

tput setaf 3;echo "¿Cuál es el rango de red final? (Ejemplo: 192.168.10.20)"
read DHCPfrang

tput setaf 3;echo "¿Cuál será el broadcast del servidor? (Ejemplo: 192.168.10.255)"
read DHCPbroad

tput setaf 3;echo "¿Cuál será el servidor DNS? (Ejemplo: 1.1.1.1)"
read DHCPdns

tput sgr 0

# ~ Estructura predeterminada ~ #

NetDir=/etc/network/interfaces

DHCPdef="ifdown $DHCPint ; ifup $DHCPint
auto $DHCPint
iface $DHCPint inet static
        address $DHCPip
        netmask $DHCPmask
        network $DHCPnet
        broadcast $DHCPbroad
        dns-name-server $DHCPdns"

# ~ Función de reemplazo ~ #

function Sed_NETfunc {
if grep -q iface $NetDir; then
	sudo tput setaf 1; echo "Se reemplazará la configuración anterior."
        sudo sed -i "/ifdown/c ifdown $DHCPint ; ifup $DHCPint" $NetDir;
        sudo sed -i "/auto/c auto $DHCPint" $NetDir;
        sudo sed -i "/iface/c iface $DHCPint inet static" $NetDir;
        sudo sed -i "/address/c \	address $DHCPip" $NetDir;
        sudo sed -i "/netmask/c \	netmask $DHCPmask" $NetDir;
        sudo sed -i "/network/c \	network $DHCPnet" $NetDir;
        sudo sed -i "/broadcast/c \	broadcast $DHCPbroad" $NetDir;
        sudo sed -i "/dns-name-server/c \	dns-name-server $DHCPdns" $NetDir;
	sudo tput setaf 2; echo "El fichero ha sido reemplazado."
	sudo tput sgr 0
else
        ## Repetición de código condicional sobre la integridad del fichero, >
        sudo echo "$DHCPdef" >> $NetDir
        echo "Se han encontrado diferencias, fichero reemplazado."
fi
}

# ~ Comprobación de fichero /interfaces ~ #

if [ -e $NetDir ];
then
        SedNet=$(Sed_NETfunc) ;
        echo "El fichero $NetDir ha sido modificado."
else
        sudo touch interfaces
        sudo echo "$DHCPdef" >> $NetDir
        echo "El fichero $NetDir no existe, generando nuevo fichero."
fi

###################################
# Activando manejo de interfaces  #
###################################

NMdir=/etc/NetworkManager/NetworkManager.conf

echo "Permitiendo las configuraciones para Network-Manager."
	if grep -q managed=false $NMdir; then
	sudo sed -i "/managed=false/c managed=true" $NMdir;
	echo "Se han permitido las configuraciones para el servicio Network-Manager."
		else
		echo "Manejo para Network-Manager correcto."
	fi

###############################
# Instalando el servidor DHCP #
###############################

if [ -d /usr/share/doc/isc-dhcp-server/ ];
then
        tput setaf 2; echo "El paquete isc-dhcp-server está instalado."
        tput sgr 0
else
        tput setaf 1; echo "Se instalará el paquete isc-dhcp-server."
        sleep 5s
        tput setaf 3;
        sudo apt-get install isc-dhcp-server
        tput sgr 0
fi

###############################
# Estableciendo tarjeta  DHCP #
###############################

DHCPcard=/etc/default/isc-dhcp-server

tput setaf 2; echo "Añadiendo tarjeta de red para el servidor."
        sleep 3s
if [ -e $DHCPcard ];
then
        sudo sed -i $"/INTERFACESv4=/c INTERFACESv4=\"$DHCPint\"" $DHCPcard;
        sudo sed -i $"/INTERFACESv6=/c INTERFACESv6=\"$DHCPint\"" $DHCPcard;
	tput setaf 2; echo "Se ha añadido la tarjeta de red correctamente."
else
	tput setaf 1; echo "Es necesario instalar el paquete isc-dhcp-server manualmente."
	sleep 5s
fi

###############################
# Cambiando preferencias DHCP #
###############################

# Interfaz

tput setaf 3; echo "Accediendo al entorno de preferencias dhcp ..."
tput sgr 0
sleep 1

# Interacción

read -p "¿Cuál es la interfaz de red externa? (Ejemplo: enp0s3): " DHCPnatcard
read -p "¿Cuál es la red externa? (Ejemplo: 192.168.13.0): " DHCPnatnet
read -p "¿Cuál es la máscara de red externa? (Ejemplo: 255.255.255.0): " DHCPnatmask

# Funcion dhcpd

DHCPconf='/etc/dhcp/dhcpd.conf'
DHCPdir='/etc/dhcp/'
DHCPdefault1='option domain-name "example.org";'
DHCPdefault2='option domain-name-servers ns1.example.org, ns2.example.org;'
DHCPdefault3='default-lease-time 600;'
DHCPdefault4='max-lease-time 7200;'

# ~ Funcion de reemplazo ~ #

function dhcpd_func {
if grep -q "# Red Externa" $DHCPconf; then
	sudo echo "Limpiando configuración anterior"> /dev/tty
	sudo sudo sed '8,22d' $DHCPconf;
	sudo echo "Estableciendo nueva configuración"> /dev/tty
	$DHCPconf;> /dev/null
	sudo tput setaf 1; echo "Se ha limpiado el fichero y aplicado los cambios"
else
	sudo echo "Modificando el archivo por primera vez."> /dev/tty
	sudo echo "Comentando líneas por defecto."> /dev/tty
        sudo sed -i "/$DHCPdefault1/c \# $DHCPdefault1" $DHCPconf;
        sudo sed -i "/$DHCPdefault2/c \# $DHCPdefault2" $DHCPconf;
        sudo sed -i "/$DHCPdefault3/c \# $DHCPdefault3" $DHCPconf;
        sudo sed -i "/$DHCPdefault4/c \# $DHCPdefault4" $DHCPconf;
	sudo sed -i '8i '"# Red Externa" $DHCPconf;
        sudo sed -i '9i '"subnet $DHCPnatnet netmask $DHCPnatmask {" $DHCPconf;
        sudo sed -i '10i \'"  interface $DHCPnatcard;" $DHCPconf;
        sudo sed -i '11i \'" default-lease-time 3600;" $DHCPconf;
        sudo sed -i '12i \'" max-lease-time 7200;" $DHCPconf;
        sudo sed -i '13i '"}" $DHCPconf;
	sudo sed -i '14i '"# Subred Interna" $DHCPconf;
        sudo sed -i '15i '"subnet $DHCPnet netmask $DHCPmask" $DHCPconf;
        sudo sed -i '16i \'"  interface $DHCPint;" $DHCPconf;
        sudo sed -i '17i \'"  range $DHCPirang $DHCPfrang;" $DHCPconf;
        sudo sed -i '18i \'"  option domain-name-servers $DHCPdns;" $DHCPconf;
        sudo sed -i '19i \'"  option broadcast-address $DHCPbroad;" $DHCPconf;
        sudo sed -i '20i \'" default-lease-time 3600;" $DHCPconf;
        sudo sed -i '21i \'" max-lease-time 7200;" $DHCPconf;
        sudo sed -i '22i '"}" $DHCPconf;
	sudo tput setaf 1; echo "Se han aplicado los cambios"
	sudo tput sgr 0
fi
}> /dev/tty

# ~ Orden de reemplazo (función conocida) ~ #

if [ -d $DHCPdir ];
then
	sudo tput setaf 3; echo 'Se modificarán las preferencias para el servidor dhcp.'
	DHCPd_conf=$(dhcpd_func) ;
	sudo tput sgr 0
else
	sudo tput setaf 1; echo 'No se ha encontrado el fichero, reinstala el servidor isc-dhcp-server'
	sudo tput sgr 0
fi


################################
# Reiniciando servicios de red #
################################

tput setaf 4;echo "Reiniciando servicio isc-dhcp-server"
sleep 1
sudo service isc-dhcp-server restart
tput setaf 4;echo "Reiniciando gestor de red NetworkManager"
sleep 1
sudo service network-manager restart
tput setaf 2;echo "Se ha completado la instalación (Se recomienda reiniciar el equipo)"
}> /dev/tty

function DNS_func {
echo 'Próximamente'> /dev/tty
}

function FTP_func {
echo 'Próximamente'> /dev/tty
}

function FTPa_func {
echo 'FTP para usuarios anónimos'> /dev/tty
}

function FTPsy_func {
echo 'FTP para usuarios del sistema'> /dev/tty
}

function NAT_func {

# Entorno NAT


sudo tput setaf 3;echo '¿Qué red utilizará DHCP? (Ejemplo de formato 192.168.1.0)'> /dev/tty
read net

sudo tput setaf 3;echo '¿Qué máscara utilizará? (Ejemplo de formato 24)'> /dev/tty
read mask

echo '-----------------------'> /dev/tty
echo 'Red interna: '$net> /dev/tty
echo 'Máscara: '$mask> /dev/tty
echo '-----------------------'> /dev/tty

#Establece que el sistema actúe como router.
sudo echo "1" >/proc/sys/net/ipv4/ip_forward

#Limpiamos la configuración del cortafuegos
sudo iptables -F
sudo iptables -t nat -F

#Indicamos que la red interna tiene salida al exterior por NAT
sudo iptables -t nat -A POSTROUTING -s $net/$mask -d 0/0 -j MASQUERADE

#Permitimos todo el tráfico de la red interna y denegamos los demás.
sudo iptables -A FORWARD -s $net/$mask -j ACCEPT
sudo iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -j DROP
}

read Elegir
case $Elegir in
	1) echo ---------------------------------
	DHCP=$(DHCP_func) ;;
	2) echo ---------------------------------
	DNS=$(DNS_func) ;;
	3) echo ---------------------------------
	FTP=$(FTP_func) ;;
	4) echo ---------------------------------
	FTPan=$(FTPa_func) ;;
	5) echo ---------------------------------
	FTPsy=$(FTPsy_func) ;;
	6) echo ---------------------------------
	NAT=$(NAT_func) ;;
	*)
esac