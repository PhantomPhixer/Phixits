#!/bin/bash

# JSS Switcher tool.
# use this to launch Casper tools and set appropriate JSS
# run as a script or use Automator and make an app for easy distribution
# Mark Lamont Jan 2016
#
# uses Pashua for dialogues 

#######################################################################################
# Variables. update for your installation.
# pref_file_loc is the path containing the plist. $HOME is prepended to this later
# pref_file is the actual plist
# tmp_loc is staging folder
casper_path="/Applications/Casper Suite"
pref_file_loc="/Library/Preferences"
pref_file="/com.jamfsoftware.jss.plist"
tmp_loc="/tmp/com.jamfsoftware.jss.plist"

#######################################################################################
# JSS URL's that can be used. These are used as dropdown choices in the dialog box conf_JSS_select
#######################################################################################

# jss1 is set as default in the selector
jss1="https://mycorpmdm.corp.com:8443"
jss2="https://mycorpsecondmdm.corp.com:8443"


#########################################################################################
# the following are the locations where the program extras are based
# WORKDIR is the folder holding the Pashua.app  The actual path of Pashua is picked up from the source setting.
WORKDIR="/Applications/"

# path to pashua.sh
source "/Applications/Pashua.app/Contents/Resources/pashua.sh"

# customise to company, remove if not required. if not used remove img.type section from conf_JSS_select and resize the fields.
imagepath="/myimagesfoldr/logo.png"


#########
# start of dialog definitions
conf_JSS_select="

# set title
*.title = JSS Selector

url.type = combobox
url.label = Select required JSS.
# set default option here
url.default = $jss1
url.option = $jss2
# add extra options as required. ensure they are adde in the variables list.
# if you have long JSS URL's adjust this.
url.width = 200

app.type = radiobutton
app.label = Select the application to launch
app.option = Admin
app.option = Remote
app.default = Admin


# add the company logo if required. 
img.type = image
img.x = 1
img.y = 185
img.maxwidth = 125
img.path = $imagepath

# launch button
db.type = defaultbutton
db.label = Launch

# cancel button
cb.type = cancelbutton
cb.label = Quit

"

###################################
### Dialog functions start here ###
###################################
dialog_JSS_select () {

pashua_run "$conf_JSS_select" "$WORKDIR"

# exit if Quit selected otherwise carry on #
if [ $cb = "1" ]; then
exit 0
fi

}

##############################################
### Start of actual program loop           ###
### display dialogs in conditional order   ###
##############################################

dialog_JSS_select

echo "jss choice: $url"
echo "app selected: $app"

if [ "$app" = "Admin" ]; then
app="Casper Admin.app"
fi
if [ "$app" = "Remote" ]; then
app="Casper Remote.app"
fi

#############################################
# build plist file with correct jss         #
#############################################
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
<key>allowInvalidCertificate</key>
<false/>
<key>url</key>
<string>$url/</string>
</dict>
</plist>" > "$tmp_loc"

#############################################
# Delete existing plist and copy new one    #
#############################################
rm -f "$HOME$pref_file_loc$pref_file"
cp "$tmp_loc" "$HOME$pref_file_loc$pref_file"
# tidy up staging
rm -f "$tmp_loc"

########################################
#         network connectivity checks  #
########################################
# if connection fails throw warning and exit
mdmping=$(echo $url | cut -d ":" -f 2 | sed 's/[^A-Za-z.]*//g')

mdmpingresult=$( ping -c 1 $mdmping | grep icmp* | wc -l )

if [ $mdmpingresult -eq 0 ]
then
    echo "*** connection to $mdmping failed."
	osascript -e 'tell app "System Events" to display dialog "Network Connection to JSS failed. Exiting application" buttons {"OK"} default button "OK" with icon caution with title "Network Connection Failed"'
	exit 0
else
	echo "*** $mdmping is alive"
fi

########################################
# launch the selected application      #
########################################
open "$casper_path/$app"




