#!/bin/bash

#####################################################################################################
#
# ABOUT THIS PROGRAM
#
# NAME
#   CitrixWorkspaceUpdate.sh -- Installs or updates Citrix Workspace
#
# SYNOPSIS
#   sudo CitrixWorkspaceUpdate.sh
#
# LICENSE
#   Distributed under the MIT License
#
# EXIT CODES
#   0 - Citrix Workspace is current
#   1 - Citrix Workspace installed successfully
#   2 - Citrix Workspace NOT installed
#   3 - Citrix Workspace update unsuccessful
#   4 - Citrix Workspace is running
#   5 - Not an Intel-based Mac
#
# these are logged but not passed to jamf as anything other than 0 is a failed script
#
####################################################################################################
#
# HISTORY
#
#   Version: 1.6
#   - v.1.7 Mark Lamont  15.05.2019  : made a whole bunch of tidy ups of bits I added for debug and changed logic round app running check
#   - v.1.6 Mark Lamont  15.05.2019  : made some changes to how the version check works, only uses xx.xx and made it so only two exit codes: 0 and 1 so jaf doesn't flag false fails for a success.
#   - v.1.5 Alex Waddell 22.02.2019  : Fixed (for real this time) various version parsing and normalisation issues, resolved exit code problems
#   - v.1.4 Alex Waddell 11.12.2018  : Fixed various version parsing and normalisation issues, resolved exit code 3 problem
#   - v.1.3 Peter Wreiber 09.19.2018  : Added support for Citrix Workspace
#   - v.1.2 Brian Monroe, 05.31.2016 : Fixed downloads and added regex for version matching
#   - v.1.1 Luie Lugo, 10.18.2016 : Updated for v12.3, also cleaned up download URL handling
#   - v.1.0 Luie Lugo, 09.05.2016 : Updates Citrix Receiver
#
####################################################################################################
# Script to download and install Citrix Workspace.

# Setting variables
WorkspaceProcRunning=0
contactinfo="IT Support"

# Echo function
echoFunc () {
    # Date and Time function for the log file
    fDateTime () { echo $(date +"%a %b %d %T"); }

    # Title for beginning of line in log file
    Title="InstallLatestCitrixWorkspace:"

    # Header string function
    fHeader () { echo $(fDateTime) $(hostname) $Title; }

    # Check for the log file
    if [ -e "/Library/Logs/CitrixWorkspaceUpdateScript.log" ]; then
        echo $(fHeader) "$1" >> "/Library/Logs/CitrixWorkspaceUpdateScript.log"
    else
        cat "" > "/Library/Logs/CitrixWorkspaceUpdateScript.log"
        if [ -e "/Library/Logs/CitrixWorkspaceUpdateScript.log" ]; then
            echo $(fHeader) "$1" >> "/Library/Logs/CitrixWorkspaceUpdateScript.log"
        else
            echo "Failed to create log file, writing to JAMF log"
            echo $(fHeader) "$1" >> "/var/log/jamf.log"
        fi
    fi

    # Echo out
    echo $(fDateTime) ": $1"
}

# Exit function
exitFunc () {
    case $1 in
        0) exitCode="0 - Citrix Workspace is current! Version: $2";;
        1) exitCode="1 - SUCCESS: Citrix Workspace has been updated to version $2";;
        2) exitCode="2 - ERROR: Citrix Workspace NOT installed!";;
        3) exitCode="3 - ERROR: Citrix Workspace update unsuccessful, version remains at $2!";;
        4) exitCode="4 - ERROR: Citrix Workspace is running.";;
        5) exitCode="5 - ERROR: Not an Intel-based Mac.";;
        6) exitCode="6 - ERROR: Wireless connected to a known bad WiFi network that won't allow downloading of the installer! SSID: $2";;
        *) exitCode="$1";;
    esac
    echoFunc "Exit code: $exitCode"
    echoFunc "======================== Script Complete ========================"
    # if exit code is expected the exit 0 else exit 1 so it shows correctly in jamf
    if [ "$1" = "0" ] || [ "$1" = "1" ] || [ "$1" = "4" ]; then
    echo "exit 0"
    exit 0
    else
    echo "exit 1"
    exit 1
    fi
}

