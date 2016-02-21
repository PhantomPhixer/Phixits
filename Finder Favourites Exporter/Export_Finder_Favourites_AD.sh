#!/bin/bash

##################################
# finder favourites export for AD joined machines
# uses home foldermapping script
# AD home folder mounting script
# uses two variables to automate
# domain dynamically works out the AD domain
# home_drive is the mount point
# Mark Lamont July 2015
#################################

iconpath="path to an png file to use in a dialog"

COCOA_DIALOG='/Applications/Utilities/cocoaDialog.app/Contents/MacOS/cocoadialog'

domain=`dsconfigad -show | grep -i "active directory domain" | awk '{print $5}'`
echo "Domain = $domain"

# $USER is a system variable for the current logged in user.

home_drive="/Volumes/$USER"
echo "Home Folder Mount: $home_drive"

# manage hidden file
if [ ! -d ~/.hf ]; then
mkdir ~/.hf
echo "Creating .hf folder"
else
echo ".hf folder exists"
fi

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
			else
		echo "$smbserver not available!"
		exit 0
	fi

}

## End map drive
#######################

list_and_copy () {


echo "Home drive mounted"
		if [ ! -d "$home_drive/MyFinderConnections" ]; then
		mkdir "$home_drive/MyFinderConnections"
		fi
	# find all finder favourite connections
	touch ~/.hf/connection_list.txt
	defaults read ~/Library/Preferences/com.apple.sidebarlists.plist favoriteservers | grep URL | cut -d "=" -f2 |sed s'/";*//g' > ~/.hf/connection_list.txt
	result=`cat ~/.hf/connection_list.txt`
	echo "Server list  is: $result"
	sleep 5
	# copy file to home folder
	cp -f ~/.hf/connection_list.txt "$home_drive/MyFinderConnections/"
		if [ -f "$home_drive/MyFinderConnections/connection_list.txt" ]; then
		echo "Copied successfully"
		#----------------------
	$COCOA_DIALOG bubble --debug --titles "Export Complete" \
	--texts "Your Finder list has been saved in your Home folder in the MyFinderConnections folder. " \
	--border-colors "2100b4" "a25f0a"                 \
	--text-colors "180082" "000000"                   \
	--background-tops "aabdcf" "dfa723"               \
	--background-bottoms "86c7fe" "fdde88"            \
	--icon-file "$iconpath"  \
	
	
		exit 0
		fi
		exit 0
}


#########################################
# check if AD is contactable
if ping -c 1 $domain &> /dev/null ;then
echo "domain contactable"
else
echo "$domain not contactable! Exiting"
osascript -e 'tell app "System Events" to display dialog "Cannot connect to the company network.\nPlease check your network and try again. " buttons {"OK"} default button "OK" with icon caution with title "Network Connection Error"'
exit 0
fi

#######################################
# check drive is  mounted
if [ -d "$home_drive" ]; then
	list_and_copy
	echo "Home drive already mounted, list and copy"
 		else
 	echo " home drive not mounted, mount drive and list and copy"
 	mount_drive
	list_and_copy
fi



exit 0