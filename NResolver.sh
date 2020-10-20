#!/bin/bash

# Versión inicial v0.8
# 0.1: Añadida interfaz
# 0.2: Añadido Nat en Red interna
# 0.3: Añadido DHCP
# 0.4: Resuelto algunos bugs en la edición de archivos dhcpd
# 0.5: Añadido DNS
# 0.6: Resuelto bugs de reconomiento y reemplazo en DHCP
# 0.7: Optimizado el codigo DNS
# 0.8: Mejorado la interfaz y resuelto bugs de sintaxis
# Descripción: Entorno de terminal para la resolución de servicios en instalaciones predefinidas
# Se recomienda utilizar bajo nuevas intalaciones

echo ''
tput setaf 3; echo '______________________________________________________________________________________'
tput setaf 4;echo '                                                                                      '
tput setaf 4;echo ' ______     ______     ______     ______     __         __   __   ______     ______   '
tput setaf 5;echo '/\  == \   /\  ___\   /\  ___\   /\  __ \   /\ \       /\ \ / /  /\  ___\   /\  == \  '
tput setaf 6;echo "\ \  __<   \ \  __\   \ \___  \  \ \ \/\ \  \ \ \____  \ \ \'/   \ \  __\   \ \  __<  "
tput setaf 4;echo ' \ \_\ \_\  \ \_____\  \/\_____\  \ \_____\  \ \_____\  \ \__|    \ \_____\  \ \_\ \_\'
tput setaf 5;echo '  \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_____/   \/_/      \/_____/   \/_/ /_/'
tput setaf 6;echo '                                                                                      '
tput setaf 9;echo '                                                               𝔳0.8 𝔇𝔢𝔳𝔢𝔩𝔬𝔭𝔢𝔡 𝔟𝔶 𝔢𝔯𝔬𝔰 '
tput setaf 3;echo '______________________________________________________________________________________'
echo ''

tput setaf 11;

# -------------------- #
#  Menú de navegación  #
# -------------------- #

echo 'Seleciona una opción:'
echo ---------------------------------
echo '1. Instalar Servidor DHCP'
echo '2. Instalar Servidor DNS'
echo '3. Instalar Servidor FTP'
echo '4. Habilitar NAT en Red Interna'
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
	sudo apt-get -y install net-tools
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
	sudo apt-get -y install ifupdown
	tput sgr 0
fi

########################
# Fijando IP Servidor  #
########################

# ~ Variables de interacción ~ #

tput setaf 4;echo "¿Qué interfaz de red utilizará el servidor? (Ejemplo: enp0s8)"
tput sgr 0;
read -e -i "enp0s8" DHCPint

tput setaf 4;echo "¿Qué dirección IP tendrá el servidor? (Ejemplo: 192.168.83.1)"
tput sgr 0;
read -e -i "192.168.83.1" DHCPip

tput setaf 4;echo "¿Qué máscara de red tendrá el servidor? (Ejemplo: 255.255.255.0)"
tput sgr 0;
read -e -i "255.255.255.0" DHCPmask

tput setaf 4;echo "¿Cuál será la red del servidor? (Ejemplo: 192.168.10.0)"
tput sgr 0;
read -e -i "192.168.83.0" DHCPnet

tput setaf 4;echo "¿Cuál es el rango de red inicial? (Ejemplo: 192.168.10.10)"
tput sgr 0;
read -e -i "192.168.83.0" DHCPirang

tput setaf 4;echo "¿Cuál es el rango de red final? (Ejemplo: 192.168.10.20)"
tput sgr 0;
read -e -i "192.168.83.20" DHCPfrang

tput setaf 4;echo "¿Cuál será el broadcast del servidor? (Ejemplo: 192.168.10.255)"
tput sgr 0;
read -e -i "192.168.83.255" DHCPbroad

tput setaf 4;echo "¿Cuál será el servidor DNS? (Ejemplo: 1.1.1.1)"
tput sgr 0;
read -e -i "1.1.1.1" DHCPdns

tput sgr 0;

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

	echo "Limpiando fichero /etc/network/interfaces"
	sudo rm -r '/etc/network/interfaces'
	sleep 1
	sudo touch '/etc/network/interfaces'

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
        tput setaf 2;echo "El fichero $NetDir ha sido modificado."
	tput sgr 0;
else
        sudo touch interfaces
        sudo echo "$DHCPdef" >> $NetDir
        tput setaf 3;echo "El fichero $NetDir no existe, generando nuevo fichero."
	tput setaf 0;
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
        tput sgr 0;
        sudo apt-get -y remove isc-dhcp-server
        sleep 1
	tput setaf 2; echo "Reinstalando isc-dhcp-server."
        tput sgr 0;
        sudo apt-get -y install isc-dhcp-server
