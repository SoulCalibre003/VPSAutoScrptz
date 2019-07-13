#!/bin/bash

if [ $USER != 'root' ]; then
	echo "You must run this as root"
	exit
fi

# initialisasi var
export DEBIAN_FRONTEND=noninteractive
OS=`uname -m`;

if [[ -e /etc/debian_version ]]; then
	#OS=debian
	RCLOCAL='/etc/rc.local'
else
	echo "You are not running this script on Debian OS"
	exit
fi

vps="vps";

if [[ $vps = "vps" ]]; then
	source="https://raw.githubusercontent.com/SoulCalibre003/VPSAutoScrptz/master"
else
	source="https://raw.githubusercontent.com/SoulCalibre003/VPSAutoScrptz/master"
fi

# go to root
cd

MYIP=$(wget -qO- ipv4.icanhazip.com);
: '
# check registered ip
wget -q -O daftarip http://34.66.206.209:85/ocs/ip.txt
if ! grep -w -q $MYIP daftarip; then
	echo "Sorry, only registered IPs can use this script!"
	if [[ $vps = "vps" ]]; then
		echo "Powered by SoulCalibre"
	else
		echo "Powered by SoulCalibre"
	fi
	rm -f /root/daftarip
	exit
fi
'

#https://github.com/adenvt/OcsPanels/wiki/tutor-debian

clear
echo ""
echo "I need to ask some questions before starting setup"
echo "You can leave the default option and just hit enter if you agree with the option"
echo ""
echo "First I need to know the new password of MySQL root user:"
read -p "Password baru: " -e -i SoulCalibre DatabasePass
echo ""
echo "Finally, name the Database Name for OCS Panels"
echo " Please, use one word only, no special characters other than Underscore (_)"
read -p " Database Name: " -e -i OCS_PANEL DatabaseName
echo ""
echo "Okay, that's all I need. We are ready to setup your OCS Panels now"
read -n1 -r -p "Press any key to continue..."

#apt-get update
apt-get update -y
apt-get install build-essential expect -y

echo "clear" >> .bashrc
echo 'echo -e " ######     #####    ##     ##  ##       "' >> .bashrc
echo 'echo -e "##   ##   ##     ##  ##     ##  ##       "' >> .bashrc
echo 'echo -e "##        ##     ##  ##     ##  ##       "' >> .bashrc
echo 'echo -e " ######   ##     ##  ##     ##  ##       "' >> .bashrc
echo 'echo -e "      ##  ##     ##  ##     ##  ##       "' >> .bashrc
echo 'echo -e "##    ##  ##     ##  ##     ##  ##       "' >> .bashrc
echo 'echo -e " ######     #####      #####    ######   "' >> .bashrc
echo 'echo -e "Modiefied by SoulCalibre                 "' >> .bashrc
echo 'echo -e "SMILE as long as it is FREE!!            "' >> .bashrc
echo 'echo -e ""' >> .bashrc

apt-get install -y mysql-server

#mysql_secure_installation
so1=$(expect -c "
spawn mysql_secure_installation; sleep 3
expect \"\";  sleep 3; send \"\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect \"\";  sleep 3; send \"Y\r\"
expect eof; ")
echo "$so1"
#\r
#Y
#pass
#pass
#Y
#Y
#Y
#Y

chown -R mysql:mysql /var/lib/mysql/
chmod -R 755 /var/lib/mysql/

sudo apt install ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list
sudo apt update
sudo apt install php7.3

apt-get -y install nginx php7.3-cli php7.3-common php7.3-curl php7.3-mbstring php7.3-mysql php7.3-xml php7.3-fpm php7.3-mcrypt
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup 
mv /etc/nginx/conf.d/vps.conf /etc/nginx/conf.d/vps.conf.backup 
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/SoulCalibre003/OCS/master/nginx.conf" 
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/SoulCalibre003/OCS/master/vps.conf" 
sed -i 's/cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php7.3/fpm/php.ini 
sed -i 's/listen = \/var\/run\/php7.3-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php7.3/fpm/pool.d/www.conf

useradd -m vps
mkdir -p /home/vps/public_html
rm /home/vps/public_html/index.html
echo "<?php phpinfo() ?>" > /home/vps/public_html/info.php
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html service php7.3-fpm restart
service php7.3-fpm restart
service nginx restart

apt-get -y install zip unzip
cd /home/vps/public_html
wget $source/OCS.zip
unzip OCS.zip
rm -f OCS.zip
chown -R www-data:www-data /home/vps/public_html
chmod -R g+rw /home/vps/public_html

#mysql -u root -p
so2=$(expect -c "
spawn mysql -u root -p; sleep 3
expect \"\";  sleep 3; send \"$DatabasePass\r\"
expect \"\";  sleep 3; send \"CREATE DATABASE IF NOT EXISTS $DatabaseName;EXIT;\r\"
expect eof; ")
echo "$so2"
#pass
#CREATE DATABASE IF NOT EXISTS OCS_PANEL;EXIT;

chmod 777 /home/vps/public_html/config
chmod 777 /home/vps/public_html/config/inc.php
chmod 777 /home/vps/public_html/config/route.php

apt-get -y --force-yes -f install libxml-parser-perl

clear
echo "Open Browser, access http://$MYIP:85/ and complete the data as below!"
echo "Database:"
echo "- Database Host: localhost"
echo "- Database Name: $DatabaseName"
echo "- Database User: root"
echo "- Database Pass: $DatabasePass"
echo ""
echo "Admin Login:"
echo "- Username: anything you want"
echo "- Password Baru: anything you want"
echo "- Re-enter New Password: as desired"
echo ""
echo "Click Install and wait for the process to finish, go back to terminal and then press [ENTER key]!"

sleep 3
echo ""
read -p "If the above step has been done, please Press [Enter] key to continue...."
echo ""
read -p "If you really believe the above step has been done, please Press [Enter] key to continue..."
echo ""
cd /root
#wget http://www.webmin.com/jcameron-key.asc
#apt-key add jcameron-key.asc
#sed -i 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
#service webmin restart

#rm -f /root/jcameron-key.asc

#rm -R /home/vps/public_html/installation

cd
rm -f /root/.bash_history && history -c
echo "unset HISTFILE" >> /etc/profile

chmod 755 /home/vps/public_html/config
chmod 644 /home/vps/public_html/config/inc.php
chmod 644 /home/vps/public_html/config/route.php

# info
clear
echo "=======================================================" | tee -a log-install.txt
echo "Please login Reseller Panel at http://$MYIP:85" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Auto Script Installer OCS Panels Mod by SoulCalibre"  | tee -a log-install.txt
echo "             (https://www.facebook.com/SoulCalibre007)           "  | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Thanks " | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Installation Log --> /root/log-install.txt" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt
cd ~/

#rm -f /root/ocspanel.sh
