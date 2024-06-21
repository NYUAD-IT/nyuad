#!/bin/bash

# Created by Chris Mariano (cdm436@nyu.edu)
# Title: Migration Proper
# License: MIT License

##########################################################################################

#Remove Anyconnect
ANYCONNECT_APPLICATIONNAME="Cisco AnyConnect Secure Mobility Client"

ANYCONNECT_BINDIR="/opt/cisco/anyconnect/bin"
POSTURE_BINDIR="/opt/cisco/hostscan/bin"

VPN_UNINST=${ANYCONNECT_BINDIR}/vpn_uninstall.sh
WEBSECURITY_UNINST=${ANYCONNECT_BINDIR}/websecurity_uninstall.sh
FIREAMP_UNINST=${ANYCONNECT_BINDIR}/amp_uninstall.sh
POSTURE_UNINST=${POSTURE_BINDIR}/posture_uninstall.sh
ISEPOSTURE_UNINST=${ANYCONNECT_BINDIR}/iseposture_uninstall.sh
ISECOMPLIANCE_UNINST=${ANYCONNECT_BINDIR}/isecompliance_uninstall.sh
NVM_UNINST=${ANYCONNECT_BINDIR}/nvm_uninstall.sh
OPENDNS_UNINST=${ANYCONNECT_BINDIR}/umbrella_uninstall.sh
DART_UNINST=${ANYCONNECT_BINDIR}/DART_uninstall.sh

SC_APPLICATIONNAME="Cisco Secure Client"

SC_BINDIR="/opt/cisco/secureclient/bin"

SCVPN_UNINST=${SC_BINDIR}/vpn_uninstall.sh
SCWEBSECURITY_UNINST=${SC_BINDIR}/websecurity_uninstall.sh
SCFIREAMP_UNINST=${SC_BINDIR}/amp_uninstall.sh
SCPOSTURE_UNINST=${SC_BINDIR}/posture_uninstall.sh
SCISEPOSTURE_UNINST=${SC_BINDIR}/iseposture_uninstall.sh
SCISECOMPLIANCE_UNINST=${SC_BINDIR}/isecompliance_uninstall.sh
SCNVM_UNINST=${SC_BINDIR}/nvm_uninstall.sh
SCOPENDNS_UNINST=${SC_BINDIR}/umbrella_uninstall.sh
SCDART_UNINST=${SC_BINDIR}/DART_uninstall.sh

#Modify script to skip EA removal for Secure Client

if [ -f "$SCVPN_UNINST" ]; then
  # Create a temporary file
  temp_file=$(mktemp)

  # Search for the string and delete matching lines
  grep -v "NWEXT" "$SCVPN_UNINST" > "$temp_file"

  # Replace the original file with the modified contents
  mv "$temp_file" "$SCVPN_UNINST"

  # Make the modified file executable
  chmod +x "$SCVPN_UNINST"

  echo "Lines containing 'NWEST' have been deleted from $SCVPN_UNINST."
  echo "$SCVPN_UNINST is now executable."
else
  echo "File not found: $SCVPN_UNINST"
fi

#Modify script to skip EA removal for legacy installation

if [ -f "$VPN_UNINST" ]; then
  # Create a temporary file
  temp_file=$(mktemp)

  # Search for the string and delete matching lines
  grep -v "NWEXT" "$VPN_UNINST" > "$temp_file"

  # Replace the original file with the modified contents
  mv "$temp_file" "$VPN_UNINST"

  # Make the modified file executable
  chmod +x "$VPN_UNINST"

  echo "Lines containing 'NWEST' have been deleted from $VPN_UNINST."
  echo "$VPN_UNINST is now executable."
else
  echo "File not found: $VPN_UNINST"
fi

# Gracefully quit the AnyConnect App prior to running uninstall script(s)
echo "Exiting ${ANYCONNECT_APPLICATIONNAME}"
osascript -e "quit app \"${ANYCONNECT_APPLICATIONNAME}\"" > /dev/null 2>&1

