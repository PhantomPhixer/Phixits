#!/bin/bash

username="name to check for"

check=`dscl . read /Users/$username | grep RecordName | cut -d ":" -f 2 | sed 's/ //g'`
if [ "$check" = "$username" ]; then
result="Yes"
else
result="No"
fi

echo "<result>$result</result>"