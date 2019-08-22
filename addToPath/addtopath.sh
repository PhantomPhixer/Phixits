#!/bin/bash


# Set new pathPlug-Ins/JavaAppletPlugin.plugin/Contents/Home/" >> /etc/bashrc
# takes in two variables from Jamf
# adds file and path to /etc/paths for path.d to pick up
fileName="${4}"
newPath="${5}"


touch /private/etc/paths.d/"$fileName"

echo "$newPath" > /private/etc/paths.d/"$fileName"
