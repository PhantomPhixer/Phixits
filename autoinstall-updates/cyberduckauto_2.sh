#!/bin/bash

# cyberduck updater
# V2 added Cyberduck installer in case statement

# runMode is required to install. if nothing set then will default to update mode
runMode=${4}

cyberduckZIP="/tmp/cyberduck.zip"
cyberduckUnzip=/tmp/cyberduckUnzip/
cyberduckinfo="/tmp/cyberduckinfo"

findLocalVersion () {
# find local version
if [ -e /Applications/Cyberduck.app/Contents/Info.plist ]; then
	localVersion=$(/usr/bin/defaults read "/Applications/Cyberduck.app/Contents/Info.plist" CFBundleShortVersionString)
	echo "local version is $localVersion"
	else
	echo "Cyberduck not installed"
	updateInventory
	exit 0
	fi
}

findLatestVersion () {
# find remote version


/usr/bin/curl -s https://version.cyberduck.io/changelog.rss > $cyberduckinfo
latestVersion=$(cat $cyberduckinfo | grep "shortVersionString" | sed 's/sparkle:shortVersionString=//' | sed 's/"//g' | sed 's/^[[:space:]]*//')
echo "latest version is $latestVersion"

latestVersionURL=$(cat $cyberduckinfo | grep "url=" | sed 's/url=//' | sed 's/"//g' | sed 's/^[[:space:]]*//')
# echo "url is $latestVersionURL"


# Check we have info to work with
if [ "$latestVersion" = "" ] || [ "$latestVersionURL" = "" ]; then
	echo "No version info found, exiting"
	exit 1
else
	echo "latest vesion is $latestVersion"
fi
}

compareVersions () {
if [ "$localVersion" = "$latestVersion" ]; then
	echo "Versions match"
	tidyUp
	exit 0
else
	echo "versions do not match"
	downloadLatestVersion

fi


}

checkIfCyberDuckRunning () {
 isCyberDuckRunning=$(ps ax | grep Cyberduck.app | grep -v grep | grep -c Cyberduck.app)

 if [ "$isCyberDuckRunning" -ge "1" ]; then
 	echo "Cyberduck running, wait until next time"
 	exit 0
 else
 	# do the do
 	echo "Cyberduck not running"
 fi
}

updateInventory () {

/usr/local/bin/jamf recon

}

downloadLatestVersion () {
checkIfCyberDuckRunning

/usr/bin/curl -s --retry 3 -Lo "$cyberduckZIP" "$latestVersionURL"

unzip -q "$cyberduckZIP" -d "$cyberduckUnzip"

if [ -d "$cyberduckUnzip/Cyberduck.app" ]; then
	echo "Cyberduck.app downloaded"
	install="yes"
else
	echo "download failed! Exiting"
	exit 0
fi

}

performUpdate () {
if [ "$install" = "yes" ]; then
	checkIfCyberDuckRunning
	rm -Rf /Applications/Cyberduck.app
	mv "$cyberduckUnzip/Cyberduck.app" /Applications/Cyberduck.app
	chown -R root:wheel /Applications/Cyberduck.app
	chmod -R 755 /Applications/Cyberduck.app
	confirmApplied
	updateInventory
else
	echo "How did this reach here!"
fi


}

performInstall () {

mv "$cyberduckUnzip/Cyberduck.app" /Applications/Cyberduck.app
chown -R root:wheel /Applications/Cyberduck.app
chmod -R 755 /Applications/Cyberduck.app

}

confirmApplied () {

localVersionNow=$(/usr/bin/defaults read "/Applications/Cyberduck.app/Contents/Info.plist" CFBundleShortVersionString)
	echo "local version is $localVersionNow"

if [ "$localVersionNow" = "$latestVersion" ]; then
	echo "Versions match, upgrade complete"
else
	echo "upgrade failed!"
	exit 1
fi

}

tidyUp () {

if [ -f "$cyberduckinfo" ]; then
	rm -Rf "$cyberduckinfo"
fi
if [ -f "$cyberduckZIP" ]; then
rm -Rf "$cyberduckZIP"
fi 
if [ -d "$cyberduckUnzip" ]; then
rm -Rf "$cyberduckUnzip"
fi

}


case $runMode in

	"--install" )
	findLatestVersion
	downloadLatestVersion
	performInstall
	tidyUp
	exit 0
	;;

	* )
	# default mode is update
	tidyUp
	findLocalVersion
	findLatestVersion
	compareVersions
	performUpdate
	tidyUp
	;;

esac

