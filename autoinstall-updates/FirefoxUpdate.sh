#!/bin/sh
# updateFirefox.sh
#to determine if there's a update for Firefox and, if there is, deploy it

#

date
#

if [ -d "/Applications/Firefox.app" ] ; then
	currentFirefoxVersion=$( defaults read /Applications/Firefox.app/Contents/Info.plist CFBundleShortVersionString
 )
else
	echo "Firefox Not installed."
	exit 0
fi

echo "Installed Firefox version is $currentFirefoxVersion"

# somehow find current version
curl -s -O FireFox*.dmg "https://download.mozilla.org/?product=firefox-latest&os=osx&lang=en-US" > /tmp/firefox.txt

# parse text file to find dmg file name and version
latestFirefoxVersionDMG=$(grep dmg /tmp/firefox.txt | sed 's/.*href=\"\(.*.dmg\).>.*/\1/')
latestFirefoxVersion=$(grep dmg /tmp/firefox.txt | sed 's/.*releases.\(.*\).mac.*/\1/')

echo "Latest Firefox version is $latestFirefoxVersion"
if  [[ "$currentFirefoxVersion" < "$latestFirefoxVersion" ]] ; then
echo Updating Firefox to $latestFirefoxVersion from $currentFirefoxVersion
#download actual dmg file
#echo Getting "$latestFirefoxVersionDMG"
curl -s -o /tmp/Firefox.dmg "$latestFirefoxVersionDMG"

#mount dmg
hdiutil mount -nobrowse "/tmp/Firefox.dmg"
if [ $? = 0 ]; then   # if mount is successful

#remove previous version of firefox
if [ -d /Applications/Firefox.app ]; then
rm -rd /Applications/Firefox.app
fi

#install new version
cp -R /Volumes/Firefox/Firefox.app /Applications
sleep 15
#Unmount
hdiutil detach /Volumes/Firefox
sleep 5
    fi

#remove files
rm /tmp/Firefox.dmg

touch /Applications/Firefox.app

else
echo "Firefox latest is $latestFirefoxVersion and we have $currentFirefoxVersion"
echo "No further action"
fi
rm /tmp/firefox.txt


exit 0