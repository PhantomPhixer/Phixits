
#!/bin/sh

if [ -f "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app/Contents/Info.plist" ] ; then
	VERSION=$( defaults read "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app/Contents/MacOS/Microsoft AU Daemon.app/Contents/Info" CFBundleVersion )
else
	VERSION="Not installed"
fi

echo "<result>$VERSION</result>"


