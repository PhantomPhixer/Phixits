#!/bin/bash

# creates a launchDaemon and script to run the appleloops tool
# https://github.com/carlashley/appleloops
# this downloads the mandatory loops (-m)
# if you want all the loops including optional then use --deployment -m -o --quiet

# simply put this into jamf as a script and call it in  policy as part of the build or appleloops install 

# replace myedu with appropriate vales, especially in the network live check

# run at your own risk of course
# and of course this is a handy method for creating any kind of launchdaemon and script
# make sure you / the $ signs in variable names in th escript if you use it for something else


####################
# the script      ##
####################

/bin/echo "#!/bin/bash

# Wait for Internet Connection

internetLive=0

until [ "\$internetLive" == "200" ]; do
	echo "Waiting for Internet"
	internetLive=\$(curl -s -k https://myedu.jamfcloud.com/healthCheck.html --write-out %{http_code} -o /dev/null)
	sleep 1
done

/usr/local/bin/appleloops --deployment -m --quiet

exit 0" > /Library/Management/myedu/runAppleLoops.sh
#Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/Management/myedu/runAppleLoops.sh
/bin/chmod 755 /Library/Management/myedu/runAppleLoops.sh

########################
# The launchDaemon     #
########################

cat << EOF > /Library/LaunchDaemons/com.myedu.runAppleLoops.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.myedu.runAppleLoops</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>-c</string>
        <string>/Library/Management/myedu/runAppleLoops.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF
##Set the permission on the file just made.
/usr/sbin/chown root:wheel /Library/LaunchDaemons/com.myedu.runAppleLoops.plist
/bin/chmod 644 /Library/LaunchDaemons/com.myedu.runAppleLoops.plist