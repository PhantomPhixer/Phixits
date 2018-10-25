#!/bin/bash

# generic depnotify cover screen

screenTitle="${4}"
screenMainTextIn="${5}"
screenInitialstatus="${6}"
screenIcon="${7}"
# number of times the windowed message can be shown before full screen kicks in
windowedTimesLimit="${8}"
slackNotifyTrigger=$(($windowedTimesLimit+10))
slackChannel="${9}"
slackBot="${10}"
plistName="${11}"



#######################################
# check depnotify actually installed. #
# install if not                      #
#######################################

if [ ! -d /Applications/Utilities/DEPNotify.app ]; then
	echo "installing DEPNotify"
	jamf policy -event install-depnotify-live
	echo "installing DEPNotify"
	if [ -d /Applications/Utilities/DEPNotify.app ]; then
		echo "***** installed DEPNotify"
	else
		echo "***** install failed! Exiting as pointless running"
	fi
else
	echo "DEPNotify is installed already"
fi


DepNotifyWorkingDir="/var/tmp/"

# check user is logged in
dockStatus=$(pgrep -x Dock)
while [[ "$dockStatus" == "" ]]; do
	sleep 5
	dockStatus=$(pgrep -x Dock)
done

loggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')

# find how many times run before
shownCount=$(defaults read com.mycorp.$plistName.message shownCount)
echo "shown count = $shownCount"

#################################


resetDEPNotify () {
rm "$DepNotifyWorkingDir"depnotify.log 
rm "$DepNotifyWorkingDir"DEPNotify.plist
rm "$DepNotifyWorkingDir"com.depnotify.agreement.done
rm "$DepNotifyWorkingDir"com.depnotify.registration.done
rm "$DepNotifyWorkingDir"com.depnotify.provisioning.done
sudo -u "$loggedInUser" defaults delete menu.nomad.DEPNotify
	
}


initialise_DEPNotify_Settings () {

echo "Command: MainTitle: $screenTitle" >> "$DepNotifyWorkingDir"depnotify.log
echo "Command: MainText: $screenMainTextIn "  >> "$DepNotifyWorkingDir"depnotify.log
echo "Status: $screenInitialstatus" >> "$DepNotifyWorkingDir"depnotify.log
echo "Command: Image: $screenIcon" >> "$DepNotifyWorkingDir"depnotify.log


}

checkContinueCompleted () {
agreeStatus="no"
while [[ "$agreeStatus" == "no" ]]; do
	sleep 1
	if [ ! -f "$DepNotifyWorkingDir"com.depnotify.provisioning.done ]; then
		agreeStatus="no"
		echo "Assign = $agreeStatus"
	else
		agreeStatus="yes"
		echo "assign = $agreeStatus"
fi
done


}

displayMessageLessThan () {
sudo -u "$loggedInUser" /Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify &

sleep 5
echo "Command: ContinueButton: Close message" >> "$DepNotifyWorkingDir"depnotify.log

}

displayMessagesMoreThan () {

sudo -u "$loggedInUser" /Applications/Utilities/DEPNotify.app/Contents/MacOS/DEPNotify -fullScreen &

#sleep 2
sleep 30

echo "Command: ContinueButton: Close message" >> "$DepNotifyWorkingDir"depnotify.log

}


sendSlackNotification () {

serial=$(system_profiler SPHardwareDataType | grep -i "serial number" | cut -d ":" -f2 |cut -d " " -f2)


curl -X POST --data-urlencode 'payload={"channel": "#'$slackChannel'", "username": "'$slackBot'", "text": "'$serial' has run upgrade notification '$newShownCount' times. User is '$loggedInUser' ", "icon_emoji": "'$icon'"}' https://hooks.slack.com/services/blahblahblahblahblahwhateveryourslackhookis

}
####################################################
resetDEPNotify

initialise_DEPNotify_Settings

#echo "**************"
#echo "shown count $shownCount"
#echo "window limit $windowedTimesLimit"
#echo "**************"
if [[ $shownCount -le $windowedTimesLimit ]]; then
	displayMessageLessThan
else
	displayMessagesMoreThan
fi

checkContinueCompleted

newShownCount=$((shownCount+1))
defaults write com.mycorp.$plistName.message shownCount -int $newShownCount

if [[ $newShownCount -ge $slackNotifyTrigger ]]; then
	echo "slack message sent"
	sendSlackNotification
fi