else
        tput setaf 1; echo "Se instalará el paquete isc-dhcp-server."
        sleep 2s
        tput setaf 3;
        sudo apt-get -y install isc-dhcp-server
        tput sgr 0;
fi

###############################
# Estableciendo tarjeta  DHCP #
###############################

DHCPcard=/etc/default/isc-dhcp-server

tput setaf 2; echo "Añadiendo tarjeta de red para el servidor."
        sleep 1s
if [ -e $DHCPcard ];
then
        sudo sed -i $"/INTERFACESv4=/c INTERFACESv4=\"$DHCPint\"" $DHCPcard;
        sudo sed -i $"/INTERFACESv6=/c INTERFACESv6=\"$DHCPint\"" $DHCPcard;
	tput setaf 2; echo "Se ha añadido la tarjeta de red correctamente."
else
	tput setaf 1; echo "Es necesario instalar el paquete isc-dhcp-server manualmente."
	sleep 2s
fi

###############################
# Cambiando preferencias DHCP #
###############################

# Interfaz

tput setaf 3; echo "Accediendo al entorno de preferencias dhcp ..."
tput sgr 0;
sleep 1

# Interacción

read -e -i "enp0s3" -p "¿Cuál es la interfaz de red externa? (Ejemplo: enp0s3): " DHCPnatcard
read -e -i "192.168.13.0" -p "¿Cuál es la red externa? (Ejemplo: 192.168.13.0): " DHCPnatnet
read -e -i "255.255.255.0" -p "¿Cuál es la máscara de red externa? (Ejemplo: 255.255.255.0): " DHCPnatmask

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
	sudo tput setaf 6;echo "Limpiando configuración anterior"
	sudo sed '8,22d' $DHCPconf;> /dev/null
	sudo echo "Estableciendo nueva configuración"
	sudo tput setaf 2; echo "Se ha limpiado el fichero y aplicado los cambios"
	sudo tput sgr 0;
else
	sudo echo "Modificando el archivo por primera vez."
	sudo echo "Comentando líneas por defecto."
	sudo sed -i "/$DHCPdefault1/c \# $DHCPdefault1" $DHCPconf;
	sudo sed -i "/$DHCPdefault2/c \# $DHCPdefault2" $DHCPconf;
	sudo sed -i "/$DHCPdefault3/c \# $DHCPdefault3" $DHCPconf;
	sudo sed -i "/$DHCPdefault4/c \# $DHCPdefault4" $DHCPconf;
	sudo sed -i '8i '"# Red Externa" $DHCPconf;
	sudo sed -i '9i '"subnet $DHCPnatnet netmask $DHCPnatmask {" $DHCPconf;
	sudo sed -i '10i \'"	interface $DHCPnatcard;" $DHCPconf;
	sudo sed -i '11i \'"	default-lease-time 3600;" $DHCPconf;
	sudo sed -i '12i \'"	max-lease-time 7200;" $DHCPconf;
	sudo sed -i '13i '"}" $DHCPconf;
	sudo sed -i '14i '"# Subred Interna" $DHCPconf;
	sudo sed -i '15i '"subnet $DHCPnet netmask $DHCPmask {" $DHCPconf;
	sudo sed -i '16i \'"	interface $DHCPint;" $DHCPconf;
	sudo sed -i '17i \'"	range $DHCPirang $DHCPfrang;" $DHCPconf;
	sudo sed -i '18i \'"	option domain-name-servers $DHCPdns;" $DHCPconf;
	sudo sed -i '19i \'"	option broadcast-address $DHCPbroad;" $DHCPconf;
	sudo sed -i '20i \'"	default-lease-time 3600;" $DHCPconf;
	sudo sed -i '21i \'"	max-lease-time 7200;" $DHCPconf;
	sudo sed -i '22i '"}" $DHCPconf;
	sudo tput setaf 1; echo "Se han aplicado los cambios"
	sudo tput sgr 0;
fi
}> /dev/tty

# ~ Orden de reemplazo (función conocida) ~ #

if [ -d $DHCPdir ];
then
	sudo tput setaf 3; echo 'Se modificarán las preferencias para el servidor dhcp.'
	DHCPd_conf=$(dhcpd_func) ;
	sudo tput sgr 0;
else
	sudo tput setaf 1; echo 'No se ha encontrado el directorio dhcp, verifica si los servicios de red están instalados'
	sudo tput sgr 0;
fi


################################
# Reiniciando servicios de red #
################################

