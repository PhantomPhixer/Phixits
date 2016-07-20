#!/bin/bash

##################################################################
# script to modify contents of the build info script #
# mark lamont july 2016
# 
# uses casper script variable as shown below
# title = $4
# heading = $5
# window type = $6
# sleep delay = $7
# type is any applicable jamf helper window type, fs hud utility
###################################################################




orig_title=`cat /Library/Management/user_config_message.sh | grep title_variable= | awk -F= '{ print $2}' | sed 's/"//g'`
orig_heading=`cat /Library/Management/user_config_message.sh | grep heading_variable= | awk -F= '{ print $2}' | sed 's/"//g'`
orig_type=`cat /Library/Management/user_config_message.sh | grep window_type= | awk -F= '{ print $2}' | sed 's/"//g'`
orig_pause=`cat /Library/Management/user_config_message.sh | grep pause= | awk -F= '{ print $2}' | sed 's/"//g'`



new_title=`echo $4`
new_heading=`echo $5`
new_type=`echo $6`
new_pause=`echo $7`


# use sed to replace the original values with new values
# sed uses " (double quotes) instead of ' (single quote) to allow the use of variables
sed -i .bak "s/$orig_title/$new_title/" /Library/Management/user_config_message.sh

# remove the .bak file for tidyness
rm /Library/Management/user_config_message.sh.bak

sed -i .bak "s/$orig_heading/$new_heading/" /Library/Management/user_config_message.sh
rm /Library/Management/user_config_message.sh.bak

sed -i .bak "s/$orig_type/$new_type/" /Library/Management/user_config_message.sh
rm /Library/Management/user_config_message.sh.bak

sed -i .bak "s/$orig_pause/$new_pause/" /Library/Management/user_config_message.sh
rm /Library/Management/user_config_message.sh.bak
