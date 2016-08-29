# AirDefense

 original by Ed Childers posted on Jamf nation to stop wifi being active when ethernet is connected and active.
# https://jamfnation.jamfsoftware.com/discussion.html?id=5916
modified by Mark Lamont to change a couple of small things
1. do not automatically turn wifi ON continually when Ethernet Not plugged in.
this allows wifi to be turned off when not required or not allowed such as on a plane.
2. only operate on a set wifi. This was added because in our environment it is only required to have the no wifi on ethernet functionality to prevent use of ISE licenses by an unused network.
the basic functionality is the same only two changes
 1. added a loop to check if on specified wifi when on ethernet
 2. commented out the last section to always turn on wifi

to use it package up the plist as a launchDaemon and the drop this script in /Library/Scripts
