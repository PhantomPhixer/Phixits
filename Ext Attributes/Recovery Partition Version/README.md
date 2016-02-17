# Recovery Partition Version
The script does the following;
Finds the recovery HD
mounts it
reads the version info
unmounts it
writes the info to a receipt.

the casper extension attribute reads the receipt.

This way the script can be put in a policy and run occasionally, weekly, monthly etc and the EA will update accordingly.

