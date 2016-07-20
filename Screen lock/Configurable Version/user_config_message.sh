#!/bin/sh
# Script that locks the computer and displays a message
# can't be bypassed

#####################
#    Mark Lamont    #
#    July 15 2016   #
#####################


# variables for portability
# these can be changed by the calling script 
terminator="configuration_complete"

title_variable="title text"
heading_variable="heading text"
window_type="hud"
pause="15"


# INVOKE ARD's Lock Screen and move on to the JAMF Helper
/System/Library/CoreServices/RemoteManagement/AppleVNCServer.bundle/Contents/Support/LockScreen.app/Contents/MacOS/LockScreen &

# Window Title
title="$title_variable"

# Window Heading
heading="$heading_variable"

# set run to yes to keep loop running until termination required
run="yes"

######## start main (and only!) loop #########
loop_ctr=1
until [ "$run" = "no" ]
do
    loop_ctr=$((loop_ctr+1))
	description=`tail  -n 3 /var/log/jamf.log | awk -F: '{print $4}'`
	
	# add check to see if termination is required. if value matches then end_loop sets to 1
	end_loop=`echo ${description} | grep -ic $terminator`
	if [ "$end_loop" = "1" ]; then
		run="no"
	fi
	
	/Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType $window_type -windowPosition centre -title "$title" -alignHeading left -heading "$heading" -alignDescription left -description "$description" -lockHUD -icon /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png &

# pause for a short while
sleep $pause

#run="no"

# kill jamfhelper to allow it to restart in the loop with new info
/usr/bin/killall jamfHelper

done	
#########  end main loop ##########

# kill lockscreen to return to desktop
/usr/bin/killall LockScreen

exit 0
