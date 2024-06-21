#!/bin/bash

# Created by Chris Mariano (cdm436@nyu.edu)
# Title: Pre-check MDM conditions
# License: MIT License

#Define attributes
outshow=$(sudo -S profiles show -type enrollment | grep "ds1688" && echo "data found" || echo "no data found")
outstatus=$(sudo -S profiles status -type enrollment)
jamfsrv=https://nyuad.jamfcloud.com/mdm/ServerURL
ws1srv=https://ds1688.awmdm.com/DeviceServices/AppleMDM/Processor.aspx

#Capture output
enroll_1=$(echo "$outstatus" | grep "Enrolled via DEP:" | awk '{print $4}')
enroll_2=$(echo "$outstatus" | grep "MDM enrollment:" | awk '{print $3}')
enroll_3=$(echo "$outstatus" | grep "MDM server:" | awk '{print $3}')

#Show output
echo $outshow
echo $outstatus

#Check conditions
if [[ $enroll_3 == *"jamfcloud"* ]]; then
    echo "Condition met : proceeding to migrate"
    sudo jamf policy -event migrate
elif [[ $outshow == *"ds1688"* ]] && [[ $enroll_1 == Yes ]] && [[ $enroll_2 == Yes ]] && [[ $enroll_3 == $ws1srv ]]; then
    echo "Already DEP enrolled"
    exit 0
elif [[ $outshow == *"ds1688"* ]] && [[ $enroll_1 == No ]] && [[ $enroll_2 == No ]]; then
    echo "Condition met : proceeding to migrate"
    sudo jamf policy -event migrate
elif [[ $enroll_2 == *"Yes"*  ]] && [[ $enroll_3 == $ws1srv ]]; then
    echo "Manually enrolled"
    exit 0
elif [[ $enroll_2 == No ]]; then
    echo "Condition met : proceeding to migrate"
    sudo jamf policy -event migrate
fi

