#!/bin/bash

#This script will retrieve all policies in the jss that casper remote created
# note if you use | in your policy name it will include them but they will be easy to spot in the output


########### EDIT THESE ##################################
JSSURL="https://jss.company.com:443"
user="apireadonlyuser"
pass="password"
workingDir="/path/to/store/files/in/remotepolicies/"
############################################################


JSS="$JSSURL/JSSResource"

# path to files
mkdir $workingDir 2>/dev/null
remotePoliciesList="$workingDir"remotepolicieslist.txt


#get policies
curl -H "Accept: application/xml" -sfku "$user:$pass" "$JSS/policies" -X GET | xmllint --format - > "$workingDir"policies.xml


#loop through Policies
policyList=`cat "$workingDir"policies.xml |grep -i \<id\>|awk -F\> '{print $2}'|awk -F\< '{print $1}'`
arr=($policyList)

# create file headers
echo "policy ID||Policy Name|---|---" > "$remotePoliciesList"
#get all policies from JSS and build a list of scripts used
for thisPolicy in "${arr[@]}"; do

# comment out if not needed
    echo "
       ############################"
    echo "Working on Policy $thisPolicy"

# find policy name from the list
policyName=`grep -A1 "<id>$thisPolicy</id>" "$workingDir"policies.xml |grep "<name>" |awk -F\> '{print $2}'|awk -F\< '{print $1}'`
# comment out if not needed
echo "name is $policyName"

policyNameChecked=$(echo "$policyName" | grep -c "|" )
if [[ "$policyNameChecked" != "0" ]]; then
	echo "+++++++++++++++++++++++++++++++"
	echo "$policyName is a remote policy"
	echo "+++++++++++++++++++++++++++++++"
	# sleep 1
	echo "$thisPolicy||$policyName" >> "$remotePoliciesList"

else
	echo "$policyName is NOT a remote policy"
fi

done

echo "++++++ Done +++++++++++++++++++++++++++++++"

