#!/bin/bash


# EA to record VM's on a machine in Parallels
# setup EA as a string.
VM=/Users/$USER/Documents/Parallels/*.pvm
    for f in $VM
    do
		cat "$f/VmInfo.pvi" | grep -E 'RealOsVersion' | sed 's/RealOsVersion//g' |grep -v "unknown" | sed 's/<>//g' | sed 's/<\/>//g' 
    done
    
echo "<result>$V</result>"