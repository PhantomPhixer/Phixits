#!/bin/bash

name="Computer-Info"
version="1.0"

##############################################################
## variables for utilities used in the script
##############################################################

#cocoaDialog app.specify the appbundle rather than the actual binary
cdialog="/Applications/Utilities/cocoaDialog.app"
# cocoa dialog executable, referenced from the cdialog variable path
cdialogbin="${cdialog}/Contents/MacOS/cocoaDialog"
# for corporate branding it is good to use a single brand icon
# I replace the jamfhelper icon to keep the branding when logout polices run so reuse it.
# use whatevr brand file you desire but a nice circle works well 
cdialogicon="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/Resources/Message.png"

# pashua path 
pashua_path="/Applications/Utilities/"
# path to the pashua config script
source "/Applications/Utilities/Pashua.app/Contents/Resources/pashua.sh"

##############################################################

##############################################################
# The functions. 
##############################################################

collectInfo() {
# create a FIFO to pipe into the progress bar
# the info is collected whilst the bar is displayed
	FIFO=/tmp/info

	mkfifo $FIFO
	"$cdialogbin" progressbar --indeterminate  --icon-file "$cdialogicon" --title "My Computer Info is running" --text "Gathering information..." < $FIFO &
	exec 3<> $FIFO
	echo -n . >&3
	
	
	OS_Version=$(sw_vers | grep ProductVersion | cut -d ":" -f 2 | awk '{$1=$1}{ print }')
	computerName=$(scutil --get ComputerName)
	IPAddress=$(ifconfig | grep '\<inet\>' | cut -d ' ' -f2 | grep -v '127.0.0.1' | head -1)

	# check specific app versions. add extra if required and amend the displayInfo to accomodate
	if [ -f "/Applications/Citrix Receiver.app/Contents/Info.plist" ]; then
		CitrixRecieverVersion=$(/usr/bin/defaults read /Applications/Citrix\ Receiver.app/Contents/Info CFBundleShortVersionString)
		else
		CitrixRecieverVersion="Not installed"
	fi
	if [ -f "/Library/Application Support/Citrix/NetScaler Gateway.app/Contents/Info.plist" ]; then
		netscalerVersion=$(/usr/bin/defaults read /Library/Application\ Support/Citrix/NetScaler\ Gateway.app/Contents/Info CFBundleShortVersionString)
		else
		netscalerVersion="Not Installed"
	fi
	if [ -f "/Applications/Cisco/Cisco AnyConnect DART.app/Contents/Info.plist" ]; then
		anyConnectVersion=$(/usr/bin/defaults read /Applications/Cisco/Cisco\ AnyConnect\ DART.app/Contents/Info CFBundleShortVersionString)
		else
		anyConnectVersion="Not Installed"
	fi

	AvailableDiskSpace=$(df -H / | grep / | awk '{ print $4}')

	SerialNumber=$(system_profiler SPHardwareDataType | grep -i "serial number" | cut -d ":" -f2 |cut -d " " -f2) # hardware serial number

	# keep the progress bar up for a short while, make it look like something is going on
	#sleep 2

exec 3>&-
	wait

}

displayInfo () {

# define the info box structure
conf_Display_Info="

# Set window title
*.title = My Computer Info

serialLbl.type = text
serialLbl.default = Serial number
serialLbl.width = 120
serialLbl.x = 1
serialLbl.y = 190

serial.type = text
serial.default = $SerialNumber
serial.width = 100
serial.x = 140
serial.y = 190

IPAddrLbl.type = text
IPAddrLbl.default = IP Address
IPAddrLbl.width = 120
IPAddrLbl.x = 1
IPAddrLbl.y = 140

IPAddr.type = text
IPAddr.default = $IPAddress
IPAddr.width = 100
IPAddr.x = 140
IPAddr.y = 140

OSVerLbl.type = text
OSVerLbl.default = OS Version
OSVerLbl.width = 120
OSVerLbl.x = 1
OSVerLbl.y = 170

OSVer.type = text
OSVer.default = $OS_Version
OSVer.width = 100
OSVer.x = 140
OSVer.y = 170

CTXLbl.type = text
CTXLbl.default = Citrix Version
CTXLbl.width = 120
CTXLbl.x = 1
CTXLbl.y = 110

CTX.type = text
CTX.default = $CitrixRecieverVersion
CTX.width = 100
CTX.x = 140
CTX.y =110

NSLbl.type = text
NSLbl.default = Netscaler Version
NSLbl.width = 120
NSLbl.x = 1
NSLbl.y = 90

NS.type = text
NS.default = $netscalerVersion
NS.width = 100
NS.x = 140
NS.y = 90

ACLbl.type = text
ACLbl.default = AnyConnect Version
ACLbl.width = 120
ACLbl.x = 1
ACLbl.y = 70

AC.type = text
AC.default = $anyConnectVersion
AC.width = 100
AC.x = 140
AC.y = 70

DsLbl.type = text
DsLbl.default = Free disk Space
DsLbl.width = 120
DsLbl.x = 1
DsLbl.y = 40

Ds.type = text
Ds.default = $AvailableDiskSpace
Ds.width = 100
Ds.x = 140
Ds.y = 40

img.type = image
img.x = 1
img.y = 230
img.maxwidth = 50
img.path = $cdialogicon

"
# call the info box
pashua_run "$conf_Display_Info" "$pashua_path"

}


##############################################################
# The launch section. 
##############################################################

collectInfo
displayInfo

# returns here when OK clicked
exit 0