if [ -x "${ISEPOSTURE_UNINST}" ]; then
  ${ISEPOSTURE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect ISE Posture Module."
  fi
fi

if [ -x "${ISECOMPLIANCE_UNINST}" ]; then
  ${ISECOMPLIANCE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect ISE Compliance Module."
  fi
fi

if [ -x "${POSTURE_UNINST}" ]; then
  ${POSTURE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Posture Module."
  fi
fi

if [ -x "${WEBSECURITY_UNINST}" ]; then
  ${WEBSECURITY_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Web Security Module."
  fi
fi

if [ -x "${OPENDNS_UNINST}" ]; then
  ${OPENDNS_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Roaming Security Module."
  fi
fi

if [ -x "${FIREAMP_UNINST}" ]; then
  ${FIREAMP_UNINST}
  if [ $? -ne 0 ]; then
  echo "Error uninstalling AMP Enabler Module."
  fi
fi

if [ -x "${NVM_UNINST}" ]; then
  ${NVM_UNINST}
  if [ $? -ne 0 ]; then
  echo "Error uninstalling Network Visibility Module."
  fi
fi

if [ -x "${VPN_UNINST}" ]; then
  ${VPN_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Secure Mobility Client."
  fi
fi

if [ -x "${DART_UNINST}" ]; then
  ${DART_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling AnyConnect Secure Mobility Client."
  fi
fi

# Gracefully quit the Secure Client App prior to running uninstall script(s)
echo "Exiting ${SC_APPLICATIONNAME}"
osascript -e "quit app \"${SC_APPLICATIONNAME}\"" > /dev/null 2>&1

if [ -x "${SCISEPOSTURE_UNINST}" ]; then
  ${SCISEPOSTURE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client ISE Posture Module."
  fi
fi

if [ -x "${SCISECOMPLIANCE_UNINST}" ]; then
  ${SCISECOMPLIANCE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client ISE Compliance Module."
  fi
fi

if [ -x "${SCPOSTURE_UNINST}" ]; then
  ${SCPOSTURE_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client Posture Module."
  fi
fi

if [ -x "${SCWEBSECURITY_UNINST}" ]; then
  ${SCWEBSECURITY_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client Web Security Module."
  fi
fi

if [ -x "${SCOPENDNS_UNINST}" ]; then
  ${SCOPENDNS_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client Roaming Security Module."
  fi
fi

if [ -x "${SCFIREAMP_UNINST}" ]; then
  ${SCFIREAMP_UNINST}
  if [ $? -ne 0 ]; then
  echo "Error uninstalling Secure Client AMP Enabler Module."
  fi
fi

if [ -x "${SCNVM_UNINST}" ]; then
  ${SCNVM_UNINST}
  if [ $? -ne 0 ]; then
  echo "Error uninstalling Secure Client Network Visibility Module."
  fi
fi

if [ -x "${SCVPN_UNINST}" ]; then
  ${SCVPN_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client Secure Mobility Client."
  fi
fi

if [ -x "${SCDART_UNINST}" ]; then
  ${SCDART_UNINST}
  if [ $? -ne 0 ]; then
    echo "Error uninstalling Secure Client Secure Mobility Client."
  fi
fi

rm -rf /opt/cisco/anyconnect
rm -rf /opt/cisco/hostscan
rm -rf /opt/cisco/vpn
rm -rf /opt/cisco/secureclient
##########################################################################################

#Remove XDR
echo "XDRCred" | /usr/bin/sudo /Library/Application\ Support/PaloAltoNetworks/Traps/bin/cytool self_prot disable
/usr/bin/sudo /Library/Application\ Support/PaloAltoNetworks/Traps/bin/cortex_xdr_uninstaller_tool XDRCred

##AMFMDM
## get macOS version
macOS_Version=$(sw_vers -productVersion)
majorVer=$( /bin/echo "$macOS_Version" | /usr/bin/awk -F. '{print $1}' )
minorVer=$( /bin/echo "$macOS_Version" | /usr/bin/awk -F. '{print $2}' )

##########################################################################################

## account with computer create and read (JSS Objects), Send Computer Unmanage Command (JSS Actions)
uname="$4"
pwd="$5"

if [ "$6" != "" ];then
	server="$6"
else
	## get current Jamf server
	server=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)
fi

if [ "$server" == "" ];then
    echo "unable to determine current Jamf server - exiting."
    exit 1
fi

## ensure the server URL ends with a /
strLen=$((${#server}-1))
lastChar="${server:$strLen:1}"
if [ ! "$lastChar" = "/" ];then
    server="${server}/"
fi

## get unique identifier for machine
udid=$(/usr/sbin/system_profiler SPHardwareDataType | awk '/UUID/ { print $3; }')
if [ "$udid" == "" ];then
    echo "unable to determine UUID of computer - exiting."
    exit 1
else
    echo "computer UUID: $udid"
fi

## get computer ID from Jamf server
compXml=$(/usr/bin/curl -sku "${uname}:${pwd}" ${server}JSSResource/computers/udid/"$udid"/subset/general -H "Accept: application/xml")

if [[ $(echo "${compXml}" | grep "The server has not found anything matching the request URI") == "" ]];then
    if [ $majorVer -gt 10 ] || ([ $majorVer eq 10 ] && [ $majorMinor -gt 15 ]);then
        compId=$(echo "${compXml}" | /usr/bin/xpath -q -e "//computer/general/id/text()")
    else
        compId=$(echo "${compXml}" | /usr/bin/xpath "//computer/general/id/text()")
    fi
    echo "computer ID: $compId"
else
    echo "computer was not found on $server - exiting."
    exit 1
fi

## send unmanage command to machine
echo "unmanage machine: curl -X POST -sku ${uname}:******** ${server}JSSResource/computercommands/command/UnmanageDevice/id/${compId}"
/usr/bin/curl -X POST -sku "${uname}:${pwd}" ${server}JSSResource/computercommands/command/UnmanageDevice/id/${compId}

#Reload UMAD LaunchAgent
sudo chown $(whoami) /Library/LaunchAgents/com.erikng.umad.plist
sudo chown $(whoami) /Library/LaunchDaemons/com.erikng.umad.check_dep_record.plist
sudo chown $(whoami) /Library/LaunchDaemons/com.erikng.umad.trigger_nag.plist
sudo chown $(whoami) /Library/umad
sudo launchctl bootout gui/$(id -u) /Library/LaunchAgents/com.erikng.umad.plist
sudo launchctl bootstrap gui/$(id -u) /Library/LaunchAgents/com.erikng.umad.plist

sleep 60

    # Get the currently logged-in user
	loggedInUser=$(stat -f "%Su" /dev/console)

	# Get the serial number of the Mac
	serialNumber=$(system_profiler SPHardwareDataType | awk '/Serial Number/ {print $4}')

	# Create the CSV file and write the information
	echo "Serial Number,Username" > /Users/Shared/owner.csv
	echo "$serialNumber,$loggedInUser" >> /Users/Shared/owner.csv

	# Print a success message
	echo "Owner information captured and saved to /Users/Shared/owner.csv"
