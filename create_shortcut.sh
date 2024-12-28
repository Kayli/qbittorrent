#!/bin/bash

# Get the absolute path of the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Define the app path and temp script path
APP_PATH="$HOME/Desktop/QBittorrent.app"
TEMP_SCRIPT="$SCRIPT_DIR/.temp_qbittorrent.applescript"

# Remove existing app if it exists
[ -e "$APP_PATH" ] && rm -rf "$APP_PATH"

# Create temporary AppleScript
cat > "$TEMP_SCRIPT" << EOL
on run
	tell application "Terminal"
		activate
		do script "cd $SCRIPT_DIR && docker compose up -d"
		
		-- Wait a bit for the service to start
		delay 3
		
		-- Open the web UI in the default browser
		do shell script "open http://localhost:8080"
	end tell
end run

on quit
	tell application "Terminal"
		activate
		do script "cd $SCRIPT_DIR && docker compose down"
		delay 1
	end tell
	
	continue quit
end quit
EOL

# Compile the AppleScript to an application
osacompile -o "$APP_PATH" "$TEMP_SCRIPT"

# Make the script executable
chmod +x "$APP_PATH"

# Clean up temporary script
rm -f "$TEMP_SCRIPT"

echo "Desktop shortcut created successfully at $APP_PATH"
echo "You can now:"
echo "1. Double-click QBittorrent.app to start qBittorrent"
echo "2. Use ⌘Q to quit and stop the container"
echo "3. The web UI will automatically open in your default browser"
echo ""
echo "Note: The first time you run it, macOS might ask for permissions to:"
echo "- Control Terminal"
echo "- Access network"
