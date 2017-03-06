#!/bin/bash


# find if the device has and SSD then
# find if it is not an Apple SSD
# if it's not set up launchdaemon to switch trimforce on

name="Trim-set"
version="0.1"

# log file path and name.
logto="/var/log/"
log="my.log"

secho()
{
	
	message="$1"
	
		# echo "$name: $message"
		echo "$(date "+%a %b %d %H:%M:%S") $HOSTNAME $name-$version : $message" >> "$logto/$log"

}

createScript() {
# create the script that launchdaemon will run
cat > /Library/Management/trimforce.sh << EOF
#!/bin/bash

# delete the files to prevent rerunning

rm -f /Library/LaunchDaemons/com.jamfsoftware.task.trimforce.plist
rm -f /Library/Management/trimforce.sh

# display message, spawn as separate process
"/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper" -windowType hud -title "Warning" -heading "TRIM is enabling" -alignHeading center -description "TRIM is enabling on this device. It will restart very shortly. Please do nothing until it completes." -alignDescription center -icon "/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png" -iconSize 75 -button1 ok -defaultButton 0 &

echo "**************** running trim setup ***************" >> "/var/log/my.log"
yes | trimforce enable




EOF

chmod +x /Library/Management/trimforce.sh
}

# 
hasSSD=$(diskutil info / | awk '/Solid State/{print $NF}')
secho "has SSD = $hasSSD"
if [ "$hasSSD" = "Yes" ]; then
	# check if it is an apple SSD
	isAppleSSD=$(diskutil info / | grep "Media Name:" | grep -c APPLE)
	if [ "$isAppleSSD" != "1" ]; then
		# If not apple then check if TRIM is on anyway
		isTRIMOn=$(system_profiler SPSerialATADataType | grep 'TRIM' | grep -c "Yes")
			if [ "$isTRIMOn" != "1" ]; then
			secho "Non Apple SSD and no TRIM detected"
			secho "Setting launchDaemon"
			createScript
			jamf scheduledTask -command "sh -c /Library/Management/trimforce.sh" -name trimforce -minute '*/.25/'
			sleep 1
			# force unload to prevent running
			launchctl unload /Library/LaunchDaemons/com.jamfsoftware.task.trimforce.plist
			else
			secho "Non Apple SSD with TRIM enabled detected"
			fi
	else
		secho "Apple SSD fitted. No action"
	fi
else
	secho "No SSD fitted. No action"
fi

