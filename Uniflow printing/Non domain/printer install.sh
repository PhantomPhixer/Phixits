																					#!/bin/bash
# modified by Mark Lamont 
# Date: 6 Oct 2015


## defaults to mono and not shared.
# paper size default A4
# implements load spreading across 4 load balancers
# This package will install two print queues for the user, selecting from a pool of four queues, 2 in each Datacentre 
# One queue is randomly selected from each Datacentre, and no two queues will be installed from the same Datacentre.


# # # ==================================================================================================== # # # 

### PRINT QUEUES DETAILS

## Queue Option A ---------------------------------------- ****
 
### APRINTLBA - MacPrintSA - 10.x.x.x– with the display named uniFLOW Queue A
###                           
### BPRINTLBA - MacPrintGA - 10.x.x.x– with the display named uniFLOW Queue B
 
## Queue Option B ---------------------------------------- ****
 
### APRINTLBB - MacPrintSB - 10.x.x.x– with the display named uniFLOW Queue A
###                           
### BPRINTLBB - MacPrintGB - 10.x.x.x– with the display named uniFLOW Queue B
 
## Queue Option C ---------------------------------------- ****
 
### APRINTLBA - MacPrintSA - 10.x.x.x– with the display named uniFLOW Queue A
###                           
### BPRINTLBB - MacPrintGB - 10.x.x.x– with the display named uniFLOW Queue B
 
## Queue Option D ---------------------------------------- ****
 
### APRINTLBB - MacPrintSB - 10.x.x.x– with the display named uniFLOW Queue B
###                           
### BPRINTLBA - MacPrintGA - 10.x.x.x– with the display named uniFLOW Queue A

### =========================================

###--SERVER----------IP---------QUEUE-NAME
## APRINTLBA - 10.x.x.x – MacPrintSA
## APRINTLBB - 10.x.x.x – MacPrintSB
## BPRINTLBA - 10.x.x.x – MacPrintGA
## BPRINTLBB - 10.x.x.x – MacPrintGB

### =========================================

prUser=""

#Prompt for username to use in print setup to allow connection to printers
if [ "X$prUser" = "X" ]; then
        prUser=`/usr/bin/osascript <<EOF
        tell application "System Events"
        activate
        display dialog "Please enter your Username:" default answer "" buttons {"OK"} default button 1
        set the prUser to text returned of the result
        return prUser
        end tell
        EOF`
fi

#If still no account name found quit
if [ "X$prUser" = "X" ]; then
	osascript -e 'tell app "System Events" to display alert "No  Account Name" message " No Account name found - no changes made. The installation has been abandoned" '
	exit 1
fi



##### Remove any secureprint queue if exist

sudo lpadmin -x MacPrintGA 
sudo lpadmin -x MacPrintGB
sudo lpadmin -x MacPrintSA
sudo lpadmin -x MacPrintSB

## Pause for 2 seconds
sleep 2

## Random print queue selection routine, uses 1 - 4 to select print choices.
randNum=$(jot -r 1 1 4)

if [ "$randNum" == "1" ] 
then
	/usr/sbin/lpadmin -p MacPrintSA -E -v lpd://$prUser@APRINTLBA.corp.com/MacPrintSA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	/usr/sbin/lpadmin -p MacPrintGA -E -v lpd://$prUser@BPRINTLBA.corp.com/MacPrintGA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	lpoptions -d MacPrintGA
fi

if [ "$randNum" == "2" ] 
then
	/usr/sbin/lpadmin -p MacPrintGB -E -v lpd://$prUser@BPRINTLBB.corp.com/MacPrintGB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	/usr/sbin/lpadmin -p MacPrintSB -E -v lpd://$prUser@APRINTLBB.corp.com/MacPrintSB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	lpoptions -d MacPrintGB
fi

if [ "$randNum" == "3" ] 
then
	/usr/sbin/lpadmin -p MacPrintGB -E -v lpd://$prUser@BPRINTLBB.corp.com/MacPrintGB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	/usr/sbin/lpadmin -p MacPrintSA -E -v lpd://$prUser@APRINTLBA.corp.com/MacPrintSA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	lpoptions -d MacPrintGB
fi

if [ "$randNum" == "4" ] 
then
	/usr/sbin/lpadmin -p MacPrintGA -E -v lpd://$prUser@BPRINTLBA.corp.com/MacPrintGA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false -o CNColorMode=mono -o CNFinisher=BFINB1
	/usr/sbin/lpadmin -p MacPrintSB -E -v lpd://$prUser@APRINTLBB.corp.com/MacPrintSB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1
	lpoptions -d MacPrintGA
fi

# End of print queue assignment