# Check to see if Citrix Workspace is running
WorkspaceRunningCheck () {
    isRunning=$(ps ax | grep "Citrix Workspace" | grep -v grep | wc -l | sed 's/ //g')
    echoFunc "isRunning is $isRunning"
    if [[ $isRunning == 0 ]]
    then
          echoFunc "Workspace is NOT running, continuing"  
    else
    # Workspace is running, 
        echoFunc "Workspace is running, get out of here"
        WorkspaceRunning
    fi
}

WorkspaceRunning () {
# workspace running. let's not interupt and we'll wait 'till next run'

# tidy up
echoFunc "tidying up downloaded dmg"
rm /tmp/${dmgfile}
exitFunc 4

}


echoFunc ""
echoFunc "======================== Starting Script ========================"


# Are we running on Intel?
if [ '`/usr/bin/uname -p`'="i386" -o '`/usr/bin/uname -p`'="x86_64" ]; then
    ## Get OS version and adjust for use with the URL string
    OSvers_URL=$( sw_vers -productVersion | sed 's/[.]/_/g' )

    ## Set the User Agent string for use with curl
    userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X ${OSvers_URL}) AppleWebKit/535.6.2 (KHTML, like Gecko) Version/5.2 Safari/535.6.2"

    # Get the latest version of Workspace available from Citrix's Workspace page.
    latestver=``
    while [ -z "$latestver" ]
    do
        latestver=`curl -s -L https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html#ctx-dl-eula-external | grep "<h1>Citrix " | awk '{print $4}'`
    done
    if [[ ${latestver} =~ ^[0-9]+\.[0-9]+$ ]]; then
        latestvershort=${latestver:0:4}
    fi
    latestvernorm=`echo ${latestver}`
    echoFunc "Latest Available Citrix Workspace Version for install is: $latestvernorm"
    echoFunc "latest version to compare is $latestvershort"

    # default value, stays at this if not installed
    currentinstalledvernorm="0000"

    # Get the version number of the currently-installed Citrix Workspace, if any.
     if [ -e "/Applications/Citrix Workspace.app" ]
     then
         currentinstalledapp="Citrix Workspace"
         currentinstalledver=`/usr/bin/defaults read /Applications/Citrix\ Workspace.app/Contents/Info CFBundleShortVersionString`
         echoFunc "Current installed version in full: $currentinstalledver"
         if [[ ${currentinstalledver} =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{0,2}$ ]];
         then
            currentinstalledvernorm=$( echo $currentinstalledver | sed -e 's/[.]//g' )
            currentinstalledvernorm=${currentinstalledvernorm:0:4}
            #echoFunc "Installed version $currentinstalledvernorm"
         else 
            currentinstalledvernorm=${currentinstalledver:0:4}
            currentinstalledvernorm=$( echo $currentinstalledvernorm | sed -e 's/[.]/0/g' )
            #echoFunc "Installed version $currentinstalledvernorm"
         fi

         echoFunc "Current installed version to compare is: $currentinstalledvernorm"
         if [ ${latestvershort} = ${currentinstalledvernorm} ]; then
             exitFunc 0 "No update needed as ${currentinstalledapp} ${currentinstalledvernorm} is current version"
         fi
     fi



    # Build URL and dmg file name
    CRCurrVersNormalized=$( echo $latestver | sed -e 's/[.]//g' )
    echoFunc "CRCurrVersNormalized: $CRCurrVersNormalized"
    url1="https:"
    url2=`curl -s -L https://www.citrix.com/downloads/workspace-app/mac/workspace-app-for-mac-latest.html#ctx-dl-eula-external | grep dmg? | sed 's/.*rel=.\(.*\)..id=.*/\1/'`
    url=`echo "${url1}${url2}"`
    echoFunc "Latest version of the URL is: $url"
    dmgfile="Citrix_work_${CRCurrVersNormalized}.dmg"

    # Compare the two versions, if they are different or Citrix Workspace is not present then download and install the new version.
        if [ "${currentinstalledvernorm}" != "${latestvershort}" ]

    then
        echoFunc "Current Installed Workspace version: ${currentinstalledapp} ${currentinstalledvernorm}"
        echoFunc "Available Workspace version : ${latestvershort} => ${currentinstalledvernorm}"

        echoFunc "Downloading newer version."
        curl -s -o /tmp/${dmgfile} ${url}
        case $? in
            0)
                echoFunc "Checking if the file exists after downloading."
                if [ -e "/tmp/${dmgfile}" ]; then
                    WorkspaceFileSize=$(du -k "/tmp/${dmgfile}" | cut -f 1)
                    echoFunc "Downloaded File Size: $WorkspaceFileSize kb"
                fi
                echoFunc "Checking if Workspace is running before we install"
                WorkspaceRunningCheck
                echoFunc "Mounting installer disk image."
                hdiutil attach /tmp/${dmgfile} -nobrowse -quiet
                echoFunc "Installing Citrix Workspace v$latestver"
                echo "$(date +"%a %b %d %T") Installing Citrix Workspace v$latestver" >> /var/log/CitrixWorkspaceInstall.log
                /usr/sbin/installer -pkg "/Volumes/Citrix Workspace/Install Citrix Workspace.pkg" -target / >> /var/log/CitrixWorkspaceInstall.log # > /dev/null

                sleep 10
                echoFunc "Unmounting installer disk image."
                /sbin/umount /Volumes/Cit*
                sleep 10
                echoFunc "Deleting disk image."
                rm /tmp/${dmgfile}

                sleep 10
                #double check to see if the new version got update
                if [ -e "/Applications/Citrix Workspace.app" ]
                then
                    newlyinstalledver=`/usr/bin/defaults read /Applications/Citrix\ Workspace.app/Contents/Info CFBundleShortVersionString`
                    echoFunc "Newly installed version is: $newlyinstalledver"

                    if [[ ${newlyinstalledver} =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{0,2}$ ]];
                    then
                        newlyinstalledvernorm=$( echo $newlyinstalledver | sed -e 's/[.]//g' )
                        newlyinstalledvernorm=${newlyinstalledvernorm:0:4}
                        echoFunc "Installed version now $newlyinstalledvernorm"
                    else 
                        newlyinstalledvernorm=${newlyinstalledver:0:4}
                        newlyinstalledvernorm=$( echo $newlyinstalledvernorm | sed -e 's/[.]/0/' )
                        echoFunc "Installed version now $newlyinstalledvernorm"
                        if [[ ${newlyinstalledvernorm} =~ ^[0-9]+\.[0-9]+$ ]]; then
                        echoFunc "installed version tweaked $newlyinstalledvernorm"
                         fi
                    fi

                    if [ "${latestvershort}" = "${newlyinstalledvernorm}" ]
                    then
                        echoFunc "SUCCESS: Citrix Workspace has been updated to version ${newlyinstalledvernorm}, issuing JAMF recon command"
                        jamf recon
                        if [ $WorkspaceProcRunning -eq 1 ]
                        then
                            /Library/Application\ Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper -windowType hud -lockHUD -title "Citrix Workspace Updated" -description "Citrix Workspace has been updated to version ${newlyinstalledvernorm}." -button1 "OK" -defaultButton 1
                        fi
                        exitFunc 0 "${newlyinstalledvernorm}"
                    else
                        exitFunc 3 "${currentinstalledapp} ${currentinstalledvernorm}"
                    fi
                else
                    exitFunc 3 "${currentinstalledapp} ${currentinstalledvernorm}"
                fi
            ;;
            *)
                echoFunc "Curl function failed on download! Error: $?. Review error codes here: https://curl.haxx.se/libcurl/c/libcurl-errors.html"
            ;;
        esac
    else
        # If Citrix Workspace is up to date already, just log it and exit.
        exitFunc 0 "No update needed as ${currentinstalledapp} ${currentinstalledvernorm} is current version"
    fi
else
    # This script is for Intel Macs only.
    exitFunc 5
fi