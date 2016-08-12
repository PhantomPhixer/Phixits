#!/bin/sh

# $4 = Time setting
# allowed values are cut down version of allowed OS values
# off = 0
# 5 = 5mins
# 20 = 20 mins
# 60 = 60 mins
# failover value is 10 mins

#Get current user
user=`ls -l /dev/console | cut -d " " -f 4`
# echo "current user is $user"

input=`echo $4`

# echo "input value is $input"

case $input in
	0)
	timeOut="0"
	;;
	5)
	timeOut="300"
	;;
	20)
	timeOut="1200"
	;;
	60)
	timeOut="3600"
	;;
	*)
	timeOut="600"
	;;
esac

#Set Screensaver to kick in, in number of secconds
sudo -u $user defaults -currentHost write com.apple.screensaver idleTime -int $timeOut
# sudo -u $user defaults -currentHost read com.apple.screensaver idleTime

sudo -u $user killall cfprefsd