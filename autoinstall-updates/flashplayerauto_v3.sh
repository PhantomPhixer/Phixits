#!/bin/sh


########################################################
# mark lamont 2019                                     #
# use at own risk - test it and test again             #
# this will update flash player to the latest version  #
# will also remove any V10/V20 versions as they won't  #
# update and are clearly very old and not in use       #
#                                                      #
# can be tweake dto be an install script if you really #
# have a need to install Flash! Shudder.....           #
########################################################


# V2. reordedered logic
# delete flash 10 before installing
# made into functions
# V3 remove if flash 10 or 20

dmgfile="flash.dmg"
volname="Flash"
logfile="/var/log/flash_update.log"


# Determine if the installed version is older than the current version of Flash
flashPlayer="/Library/Internet Plug-Ins/Flash Player.plugin"

getCurrentVersion () {

if [ ! -e "$flashPlayer" ]
    then
        currentinstalledver="0"
        echo "Flash Player is not installed" >> ${logfile}
        echo "Flash Player is not installed"
        exit 0
    else        
        
        currentinstalledver=`/usr/bin/defaults read "${flashPlayer}/Contents/version" CFBundleShortVersionString`
        #### test version data
        ### currentinstalledver="20.10.10.0"
        echo "Flash Player v${currentinstalledver} is installed"
        shortinstalledver=${currentinstalledver:0:2}
        echo "Installed short version is $shortinstalledver"
        
fi

}

findLatestVersion () {
# get latest version info
latestver=`/usr/bin/curl --connect-timeout 8 --max-time 8 -sf "http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml" 2>/dev/null | xmllint --format - 2>/dev/null | awk -F'"' '/<update version/{print $2}' | sed 's/,/./g'`
shortver=${latestver:0:2}
echo "short version = $shortver"
url="https://fpdownload.adobe.com/get/flashplayer/pdc/${latestver}/install_flash_player_osx.dmg"

}

compareVersionsAndInstall () {
# Compare the two versions, if they are different then download and install the new version.
if [ "${currentinstalledver}" != "${latestver}" ]; then

    echo "Current Flash version: v${currentinstalledver}" >> ${logfile}
    echo "Available Flash version:  v${latestver}" >> ${logfile}

    echo "Downloading Flash Player v${latestver}." >> ${logfile}
    echo "Downloading Flash Player v${latestver}."
    #/usr/bin/curl -s -o `/usr/bin/dirname $0`/flash.dmg $url
    /usr/bin/curl -s -o /tmp/flash.dmg $url
    
    

    echo "Mounting installer disk image." >> ${logfile}
    echo "Mounting installer disk image."
    #/usr/bin/hdiutil attach `dirname $0`/flash.dmg -nobrowse -quiet
    /usr/bin/hdiutil attach /tmp/flash.dmg -nobrowse -quiet



    echo "Installing..." >> ${logfile}
    echo "Installing..."
    /usr/sbin/installer -pkg /Volumes/Flash\ Player/Install\ Adobe\ Flash\ Player.app/Contents/Resources/Adobe\ Flash\ Player.pkg -target / > /dev/null
    /bin/sleep 10

    echo "Um Mounting installer disk image." >> ${logfile}
    echo "Un Mounting installer disk image."
    /usr/bin/hdiutil detach $(/bin/df | /usr/bin/grep ${volname} | awk '{print $1}') -quiet
    /bin/sleep 10

    echo "Deleting disk image." >> ${logfile}
    echo "Deleting disk image."
    /bin/rm -Rf /tmp/flash.dmg

    newlyinstalledver=`/usr/bin/defaults read "/Library/Internet Plug-Ins/Flash Player.plugin/Contents/version" CFBundleShortVersionString`
    if [ "${latestver}" = "${newlyinstalledver}" ]; then
        echo "SUCCESS: Flash has been updated to version ${newlyinstalledver}" >> ${logfile}
        echo "SUCCESS: Flash has been updated to version ${newlyinstalledver}"
        /usr/local/bin/jamf recon
    else
        echo "ERROR: Flash update unsuccessful, version remains at ${currentinstalledver}." >> ${logfile}
        echo "ERROR: Flash update unsuccessful, version remains at ${currentinstalledver}."
        echo "--" >> ${logfile}
    fi

# If Flash is already up to date, exit.    
else
    echo "Flash is already up to date, running ${currentinstalledver}." >> ${logfile}
    echo "Flash is already up to date, running ${currentinstalledver}."
fi

}

removeFlash10or20 () {
# remove really old versions
if [ "$shortinstalledver" = "10" ] || [ "$shortinstalledver" = "20" ]; then
    echo "Removing Flash $shortinstalledver" >> ${logfile}
    echo "Removing Flash $shortinstalledver"
    rm -Rf "/Library/Internet Plug-Ins/Flash Player.plugin"
    echo "Flash removed - no further action"
    /usr/local/bin/jamf recon
    exit 0
fi
    
}

#################
# script
#################


getCurrentVersion

removeFlash10or20

findLatestVersion

compareVersionsAndInstall


exit 0