tput setaf 4;echo "Iniciando servicio isc-dhcp-server"
sudo service isc-dhcp-server stop
sleep 2
sudo service isc-dhcp-server start
sleep 3

tput setaf 4;echo "Reiniciando gestor de red NetworkManager"
sudo service network-manager restart
tput setaf 2;echo "Se ha completado la instalación (Se recomienda reiniciar el equipo)"
tput sgr 0;
}> /dev/tty

function DNS_func {
# Interfaz

tput setaf 1;echo '** Este script reemplazará configuraciones existentes.'
tput sgr 0;

tput setaf 6;echo '¿Qué interfaz utilizará el servidor? (Ejemplo: enp0s8)'
tput sgr 0;
read -e -i "enp0s8" DnsI

tput setaf 6;echo '¿Qué interfaz lleva internet en adaptador puente? (Ejemplo: enp0s3)'
tput sgr 0;
read -e -i "enp0s3" DnsII

tput setaf 6;echo '¿Cuál es la red del servidor? (Ejemplo: 192.168.83.0)'
tput sgr 0;
read -e -i "192.168.83.0" DnsN

tput setaf 6;echo '¿Cuál es la ip del servidor? (Ejemplo: 192.168.83.1)'
tput sgr 0;
read -e -i "192.168.83.1" DnsA

tput setaf 6;echo '¿Cuál es la máscara del servidor? (Ejemplo: 255.255.255.0)'
tput sgr 0;
read -e -i "255.255.255.0" DnsM

tput setaf 6;echo 'Cuál es el broadcast del servidor? (Ejemplo: 192.168.83.255)'
tput sgr 0;
read -e -i "192.168.83.255" DnsB

tput setaf 6;echo '¿Nombre de dominio zona directa? (Ejemplo: webclase.com)'
tput sgr 0;
read -e -i "webebre.net" DZone

tput setaf 6;echo '¿Nombre de dominio zona inversa? (Ejemplo: 1.168.192.in-addr.arpa)'
tput sgr 0;
read -e -i "83.168.192.in-addr.arpa" IZone

# Directorios

DNSdir=/etc/bind

# Limpiando posibles configuraciones anteriores

	# Verificando bases de datos y eliminando
	if [ -e $DNSdir/db.$DZone.direct ];
	then
	echo 'Ya existe una configuración similar, se reemplazará por la nueva'
	sudo rm -r $DNSdir/db.$DZone.direct
	else
        echo 'Se ha detectado que es una nueva configuración, continuando..'
	fi

	if [ -e $DNSdir/db.$IpRev.rev ];
	then
	sudo rm -r $DNSdir/db.$IpRev.rev
	else
	tput setaf 2;echo 'Nueva zona inversa correcta.'
	tput sgr 0;
	fi

	# Reestableciendo named.conf.local.backup
	if [ -e $DNSdir/named.conf.local.backup ];
	then
	tput setaf 2;echo 'Reestableciendo fichero named.conf.local'
	sudo rm -r $DNSdir/named.conf.local
	sudo cp $DNSdir/named.conf.local.backup $DNSdir/named.conf.local
	tput sgr 0;
	else
	tput setaf 1;echo 'Iniciando nueva instalación o named.conf.local no reconocido.'
	tput sgr 0;
	fi

# Instalando servidor bind9

sudo dpkg -s bind9 &> /dev/null

if [ $? -ne 0 ]
then
	tput setaf 3;echo "Bind9 no se encuentra instalado, instalando..."
	sudo apt-get -y update
	sudo apt-get -y install bind9
	tput sgr 0;
else
	tput setaf 1;
	sudo apt-get -y remove bind9
	tput setaf 2;echo "Reinstalando bind9."
	sudo apt-get -y install bind9
	tput sgr 0;
fi

# Estableciendo ip estática para el servidor dns

echo 'Estableciendo IP Estática.'

DNSs="ifdown $DnsI ; ifup $DnsI
auto $DnsI
iface $DnsI inet static
	address $DnsA
	netmask $DnsM
	network $DnsN
	broadcast $DnsB
	dns-name-server $DnsA

auto $DnsII
iface $DnsII inet dhcp"

sudo echo "$DNSs" > /etc/network/interfaces

# Ip reverse brusco
IpR1=$(echo $DnsA | cut -d '.' -f1)
IpR2=$(echo $DnsA | cut -d '.' -f2)
IpR3=$(echo $DnsA | cut -d '.' -f3)
IpRev="$IpR3.$IpR2.$IpR1"

# Creando bases de datos DNS

echo 'Generando bases de datos DNS.'

cp $DNSdir/db.local $DNSdir/db."$DZone".direct
tput setaf 2;echo 'Base de datos directa creada.'
tput sgr 0;

cp $DNSdir/db.127 $DNSdir/db."$IpRev".rev
tput setaf 2;echo 'Base de datos inversa creada.'
tput sgr 0;

# Añadiendo zonas directa e inversa al fichero de configuración de zonas


echo 'Añadiendo zonas al fichero de configuración.'

DnsZones="//Zona directa
zone "'"'"$DZone"'"'" {
	type master;
	file "'"'"$DNSdir/db.$DZone.direct"'"'";
	notify yes;
};

//Zona inversa
zone "'"'"$IpRev.in-addr.arpa"'"'" {
	type master;
	file "'"'"$DNSdir/db.$IpRev.rev"'"'";
	notify yes;
};"

DnsZonesOut=$DnsZones

	# Limpiando backup de lineas erróneas
	sudo sudo sed '7,25d' $DNSdir/named.conf.local.backup;> /dev/null

echo 'Realizando backup al fichero named.conf.local'
sudo cp $DNSdir/named.conf.local $DNSdir/named.conf.local.backup
	sudo sed -i '/rfc1918/G' $DNSdir/named.conf.local;
	sudo echo "$DnsZonesOut" >> $DNSdir/named.conf.local
	tput setaf 2;echo 'Se han añadido las zonas'
	tput sgr 0;

# Añadiendo un servidor DNS alternativo

echo 'Añadiendo un servidor DNS alternativo'
sudo sed -i "s/0.0.0.0/8.8.8.8/g" $DNSdir/named.conf.options;

# Configurando zona directa

echo 'Configurando zona directa'
read -e -i "s" -p '¿Incluir subdominios por defecto (s/n): ' DNSanswerD

# Sumándole un host a la ip
DnsIp=$(echo $DnsA | cut -d '.' -f1,2,3)
DnsLp=$(echo $DnsA | cut -d '.' -f4)
DnsSum=$(($DnsLp + 1))
DnsResult="$DnsIp"."$DnsSum"

if [ $DNSanswerD == s ];
then
	echo "Remplazando dominio local por $DZone"
	sudo sed -i "s/localhost/$DZone/g" $DNSdir/db.$DZone.direct;
	sudo sed -i "s/127.0.0.1/$DnsA/g" $DNSdir/db.$DZone.direct;
	echo "Añadiendo subdominios a zona directa."
	sudo sed -i '$a'"$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
        sudo sed -i '$a'"dns.$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
	sudo sed -i '$a'"pc1.$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
	sudo sed -i '$a'"pc2.$DZone.\	\IN	\A	$DnsResult" $DNSdir/db.$DZone.direct;
else
	echo 'Sólo se permiten 3 subdominios por el momento'
	read -p 'Introduce el primer subdominio (Ejemplo: dns): ' DNSdsub
	read -p 'Introduce el segundo subdominio (Ejemplo: pc1): ' DNSdsub1
	read -p 'Introduce el cuardo subdominio (Ejemplo: www): ' DNSdsub2

	echo "Remplazando dominio local por $DZone"
	sudo sed -i "s/localhost/$DZone/g" $DNSdir/db.$DZone.direct;
	sudo sed -i "s/127.0.0.1/$DnsA/g" $DNSdir/db.$DZone.direct;
	echo "Añadiendo subdominios a zona directa."
	sudo sed -i '$a'"$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
	sudo sed -i '$a'"$DNSdsub.$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
	sudo sed -i '$a'"$DNSdsub1.$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
	sudo sed -i '$a'"$DNSdsub2.$DZone.\	\IN	\A	$DnsA" $DNSdir/db.$DZone.direct;
fi

# Configurando zona inversa

echo 'Configurando zona inversa'
read -e -i "s" -p '¿Incluir subdominios por defecto (s/n): ' DNSanswerI

if [ $DNSanswerI == s ];
then
	echo "Remplazando dominio local por $DZone"
	sudo sed -i "s/localhost/$DZone/g" $DNSdir/db.$IpRev.rev;
	sudo sed -i "s/1.0.0/$DnsLp/g" $DNSdir/db.$IpRev.rev;
	echo "Añadiendo subdominios a zona inversa."
	sudo sed -i '$a'"$DnsLp\	\IN	\PTR	dns.$DZone." $DNSdir/db.$IpRev.rev;
	sudo sed -i '$a'"$DnsLp\	\IN	\PTR	pc1.$DZone." $DNSdir/db.$IpRev.rev;
	sudo sed -i '$a'"$DnsSum\	\IN	\PTR	pc2.$DZone." $DNSdir/db.$IpRev.rev;
else
	echo 'Sólo se permiten 3 subdominios por el momento'
	read -p 'Introduce el primer subdominio (Ejemplo: dns): ' DNSisub
	read -p 'Introduce el segundo subdominio (Ejemplo: pc1): ' DNSisub1
	read -p 'Introduce el cuardo subdominio (Ejemplo: www): ' DNSisub2

	echo "Remplazando dominio local por $IZone"
	sudo sed -i "s/localhost/$DZone/g" $DNSdir/db.$IpRev.rev;
	sudo sed -i "s/1.0.0/$DnsLp/g" $DNSdir/db.$IpRev.rev;
	echo "Añadiendo subdominios a zona inversa."
	sudo sed -i '$a'"$DnsLp\        \IN     \PTR      $DNSisub.$DZone." $DNSdir/db.$IpRev.rev;
	sudo sed -i '$a'"$DnsLp\        \IN     \PTR      $DNSisub1.$DZone." $DNSdir/db.$IpRev.rev;
	sudo sed -i '$a'"$DnsSum\       \IN     \PTR      $DNSisub2.$DZone." $DNSdir/db.$IpRev.rev;
fi

# Verificando ficheros de configuración

tput setaf 3; echo 'Verificando configuración directa.'
tput sgr 0;
named-checkzone $DZone $DNSdir/db.$DZone.direct

tput setaf 3; echo 'Verificando configuración inversa.'
tput sgr 0;
named-checkzone $IZone $DNSdir/db.$IpRev.rev
sleep 1

# Reemplazando servidor en /etc/resolv.conf
# Via opcional de resolv.conf
# sudo sed -i s/nameserver 127.0.0.53/c \# nameserver 127.0.0.53/g" $ResolvDir;
# sudo sed -i s/options edns0/c \# options edns0/g" $ResolvDir;

ResolvDir=/etc/resolv.conf
DnsNMDir=/etc/NetworkManager

ResolvDef="domain $DZone
search $DZone
nameserver $DnsA"

sudo rm -r $ResolvDir
sudo touch $ResolvDir
sleep 1

tput setaf 6; echo "Reemplazando servidor en $ResolvDir"
tput sgr 0;

	sudo echo "$ResolvDef" >> $ResolvDir
	tput setaf 2; echo "El fichero ha sido reemplazado."
	tput sgr 0;

tput setaf 6; echo "Desactivando la actualización automática dns de Network-Manager."
tput sgr 0;

	DNScat=$(cat $DnsNMDir/NetworkManager.conf | grep -i 'dns=')

	if [ "$DNScat" == "" ];
	then
        sudo sed -i '/keyfile/a\dns=none' $DnsNMDir/NetworkManager.conf;
	else
        sudo sed -i 's/dns=true/dns=none/g' $DnsNMDir/NetworkManager.conf;
	fi

	echo "Permitiendo manejo de interfaces para Network-Manager"
	sudo sed -i "s/managed=none/managed=true/g" $DnsNMDir/NetworkManager.conf;

# Reiniciando servicios y limpiando caché

tput setaf 2; echo "Reiniciando servicios y limpiando caché dns"
tput sgr 0;

	sudo service bind9 restart
	sudo service network-manager restart
	sleep 1
	tput setaf 2; host $DnsA
	tput sgr 0;

# Informacion

tput setaf 6;echo " ------------------------------------------------------------------------- "
tput setaf 6;echo "1. Se ha instalado el servidor bind9                                       "
tput setaf 6;echo "2. Se ha establecido una ip en /etc/network/interfaces                     "
tput setaf 6;echo "3. Se han generado las bases de datos db.$DZone.direct y db.$IpRev.rev     "
tput setaf 6;echo "4. Se ha realizado un backup del archivo named.conf.local a .backup        "
tput setaf 6;echo "5. Se ha editado el fichero dns alternativo /etc/bind/named.conf.options   "
tput setaf 6;echo "6. Se ha configurado zona directa en $DNSdir/db.$DZone.direct              "
tput setaf 6;echo "7. Se ha configurado zona inversa en $DNSdir/db.$IpRev.rev		      "
tput setaf 6;echo "8. Se han verificado los archivos para observación del usuario             "
tput setaf 6;echo "9. Se ha reemplazado el servidor en el fichero /etc/resolv.conf            "
tput setaf 6;echo "10. Se han reiniciado los servicios y limpiado la caché dns                "
tput setaf 6;echo " ------------------------------------------------------------------------- "
tput sgr 0;
}> /dev/tty

function FTP_func {
echo 'Próximamente'> /dev/tty
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
	NAT=$(NAT_func) ;;
	*)
esac
