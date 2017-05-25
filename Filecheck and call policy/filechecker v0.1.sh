#!/bin/bash

#########################################################
# script to check the contents                          #
# of a file and run a policy based                      #
# on the result                                         #
# mark lamont May 2017                                  #
# use at your own discression and test test test first. #
#########################################################

name="fileChecker"
version="0.1"

# input variables set in the jss policy

# fileNameToCheck  is the full path and the file name
fileNameToCheck="$4"
#echo "$4"
# the string to look for
textToCheck="$5"
#echo "$5"
# call a policy based upon the result
policyTriggerToCall="$6"
#echo "$6"
# what number represents an invalid state required to 
# trigger the policy. if value is there the answer is 1
# if not then the value is 0. Set this to be the opposite value to whatever is valid.
isInValid="$7"
#echo "$7"

# log file path and name.
logto="/var/log/"
log="my.log"


jamfBinary="/usr/local/bin/jamf"

secho()
{	
	message="$1"
	
		echo "$name: $message"
		echo "$(date "+%a %b %d %H:%M:%S") $HOSTNAME $name-$version : $message" >> "$logto/$log"

}

takeAction() {
# put whatever action you need in here

# calls the policy as a separate process and allows the script to exit 
 secho "Doing the action bit... hang tight!"
$jamfBinary policy -event $policyTriggerToCall &

}

checkFileExists(){
	if [ ! -f "$fileNameToCheck" ]; then
		secho "$fileNameToCheck doesn't exist..."
		secho "Calling policy"
		takeAction
		secho "Finished...."
		exit 0
	fi
}

checkFile() {
# checks the file and returns answer as a 1 or 0
trueOrFalse=$(cat "$fileNameToCheck" | grep -c "$textToCheck")
secho "check value is $trueOrFalse"

}

checkParameters(){
if [ "$fileNameToCheck" == "" ] || [ "$textToCheck" == "" ] || [ "$policyTriggerToCall" == "" ] || [ "$isInValid" == "" ]; then
	secho "Warning! one or parameters missing... Exiting!"
	secho "Finished...badly sob :-("
	exit 0
fi
}

isValid() {
	#echo "isInValid = $isInValid"
	#echo "trueOrFalse = $trueOrFalse"
	if [ "$isInValid" == "$trueOrFalse" ]; then
		secho "check for $textToCheck failed, calling policy"
		takeAction
	else
		secho "check for $textToCheck passed, NFA"
	fi

}

#######################
secho "Start....."

checkParameters

checkFileExists

checkFile

isValid

secho "Finished....."


