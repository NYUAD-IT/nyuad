#!/bin/bash

#NoMAD Prefereces

# Preference key reference
domain="ad.nyu.edu"
#background_image="/usr/local/nomadback.jpeg"
#logo="/usr/local/nomadlogo.png"

# Set default AD domain
defaults write /Library/Preferences/menu.nomad.login.ad.plist ADDomain "$domain"

# Create user as Admin pref
defaults write /Library/Preferences/menu.nomad.login.ad.plist CreateAdminUser -bool Yes

# Set background image
#defaults write /Library/Preferences/menu.nomad.login.ad.plist BackgroundImage "$background_image"

# Set login window logo
#defaults write /Library/Preferences/menu.nomad.login.ad.plist LoginLogo "$logo"

# Set security authorization database mechanisms with authchanger
/usr/local/bin/authchanger -reset -AD

#Install Nomad

echo "Installing Latest NoMAD" 
cd /tmp
curl -L -o nomadL.pkg https://files.nomad.menu/NoMAD-Login-AD.pkg
echo "Installing NoMAD"
sudo -S installer -allowUntrusted -pkg "/tmp/nomadL.pkg" -target /;

        if [[ $? -eq 0 ]]; then
        	echo "NoMAD has been successfully installed."
        else
        	echo "NoMAD installation failed!"
        	exitcode=1
        fi

#Invoke Nomad UI
# Kill loginwindow process to force NoMAD Login to launch
/usr/bin/killall -HUP loginwindow
echo "Nomand Login Loaded"
