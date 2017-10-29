# jamf binary selffix
There are a few ideas for checking whether the jamf binary is installed and working.
For a bit of fun I wrote my own and it works quite well.

**Requirements**
in the jss create policy a policy, the policy needs two things;
- name of *jss_check_ok*
- Trigger set to *checkjsspolicy*

The policy is scoped to all computers.
These are used in the script to check everything is working.

a quickadd package is required, it should be kept up to date as the jss version gets updated, and needs to be available from any location both internal and external if your devices roam. I use akamai as it's used for a cloud distro in my environment.

*optional*
the script is built to fire a webhook to a specified slack channel. you can comment this out if not used

**How does it work?**
- check if there is connectivity to the internet - exit if not
- check jssCheckConnection 
- run check policy

based an various other tests if the *jssCheckConnection* fails then the quickadd will be installed.
