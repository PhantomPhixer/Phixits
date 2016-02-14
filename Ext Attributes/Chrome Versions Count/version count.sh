#!/bin/bash

#Google Chrome versions count.
cd /Applications/Google\ Chrome.app/Contents/Versions/

versions=`ls -p | grep "/$" | wc -l | sed 's/ //g'`

if [ "$versions" = "" ]; then
versions="0"
fi

echo "<result>$versions</result>"