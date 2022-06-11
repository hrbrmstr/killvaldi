#!/bin/ksh
# KillValdi — stop Vivaldi from inserting itself into the login items.
# Author: @hrbrmstr
echo
echo "This script will install a ksh job file in ~/.local/launchd/killvaldi.sh"
echo "and a new launchd property list (~/Library/LaunchAgents/is.rud.killvaldi.plist)"
echo "which work in conjunction to remove Vivaldi from startup items ever 3,600 seconds"
echo "(i.e. 1 hour — you can modify this value in the script or property list directly)."
echo 
echo "NOTE: no error checking will be performed, and if you already have KillValdi"
echo "set up, you should CTRL-C right now and follow the instructions at the end of this"
echo "script before continuuing, otherwise hit RETURN/ENTER."
echo
echo -n "Press RETURN/ENTER to continue; CTRL-C to quit"

read  key

echo "Creating ~/.local/launchd directory to store launchd job script"

mkdir -p "${HOME}/.local/launchd"

echo "Writing ~/.local/launchd/killvaldi.sh"

cat <<EOF >${HOME}/.local/launchd/killvaldi.sh
#!/bin/ksh
items=\$(osascript -e 'tell application "System Events" to get the name of every login item')

if [[ "\${items}" =~ Vivaldi ]]; then
	osascript -e 'tell application "System Events" to delete login item "Vivaldi"' 
fi
EOF

chmod 755 ${HOME}/.local/launchd/killvaldi.sh

echo "Writing ~/Library/LaunchAgents/is.rud.killvaldi.plist launchd property list"

cat <<EOF >${HOME}/Library/LaunchAgents/is.rud.killvaldi.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>is.rud.killvaldi</string>
    <key>ProgramArguments</key>
    <array>
        <string>${HOME}/.local/launchd/killvaldi.sh</string>
    </array>
    <key>StartInterval</key>
    <integer>3600</integer>
</dict>
</plist>
EOF

echo "Using launchctl to load ~/Library/LaunchAgents/is.rud.killvaldi.plist"

launchctl load -w  ${HOME}/Library/LaunchAgents/is.rud.killvaldi.plist

echo
echo "You may be prompted by the system to allow this launchd agent to run."
echo 
echo "To uninstall this helper launch agent, issue the following commands at a terminal prompt:"
echo 
echo "    $ launchctl unload -w ~/Library/LaunchAgents/is.rud.killvaldi.plist"
echo "    $ rm ~/Library/LaunchDaemons/is.rud.killvaldi.plist"
echo "    $ rm ~/.local/launchd/killvaldi.sh"
