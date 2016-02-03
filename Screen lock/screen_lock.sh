#!/bin/sh
# Script that locks the computer and displays a message

#INVOKE ARD's Lock Screen and move on to the JAMF Helper
/System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/LockScreen.app/Contents/MacOS/LockScreen &

#Window Title
title=" Build In Progress"

#Window Heading
heading="This Mac is rebuilding. Log messages are shown here to show progress.   Screen refreshes every 60 seconds"

run="yes"

loop_ctr=1
until [ "$run" = "no" ]
do
    loop_ctr=$((loop_ctr+1))
	description=`tail  -n 3 /var/log/jamf.log`
	
	echo "loop counter: $loop_ctr"
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType fs -windowPosition centre -title "$title" -alignHeading left -heading "$heading" -alignDescription left -description "$description" -lockHUD -icon /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png &

	sleep 60
	ps axco pid,command | grep jamfHelper | awk '{ print $1; }' | xargs kill -9

done	
