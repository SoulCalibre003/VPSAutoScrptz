#!/bin/bash
#SoulCalibre
cd

chmod -R g+rw /home/vps/public_html 
rm /home/vps/public_html/view/setting.html
rm /home/vps/public_html/view/login.html
rm /home/vps/public_html/controller/home.php
wget -P /home/vps/public_html/view "https://raw.githubusercontent.com/SoulCalibre003/VPSAutoScrptz/master/login.html"
wget -P /home/vps/public_html/view "https://raw.githubusercontent.com/SoulCalibre003/VPSAutoScrptz/master/setting.html"
wget -P /home/vps/public_html/controller "https://raw.githubusercontent.com/SoulCalibre003/VPSAutoScrptz/master/home.php"
