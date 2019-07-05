#!/bin/bash

################################################################################################
# script to take multiple inputs and use them to fire multiple jamf policy -event triggers.    #
# uses $4--11                                                                                  #
# script will exit out when it detects no more policies to try                                 # 
# Mark Lamont Mar 2019                                                                       #
################################################################################################

###########################################
# if 8 aren't enough what are you doing!? #
###########################################
policyTrigger1="${4}"
policyTrigger2="${5}"
policyTrigger3="${6}"
policyTrigger4="${7}"
policyTrigger5="${8}"
policyTrigger6="${9}"
policyTrigger7="${10}"
policyTrigger8="${11}"


################
# debug lines. #
################
#echo "$policyTrigger1"
#echo "$policyTrigger2"
#echo "$policyTrigger3"
#echo "$policyTrigger4"
#echo "$policyTrigger5"
#echo "$policyTrigger6"
#echo "$policyTrigger7"
#echo "$policyTrigger8"


############################
# run sequentially.        #
# when no input found exit #
############################
if [ "$policyTrigger1" != "" ]; then
	jamf policy -event $policyTrigger1
else
	echo "No work to do at all!"
	exit 0
fi

if [ "$policyTrigger2" != "" ]; then
	jamf policy -event $policyTrigger2
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger3" != "" ]; then
	jamf policy -event $policyTrigger3
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger4" != "" ]; then
	jamf policy -event $policyTrigger4
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger5" != "" ]; then
	jamf policy -event $policyTrigger5
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger6" != "" ]; then
	jamf policy -event $policyTrigger6
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger7" != "" ]; then
	jamf policy -event $policyTrigger7
else
	echo "no more work to do"
	exit 0
fi

if [ "$policyTrigger8" != "" ]; then
	jamf policy -event $policyTrigger8
else
	echo "no more work to do"
	exit 0
fi

echo "all 8 policies triggered, good work everyone!"
exit 0