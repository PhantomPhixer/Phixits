#!/bin/bash

####################################
#     Mark Lamont                  #
# script to run from launchD       #
# to check if jamf still working   #
# and attempt to fix if not        #
####################################
# use at your own risk.            # 
# test, test and test some more    #
# before using it.                 #
####################################


name="jamfcheckFix"
version="1.0"


# log file path and name.
###############################################
# change logname and path to suit your needs  #
# all the tools and scripts we write log to   #
# one cnetral log for ease of use.            #
###############################################
logto="/var/log/"
log="mycorp.log"


# jamf binary location
jamfBinary="/usr/local/jamf/bin/jamf"
# jss url. not dynamically calculated as may heve been unenrolled.
JSSURL="https://myjss.company.com"
PING="google.com"

# this is the name of the trigger event used to call the test policy
check_policy_trigger="checkjsspolicy"
# this is the result that will show in the jamf log when the policy is run
check_policy_result="jss_check_ok"

######################################################################################
# the logging function. I copied this from patchoo. use it in all my scipts now
secho()
{
	
	message="$1"
	
		#echo "$name: $message"
		echo "$(date "+%a %b %d %H:%M:%S") $HOSTNAME $name-$version : $message" >> "$logto/$log"

}

# function to run quickadd
quickadd () {
# reinstall jamf with quickadd after downloading it from Akamai
# we store the quickadd on our cloud distro, you will need to set this up to suit your extrenally, and internally, available location

secho "Downloading QuickAdd"
curl -L -o /tmp/QuickAdd.pkg 'http://mybucket.akamaihd.net/QuickAdd.pkg'

secho "Installing QuickAdd"
# install the quickadd pkg
installer -pkg /tmp/QuickAdd.pkg -target /


date=$(date +%Y-%m-%d)
	
# write to receipt for EA
# have set up an EA to record the reason why quickadd reinstalled. populated on a recon
# you can put this where you want or not even use it but useful for reporting
echo "$date|$reason" > /Library/Receipts/mycorp/Auto_Renroll_Date

# send slack notification to dedicated channel.
sendSlack
# tidy up
rm /tmp/QuickAdd.pkg


}


checkjss () {
##################################################################	
# this function checks if the jss is available                   #
# in this set there are external and internal jss,               #
# the external has the web app disabled, common enough setup,    #
# so this gives an easy indication which side is being used.     #
# if no response then jss isn't available so no point trying     #
# anything else this time so it exits                            #
##################################################################	
secho "Checking JSS"
loop_ctr=0
mdmconnected=0
while [ $mdmconnected -eq 0 ]; do
	#loop_ctr=$((loop_ctr+1))
    mdmup=$(curl --silent  --insecure ${JSSURL})
   	mdmconnectedInt=$(echo $mdmup | grep -c 'password')

   	mdmconnectedExt=$(echo $mdmup | grep -c 'Web Application Disabled')
   	secho "mdmconnectedInt = $mdmconnectedInt"
   	secho "mdmconnectedExt = $mdmconnectedExt"
   	if [ "$mdmconnectedInt" = "1" ] || [ "$mdmconnectedExt" = "1" ]; then
   		secho "JSS is available"
   		mdmconnected=1
   	fi
   	loop_ctr=$((loop_ctr+1))
	if [ $loop_ctr -eq 5 ]; then
	secho "Unable to curl to JSS, NFA"
	exit 0
	fi
done	

}


jss_is_up () {


jss_up=$(/usr/local/jamf/bin/jamf checkJSSConnection -retry 3 | grep -c available)
	
		secho "jss_up state = $jss_up"

}

run_test_policy () {

secho "Running check policy"

/usr/local/jamf/bin/jamf policy -event $check_policy_trigger
sleep 5
check_policy_ran=$(tail  -n 5 /var/log/jamf.log | awk -F: '{print $4}' | grep $check_policy_result)

secho "check policy result: $check_policy_result"
if [ "$check_policy_ran" = "" ]; then


secho "Policy result not achieved."
# run quickadd
reason="Policy not running"
quickadd

# re run this loop
run_test_policy

else
secho "Check policy result ok"
secho "Check jamf script end"
exit 0
fi



}


check_network() {
##########################################################	
# check network is available or the script is pointless  #
##########################################################	

ping_result=$(ping -c 3 $PING &> /dev/null && echo success || echo fail)
			if [ "$ping_result" = "fail" ]; then
		# no network so no point in trying any more
				secho "No network available. NFA possible"
				secho "Check jamf script end"
				exit 0
			fi

}

sendSlack() {
##########################################################################################	
# you need a configured slack channel, in this example it is called jamf-self-fix-alerts #
# setup webhooks and put your url in the curl command                                    #
##########################################################################################	
serial=$(system_profiler SPHardwareDataType | grep -i "serial number" | cut -d ":" -f2 |cut -d " " -f2)

now=$(date +"%D")
curl -X POST --data-urlencode 'payload={"channel": "#jamf-self-fix-alerts", "username": "'$name'", "text": "@channel '$serial' has reinstalled binary on '$now' because '$reason'"}' https://hooks.slack.com/services/zzzzzz/xxxxxx/yyyyyyyyyyyyyyy


}
########################################################
#   MAIN PROGRAM CODE 
########################################################
secho "Check jamf script start"
# Check we have network or no point proceeeding
check_network
# does jamf binary exist?
# then check if jssconnection is ok
if [ -e $jamfBinary ];then
secho "Binary Present."
		
		jss_is_up
		
				if [ "$jss_up" != "1" ]; then
					secho "jamf not connecting. Network ok."
					reason="JSS Check Failure"
					# checkJSSConnection failed so check if jss is actually connectable
					checkjss
					# so jss is contactable so reenroll with quickadd
					quickadd
					# run the test policy
					run_test_policy

				else
		
					run_test_policy
					# if script returns here test policy failed for unknown reason
					# exit and wait for next time. could just be timing so no point in reinstalling
					secho "unkown failure of check policy - exiting"
					secho "Check jamf script end"
					exit 0
				fi
else
reason="jamf_binary_missing"
# stuff here is if jamf binary NOT found
secho "No jamf Binary"
checkjss
quickadd
jss_is_up
run_test_policy

fi 

