#!/bin/bash

#####################################################################################
# original by Ed Childers posted on Jamf nation to stop wifi being active when ethernet is connected and active.
# https://jamfnation.jamfsoftware.com/discussion.html?id=5916
# modified by Mark Lamont to change a couple of small things
# 1. do not automatically turn wifi ON continually when Ethernet Not plugged in.
# this allows wifi to be turned off when not required or not allowed such as on a plane.
# 2. only operate on a set wifi. This was added because in our environment it is only required to have the no wifi on ethernet functionality to prevent use of ISE licenses by an unused network.
# the basic functionality is the same only two changes
# 1. added a loop to check if on specified wifi when on ethernet
# 2. commented out the last section to always turn on wifi
# to use it package up the plist as a launchDaemon and the drop this script in /Library/Scripts
###################################################################################

#############################################
#Some variables to make things easier to read:
#############################################

PlistBuddy=/usr/libexec/PlistBuddy
plist=/Library/Preferences/SystemConfiguration/NetworkInterfaces.plist

# for testing uncomment one and comment the other
#disableOnWiFi="testwifissid"
disableOnWiFi="MyWiFiSSID"

#############################################
#Find out how many Interfaces there are
#############################################

count=`networksetup -listallhardwareports | grep Hardware | wc -l | tr -s " "`
echo "Found$count network interfaces"



#############################################
#Get Interfaces
#############################################
#############################################
#reset counter
#############################################
counter=0

while [ $counter -lt $count ] 
do
		interface[$counter]=`$PlistBuddy -c "Print Interfaces:$counter:SCNetworkInterfaceType" $plist` 
	let "counter += 1"
done


#############################################
#Get Real Interfaces
#############################################
#reset counter
#############################################
counter=0

while [ $counter -lt $count ] 
do
		bsdname[$counter]=`$PlistBuddy -c "Print Interfaces:$counter:BSD\ Name" $plist`
	let "counter += 1"
done


#############################################
#Build Airport Array ${airportArray[@]} and Ethernet Array ${ethernetArray[@]}
#############################################
#reset counter
#############################################
counter=0

while [ $counter -lt $count ] 
do
#############################################
#Check for Airport
#############################################
		if [ "${interface[$counter]}" = "IEEE80211" ]
		then
#############################################
#Add it to the Array
#############################################
			airportArray[$counter]=${bsdname[$counter]}
		fi
#############################################
#Check for Ethernet
#############################################
		if [ "${interface[$counter]}" = "Ethernet" ]
		then
#############################################
#Add it to the Array
#############################################
			ethernetArray[$counter]=${bsdname[$counter]}
		fi
#############################################
	let "counter += 1"
#############################################
done
#############################################



#############################################
#Tell us what was found
#############################################
for i in ${ethernetArray[@]}
do
	echo $i is Ethernet
done

for i in ${airportArray[@]}
do
	echo $i is Airport
done


#############################################
#Check to see if Ethernet is connected
#############################################
#############################################
#Figure out which Interface has activity
#############################################
for i in ${ethernetArray[@]}
	do
	activity=`netstat -I $i | wc -l`
		if [ $activity -gt 1 ]
		then
			echo "$i has activity..."
			checkActive=`ifconfig $i | grep status | cut -d ":" -f2`
#############################################
#Ethernet IS connected
#############################################
			if [ "$checkActive" = " active" ]
			then

#############################################
# check if on corporate WiFi, only turn off if internal
#############################################
			
#Detect our connected SSID:
ssid=$(networksetup -getairportnetwork ${airportArray[@]} | cut -d " " -f 4)

echo "ssid: $ssid"

# check if we need to turn wifi off, only applicable on corporate network
disableRequired=$(echo ${ssid} | grep -ci "$disableOnWiFi")
		
				if [ $disableRequired = "1" ]; then
			
				echo "$i is connected and we are on the $disableOnWiFi SSID...turning off Airport"
#############################################
#Turn off Airport
#############################################
				networksetup -setairportpower ${airportArray[@]} off
				echo "Airport off"
				exit 0
				else
				echo "$i is connected and we are NOT on the $disableOnWiFi SSID...leaving Airport"
				fi
			fi
			if [ "$checkActive" = " inactive" ]
			then
				echo "$i is not active"
			fi
		fi
done
	echo "Checked all Interfaces"




#############################################
#If the script makes it this far assume Ethernet is not connected.
#############################################
#Turn on Airport
#############################################
# commented out the airport onto avoid the wifi always turning on even when manually turned off.

#networksetup -setairportpower ${airportArray[@]} on
#echo "Airport on"
exit 0
