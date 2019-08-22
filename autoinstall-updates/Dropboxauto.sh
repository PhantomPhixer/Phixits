#!/bin/bash

########################################################
# mark lamont 2019                                     #
# use at own risk - test it and test again             #
# this will update Dropbox to the latest version       #
# Can be used as an install script by using $4         #    
# runMode is required to install.                      #
# if nothing set then will default to update mode.     #

# Note: install mode will NOT update                   #
#       update mode will NOT install                   #
# so if it's installed then install mode exits         #
# and if it's not installed update mode exits          #
########################################################

runMode=${4}

dmgfile="/tmp/dropbox.dmg"


logfile="/var/log/dropbox_update.log"

downloadLatestVersion () {

# remove any previous downloads
rm -f "$dmgfile"

echo "Downloading DMG from Dropbox.com" >> $logfile
# pull down the latest version
curl -s -L "https://www.dropbox.com/download?plat=mac&full=1" > "$dmgfile"
# check download ok
if [ -f "$dmgfile" ]; then
        WorkspaceFileSize=$(du -k "${dmgfile}" | cut -f 1)
        echo "Downloaded File Size: $WorkspaceFileSize kb" >> $logfile
    echo "Download ok" >> $logfile
else
    echo "Download Failed!!! Exiting" >> $logfile
    exit 1
fi

}

findLatestVersion () {
# dropbox doesn't seem to maintain an easy feed of version releases so we need to pull it from the app in the dmg!
# downloadLatestVersion
echo "Mounting DMG" >> $logfile
hdiutil attach ${dmgfile} -nobrowse -quiet
sleep 5
latestVersion=$(defaults read /Volumes/Dropbox\ Installer/Dropbox.app/Contents/Info.plist CFBundleShortVersionString
)

echo "Downloaded version is $latestVersion" >> $logfile

}


findLocalVersion () {
localVersion=$(defaults read /Applications/Dropbox.app/Contents/Info.plist CFBundleShortVersionString
)
echo "local version is $localVersion" >> $logfile

}

compareVersions () {
if [ "$localVersion" = "$latestVersion" ]; then
	echo "Versions match" >> $logfile
	tidyUp
    echo "Completed *******************" >> $logfile
	exit 0
else
	echo "versions do not match, update required" >> $logfile

fi

}

checkIfRunning () {
# need to check if Dropbox is running, if it is stop it before upgrade
PIDs=$(pgrep Dropbox | grep -v "no matching")
echo "dropbox running is $PIDs" >> $logfile
if [ "$PIDs" = "" ]; then
    echo "Dropbox not running" >> $logfile
    appRunning="no"
else
    echo "Dropbox is running, will stop then restart it" >> $logfile
    appRunning="yes"
fi
}

performInstall () {
# install only
# but first double check there isn't already an installed version
findLocalVersion
if [ "$localVersion" = "" ]; then
echo "Confirmed no local version exists so proceed with install" >> $logfile
downloadLatestVersion
findLatestVersion
# this now means the dmg is mounted
echo "Copying app bundle" >> $logfile
cp -R /Volumes/Dropbox\ Installer/Dropbox.app/ /Applications/Dropbox.app
sleep 1
chown -R root:wheel /Applications/Dropbox.app
chmod -R 755 /Applications/Cyberduck/Dropbox.app

else
    echo "Install called but app exists already! doing nothing *******" >> $logfile
    #tidyUp
    echo "Completed *******************" >> $logfile
    exit 0
fi

}

isInstalled () {
if [ "$localVersion" = "" ]; then
    echo "Update initiated but app not installed! *********" >> $logfile
    tidyUp
    echo "Completed *******************" >> $logfile
    exit 1
fi

}
performUpdate () {
# this does an update if already installed. If not installed we shouldn't update it.

    echo "Performing update" >> $logfile
    if [ "$appRunning" = "yes" ]; then
        echo "Stopping Dropbox" >> $logfile
        killall Dropbox
        sleep 5
    fi

    echo "Deleting previous version" >> $logfile
    rm -Rf /Applications/Dropbox.app

    echo "Copying app bundle" >> $logfile
    cp -R /Volumes/Dropbox\ Installer/Dropbox.app/ /Applications/Dropbox.app
    sleep 1
    chown -R root:wheel /Applications/Dropbox.app
    chmod -R 755 /Applications/Cyberduck/Dropbox.app        

    if [ "$appRunning" = "yes" ]; then
        echo "Starting Dropbox" >> $logfile
        open -a Dropbox
        sleep 5
    fi



}


tidyUp () {
# tidy things up
echo "Tidying up" >> $logfile
/sbin/umount /Volumes/Drop*
sleep 10
rm -Rf ${dmgfile}


}

##########################################
echo "Starting **************************" >> $logfile


case $runMode in

	"--install" )
    echo "Install selected" >> $logfile
	# downloadLatestVersion
	performInstall
	tidyUp
    echo "Install completed ******************" >> $logfile
	exit 0
	;;

	* )
	# default mode is update
    echo "Update is selected" >> $logfile
	findLocalVersion
    isInstalled
    downloadLatestVersion
	findLatestVersion
	compareVersions
    checkIfRunning
	performUpdate
	tidyUp
    echo "Update completed ******************" >> $logfile
    exit 0
	;;

esac