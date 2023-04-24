#!/bin/bash

##########################################################################################
##
##Copyright (c) 2017 Jamf.  All rights reserved.
##
##      Redistribution and use in source and binary forms, with or without
##      modification, are permitted provided that the following conditions are met:
##              * Redistributions of source code must retain the above copyright
##                notice, this list of conditions and the following disclaimer.
##              * Redistributions in binary form must reproduce the above copyright
##                notice, this list of conditions and the following disclaimer in the
##                documentation and#or other materials provided with the distribution.
##              * Neither the name of the Jamf nor the names of its contributors may be
##                used to endorse or promote products derived from this software without
##                specific prior written permission.
##
##      THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
##      EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
##      WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
##      DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
##      DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
##      (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
##      LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
##      ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
##      (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
##      SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
##########################################################################################
#
# SUPPORT FOR THIS PROGRAM
#
#       This program is distributed "as is" by JAMF Software, Professional Services Team. For more
#       information or support for this script, please contact your JAMF Software Account Manager.
#
#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME - apiMDM_remove.sh
# 
# DESCRIPTION - Script is used to remove MDM from macOS clients 10.13 (High Sierra) and later.
#               Parameters passed to the script include a Jamf server username and password and 
#               optionally the Jamf server URL in the form: https://FQDN:port/.
#
#               The jamf user aaccount must have at least computer create and read (JSS Objects) 
#               along with Send Computer Unmanage Command (JSS Actions).
# 	
####################################################################################################
#
# HISTORY
#
#	Version: 1.3
#
#	- Created by Leslie Helou, Professional Services Engineer, JAMF Software on December 12, 2017
#   - updated 20190124: Provide additional feedback as it runs
#   - updated 20200918: Updates due to changes in xpath for Big Sur
#
####################################################################################################

## get macOS version
macOS_Version=$(sw_vers -productVersion)
majorVer=$( /bin/echo "$macOS_Version" | /usr/bin/awk -F. '{print $1}' )
minorVer=$( /bin/echo "$macOS_Version" | /usr/bin/awk -F. '{print $2}' )

## account with computer create and read (JSS Objects), Send Computer Unmanage Command (JSS Actions)
uname="apimdmremove"
pwd="!Welcome20"
server="https://nyuad.jamfcloud.com/"

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

