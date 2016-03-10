# Keychain items find and delete
whilst writing a password management script I needed a way to tidy the users keychain so wrote this.
In this example it is specific to smb and afp passwords for the specified username to avoid accidental deletions.

Simply loops round smb networks passwords until none left then repeat for afp.

