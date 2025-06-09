#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh

WORKSPACE=$1

# Get the list of windows in the workspace
WINDOWS=$(aerospace list-windows --workspace $WORKSPACE)

# Initialize icon string and tooltip string
ICONS=""
TOOLTIP=""

# Process each window to get its app icon
while IFS= read -r window; do
    if [ ! -z "$window" ]; then
        # Extract app name from window info
        APP_NAME=$(echo "$window" | awk -F'|' '{print $2}' | xargs)
        
        # Convert app name to icon (you can customize this mapping)
        case "$APP_NAME" in
            "Google Chrome") ICON="" ;;
            "Safari") ICON="󰈹" ;;
            "Firefox") ICON="󰈹" ;;
            "Code") ICON="󰨞" ;;
            "Cursor") ICON="" ;;
            "Tabby") ICON="" ;;
            "iTerm2") ICON="󰈹" ;;
            "Terminal") ICON="󰈹" ;;
            "Spotify") ICON="󰓇" ;;
            "Slack") ICON="󰒱" ;;
            "Discord") ICON="󰙯" ;;
            "Mail") ICON="󰇮" ;;
            "Messages") ICON="󰍦" ;;
            "Notes") ICON="󰎞" ;;
            "Preview") ICON="󰋩" ;;
            "Finder") ICON="󰀶" ;;
            "Live") ICON="󰸪" ;;
            "Plex") ICON="󰚺" ;;
            "Plexamp") ICON="" ;;
            "Obsidian") ICON="" ;;
            *) ICON="" ;; # Default icon for unknown apps
        esac
        
        ICONS="$ICONS $ICON"
        TOOLTIP="$TOOLTIP$APP_NAME\n"
    fi
done <<< "$WINDOWS"

# Remove trailing newline from tooltip
TOOLTIP=$(echo -e "$TOOLTIP" | sed '$d')

# Update the workspace item
if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME background.drawing=on label="$WORKSPACE" icon="$ICONS" tooltip="$TOOLTIP"
else
    sketchybar --set $NAME background.drawing=off label="$WORKSPACE" icon="$ICONS" tooltip="$TOOLTIP"
fi