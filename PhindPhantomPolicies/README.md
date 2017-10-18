# Finds policies left in JSS when using Casper Remote

jamf PI-002589
Casper Remote Task Creates Policy entry in DB and is viewable via API list of Policies

if you use the api you can end up pulling in a load of policies that have the name format
 'data time | user | number of devices assigned'

Not much use and can be deleted

This scpirt lists them  out and writes to a txt file delimited by ||
columns are ID || policy name
