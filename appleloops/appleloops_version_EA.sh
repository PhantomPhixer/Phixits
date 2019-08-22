#!/bin/bash

# EA to report appleloops version

version="Not installed"
if [ -f /usr/local/bin/appleloops ]; then
    version=$(/usr/local/bin/appleloops -v 2>&1 | cut -d ' ' -f 2)
fi

echo "<result>$version</result>"