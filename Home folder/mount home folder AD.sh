#!/bin/bash

##################################
# AD home folder mounting script
# uses two variables to automate
# domain dynamically works out the AD domain
# home_drive is the mount point
# Mark Lamont July 2015
#################################


# $USER is a system variable for the current logged in user.

COCOA_DIALOG='/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoadialog'
iconpath="/path to an optional icon"

domain=`dsconfigad -show | grep -i "active directory domain" | awk '{print $5}'`
echo "Domain = $domain"

home_drive="/Volumes/$USER"
echo "Home Folder Mount: $home_drive"

#######################
## Mount drive function

mount_drive () {

short_domain=`echo $domain | cut -d "." -f1 | tr "[:lower:]" "[:upper:]"`
echo "short domain = $short_domain"

smbhome=`dscl "/Active Directory/$short_domain/All Domains" -read /Users/$USER SMBHome | awk '{print \$2}' | tr '\' '/'` 

echo "smbhome = $smbhome"
smbserver=`echo $smbhome | cut -c 3- | cut -d "/" -f1`
echo "smbserver = $smbserver"
 
 	### check if smbserver is available and mount if it is
	if ping -c 1 $smbserver &> /dev/null ; then
		echo "mounting $smbhome"
		mkdir "$home_drive" 
		mount -t smbfs $smbhome "$home_drive"
		
		$COCOA_DIALOG bubble --debug --titles "HomeFolder Mounted" \
	--texts "Your Home Folder has been mounted. A shortcut is on your desktop for quick access." \
	--border-colors "2100b4" "a25f0a"                 \
	--text-colors "180082" "000000"                   \
	--background-tops "aabdcf" "dfa723"               \
	--background-bottoms "86c7fe" "fdde88"            \
	--icon-file "$iconpath"  \
	
	
		echo "Creating shortcut"
		ln -s "$home_drive"/ ~/Desktop/$USER
			else
		echo "$smbserver not available!"
		exit 0
	fi

}

## End map drive
#######################


#######################################
# check if drive is already mounted
if [ -d "$home_drive" ]; then
	umount "$home_drive"
	echo "Home drive already mounted, dismounted"
#	exit 0
fi

#########################################
# check if AD is contactable
if ping -c 1 $domain &> /dev/null ;then
mount_drive
else
echo "$domain not contactable! Exiting"
exit 0
fi

exit 0