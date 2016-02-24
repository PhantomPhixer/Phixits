#!/bin/bash

# Mark Lamont Aug 2015
# printer installation for AD joined devices with users logging in with AD credentials.
# forces authentication for all users.
# defaults to mono and not shared.
# paper size default A4
# implements load spreading across 4 load balancers
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

# Example print install line from Canon
# /usr/sbin/lpadmin -p MacPrintSA -E -v lpd://APRINTLBA.corp.com/MacPrintSA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=A4

## Random print queue selection routine, uses 1 - 4 to select print choices.

randNum=$(jot -r 1 1 4)

echo "Random printer option is option $randNum"

if [ "$randNum" == "1" ] 
then
	/usr/sbin/lpadmin -p MacPrintSA -E -v lpd://APRINTLBA.corp.com/MacPrintSA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	/usr/sbin/lpadmin -p MacPrintGA -E -v lpd://BPRINTLBA.corp.com/MacPrintGA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	lpoptions -d MacPrintGA
	exit 0
fi

if [ "$randNum" == "2" ] 
then
	/usr/sbin/lpadmin -p MacPrintGB -E -v lpd://BPRINTLBB.corp.com/MacPrintGB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	/usr/sbin/lpadmin -p MacPrintSB -E -v lpd://APRINTLBB.corp.com/MacPrintSB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	lpoptions -d MacPrintGB
	exit 0
fi

if [ "$randNum" == "3" ] 
then
	/usr/sbin/lpadmin -p MacPrintGB -E -v lpd://BPRINTLBB.corp.com/MacPrintGB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	/usr/sbin/lpadmin -p MacPrintSA -E -v lpd://APRINTLBA.corp.com/MacPrintSA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false  -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	lpoptions -d MacPrintGB
	exit 0
fi

if [ "$randNum" == "4" ] 
then
	/usr/sbin/lpadmin -p MacPrintGA -E -v lpd://BPRINTLBA.corp.com/MacPrintGA -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue A' -o printer-is-shared=false -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	/usr/sbin/lpadmin -p MacPrintSB -E -v lpd://APRINTLBB.corp.com/MacPrintSB -P /Library/Printers/PPDs/Contents/Resources/CNMCIRAC7065S2.ppd.gz -D 'uniFLOW LPR queue B' -o printer-is-shared=false -o CNColorMode=mono -o CNFinisher=BFINB1 -o PageSize=*A4
	lpoptions -d MacPrintGA
	exit 0
fi

