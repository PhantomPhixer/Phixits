#######################################
###  This is not a complete script  ###
###  It is a collection of bits for ###
###  a password checking function   ###
###  for use in scripts where you   ###
###  need people to set passwords   ###
####################################### 





## CocoaDialog paths
CD_APP="/Applications/Utilities/cocoaDialog.app" # Location of the App 
CD="$CD_APP/Contents/MacOS/CocoaDialog" # Location of the binary
imagepath="/<imagepath>/icon.png"

#### Include pashua.sh to be able to use the 2 functions defined in that file ####
#### functions are pashua_run and locate_pashua  #####
# path to pashua.app
pashua_path="/Applications/"
# path to pashua.sh
source "/Applications/Pashua.app/Contents/Resources/pashua.sh"


scriptname="myscript"



#########################################
# password length and disallowed words list for use in check_pwd_valid routine
required_length="8"
not_allowed="password complex c0mplex welcome letmein qwerty baseball football master superman trustno1 qwertyuiop wanker ihatework passw0rd starwars bigboobs hello monday tuesday wednesday thursday friday saturday sunday"
#
#########################################

##### start of local account password screen ########################################
# This screen asks the user to enter a password that will be used when the local account is created.
conf_local_pwd="
*.title = Set Local Account Password

# Password box x2. 
lpass2.type = password
lpass2.label = Retype the Password:
lpass2.width = 180
lpass2.x = 1
lpass2.y = 75

lpass1.type = password
lpass1.label = Type a Password:
lpass1.width = 180
lpass1.x = 1
lpass1.y = 125

# this example is to set a local account password
txt.type = text
txt.default = *** End User ***[return][return]Set a password that you will use to secure your Mac.[return][return]This should NOT be the same as your Corp account password[return][return]It should be 8 characters minimum, contain at least one CAPITAL and one number.[return]Do not use common simple passwords.[return][return]Try using a pass phrase instead of a single word.[return][return]If it does not meet the requirements it will be rejected and you will need to set a different one.
txt.width = 250
txt.x = 250
txt.y = 75


# add the corp logo
img.type = image
img.x = 1
img.y = 200
img.maxwidth = 100
img.path = $imagepath

# set button.
lpassbutt.type = defaultbutton
lpassbutt.label = Set password

"

######################### Messages section. uses cocoa dialog ##############
## Display the dialog box warning about passwords fitting security criteria
display_pwd_invalid ()
{
failed_match=($($CD msgbox --title "Warning" --icon "x" --text "The password does not meet security policy" --no-newline --informative-text "Minimum 8 characters, upper case and a number, no common passwords
	Please try again" --button1 "Set new password" ))
	
}


## Display the dialog box warning about passwords not matching
display_pwd_match_fail () 
{
failed_match=($($CD msgbox --title "Warning" --icon "x" --text "The passwords do not match" --no-newline --informative-text "Your typed passwords do not match.
	Please try again" --button1 "Reenter password" ))
	
}


########################## functions section. #################################
# check password complexity 
check_pwd_valid () {

echo "$(date) $scripname: password valid checker"

# reset password_valid for subsequent loops
password_valid="0"


# Check password length. Set password_fail variable if too short
if [ "${#lpass1}" -ge "${required_length}" ]; then
 echo "$(date) $scripname: Password length ok."
else
password_valid="1"
 echo "$(date) $scripname: Password too short." 
fi

# check for upper case [A-Z], lower case [a-z], number [0-9] and non alpha char [^a-z0-9]
# Caps
echo "$lpass1" | grep -q '[A-Z]' || password_valid="1"
# echo "$(date) $scripname: [A-Z] password_valid = $password_valid"
#lowercase
echo "$lpass1" | grep -q '[a-z]' || password_valid="1"
# echo "$(date) $scripname: [a-z] password_valid = $password_valid"
#numbers
echo "$lpass1" | grep -q '[0-9]' || password_valid="1"
# echo "$(date) $scripname: [0-9] password_valid = $password_valid"
# non alpha
 echo "$lpass1" | grep -iq '[^a-z0-9]' || password_valid="1"
 # echo "$(date) $scripname: [0-9] password_valid = $password_valid"


# check for not_allowed words. if a word is not allowed variable is set
for WORD in $not_allowed
do
	echo "$lpass1" | grep -iqv "$WORD" || password_valid="1"
done


# check if password has failed.
if [ "$password_valid" = "1" ]; then
echo "$(date) $scripname: password failed checks"
password_invalid="1"
else
echo "$(date) $scripname: password passed checks"
password_invalid="0"
userpass=`echo ${lpass1}`
#echo "$(date) $scripname: password debug do not leave in! *****"
# echo "$(date) $scripname: password set as: $userpass"
#echo "$(date) $scripname: password debug       *****************"

fi

}


# dialog to request user set local password.
# this is using pashua because I like it!
dialog_local_pwd () {

pashua_run "$conf_local_pwd" "$pashua_path"

# check passwords match and set variable used in check routine
if [ "$lpass1" != "$lpass2" ]; then
	pwd_match_fail="1"
	else
	pwd_match_fail="0"
	
fi
}


#################### main script part #############################

dialog_local_pwd # calls the dialog 

# if passwords don't match then loop round until they do
while [ $pwd_match_fail = "1" ]
	do
	echo "$(date) $scripname: pwd match = failed"
	echo "$(date) $scripname: pwd match = $pwd_match_fail"
	display_pwd_match_fail
	dialog_local_pwd
	done


check_pwd_valid
#if password not valid loop round until do
while [ $password_invalid = "1" ]
	do
	echo "$(date) $scripname: pwd invalid = true"
	echo "$(date) $scripname: pwd invalid = $password_invalid"
	echo "$(date) $scripname: Showing password invalid dialog"
	display_pwd_invalid
	echo "$(date) $scripname: Showing password dialog"
	dialog_local_pwd
	echo "$(date) $scripname: Checking validity"
	check_pwd_valid
	done

