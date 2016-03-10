#!/bin/bash

# feed in $username to make this work


loop="smb"
while [ $loop = "smb" ]
	do
	check=`security find-internet-password  -a $username -D "Network Password" -r "smb " |  grep acct | awk -F "=" '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`

if [[ $check != "" ]]; then
	security delete-internet-password  -a $username -D "Network Password" -r "smb "
else
loop="smbdone"
fi
done


loop="afp"
while [ $loop = "afp" ]
	do
	check=`security find-internet-password  -a $username -D "Network Password" -r "afp " |  grep acct | awk -F "=" '{ print $2 }' | sed -e 's/^"//' -e 's/"$//'`

if [[ $check != "" ]]; then
	security delete-internet-password  -a $username -D "Network Password" -r "afp "
else
loop="afpdone"
fi
done



 
