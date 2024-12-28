#!/bin/bash

CONFIG_FILE="/config/qBittorrent/qBittorrent.conf"

# Ensure the directory exists
mkdir -p "$(dirname "$CONFIG_FILE")"

# Create the file if it doesn't exist
touch "$CONFIG_FILE"

# Function to set or update a preference
set_preference() {
    local key="$1"
    local value="$2"
    
    # Remove existing entry if it exists
    sed -i "/^${key}=/d" "$CONFIG_FILE"
    
    # Add new entry
    echo "${key}=${value}" >> "$CONFIG_FILE"
}

# Ensure [Preferences] section exists
if ! grep -q "^\[Preferences\]" "$CONFIG_FILE"; then
    echo "[Preferences]" >> "$CONFIG_FILE"
fi

# Set the specific preferences
set_preference "WebUI\\AuthSubnetWhitelist" "172.18.0.0/16"
set_preference "WebUI\\AuthSubnetWhitelistEnabled" "true"
set_preference "WebUI\\LocalHostAuth" "false"

# Ensure the preferences are in the [Preferences] section
sed -i '/^\[Preferences\]/,/^\[/ {
    /^WebUI\\AuthSubnetWhitelist=/d
    /^WebUI\\AuthSubnetWhitelistEnabled=/d
    /^WebUI\\LocalHostAuth=/d
}' "$CONFIG_FILE"

sed -i '/^\[Preferences\]/a\
WebUI\\AuthSubnetWhitelist=172.18.0.0/16\
WebUI\\AuthSubnetWhitelistEnabled=true\
WebUI\\LocalHostAuth=false' "$CONFIG_FILE"
