#!/bin/bash

# launchDaemon and Agent creator
# feed it with;
# launcher type =  Daemon or Agent
# launchItem = path to the app being launched, the full path to the executable
# launcherPlistName = unique bit of the plist name. it will be com.mycorp.{unique bit}.plist
# isScriptIn = is this a script yes or no. defines which plist will be used
####################################################
# Use at your own risk!
####################################################
# mark lamont Jan 2018

launcherTypeIn="$4"
launchItem="$5"
launcherPlistName="$6"
isScriptIn="$7"
# set input strings to lower to avoid case failure
launcherType=$(echo $launcherTypeIn | tr '[:upper:]' '[:lower:]')
isScript=$(echo $isScriptIn | tr '[:upper:]' '[:lower:]')
#echo "$launchItem"

# 
case "$launcherType" in
	
	"daemon" )
	#echo "**** Daemon ****"
	launchFolder="LaunchDaemons"
	;;

	"agent" )
	#echo "**** Agent ****"
	launchFolder="LaunchAgents"
	;;

	*)
		echo "**** no launcher type selected. Exiting *****"
		exit 1
	;;
esac

case "$isScript"  in

	"no" )

cat << EOF > /Library/${launchFolder}/com.mycorp.${launcherPlistName}.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mycorp.${launcherPlistName}</string>
    <key>ProgramArguments</key>
    <array>
        <string>${launchItem}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

	;;

	"yes" )

cat << EOF > /Library/${launchFolder}/com.mycorp.${launcherPlistName}.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mycorp.${launcherPlistName}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>${launchItem}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

	;;

	*)
		echo "**** no type selected. Exiting *****"
		exit 1
	;;
esac

/usr/sbin/chown root:wheel /Library/${launchFolder}/com.mycorp.${launcherPlistName}.plist
/bin/chmod 644 /Library/${launchFolder}/com.mycorp.${launcherPlistName}.plist
