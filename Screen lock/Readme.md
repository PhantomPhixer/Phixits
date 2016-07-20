# Screen locking
A screen lock that displays info from a log file and periodically updates the info.
Originally made to work with Casper deployments.

Not all my own work but I can't remember where I found the base idea of using the ARD lock function with JAMF helper, if it's yours let me know and I'll credit you. 

**The configurable version is designed for use with Casper.**

the user message script is pre installed on the devices.
the configuration script is called through a casper policy and uses casper script variables making it infinitely configurable and reusable.


copy the contents of the message modifier into a casper script object to use, ensure the variables are suitably labeled then add to a policy.

adding a line to the end to run the script itself after configuration;
/Library/Management/user_config_message.sh &&

this allows it to run independently

Set this script to run "before" in the policy, or policy chain, you want to lock the screen for.

create another policy, containing the terminator text "configuration_complete" in the title. I don't add anything to this except a simple payload to check if a file exists.
Set the policy to be scoped to all and triggered by an event, like "configuration_complete"

so somewhere in the policy calling the script, I suggest the execute command section run a jamf policy -event to call the terminator;
sh -c "/usr/local/jamf/bin/jamf policy -trigger configuration_complete"

This means that the modifier runs, sets required text, calls the screen lock. The rest of the policy(ies) run then the terminator is called.
As the script looks for the terminator text in the jamf log it then exits and clears the screen lock.

remember that the script greps from the jamf log every time it runs so be careful with the timeout value.
