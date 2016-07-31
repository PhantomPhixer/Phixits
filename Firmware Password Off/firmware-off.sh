#!/bin/sh


# see https://montysmacmusings.wordpress.com/2016/07/31/switch-off-firmware-password/
# for more info

# replace <password> with actual password
 

if [ ! -f /usr/sbin/firmwarepasswd ]; then

echo " using regproptool"
/Library/Application\ Support/JAMF/bin/setregproptool -d -o <password>

else
echo " using firmwarepasswd"
DeletePassword=$(/usr/bin/expect <<- DONE
			spawn sudo /usr/sbin/firmwarepasswd -delete
			expect "Enter password:"
			send "<password>\r"
DONE)

fi

# tidy up

rm -f /Library/Application\ Support/JAMF/bin/firmware-off.sh