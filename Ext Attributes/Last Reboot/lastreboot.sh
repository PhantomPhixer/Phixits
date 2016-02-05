#!/bin/sh

# Purpose of this Script: This script will return number of days since last restart
# Author: Mark Lamont
# Date Created: 26th Jun 2015
# Version History:
# 1.0 - Initial Draft of the script created

result=`last reboot | head -1 | cut -d "~" -f2 | awk -F' ' '{print $1,$3,$2,$4,$5}'`

echo "<result>$result</result>"