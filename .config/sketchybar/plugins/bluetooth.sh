#!/bin/bash

# Bluetooth plugin for sketchybar
# Shows currently connected device and manages popup with paired devices

# Function to get currently connected device
get_connected_device() {
    local connected_device=$(blueutil --paired --format json | jq -r '.[] | select(.connected == true) | .name // .address')
    if [ -z "$connected_device" ]; then
        echo "Not Connected"
    else
        # Take only the first word of the device name
        echo "$connected_device" | cut -d' ' -f1
    fi
}

# Function to refresh popup devices
refresh_popup_devices() {
    # Remove existing popup items first
    for i in {1..10}; do
        sketchybar --remove "bluetooth.device.$i" 2>/dev/null || true
    done
    
    # Get all paired devices
    local devices_json=$(blueutil --paired --format json)
    local device_count=$(echo "$devices_json" | jq length)
    
    if [ "$device_count" -eq 0 ]; then
        sketchybar --set bluetooth.devices label="No paired devices" icon="󰂯"
        return
    fi
    
    # Create popup items for each paired device
    local index=1
    while IFS= read -r device; do
        if [ -n "$device" ]; then
            local is_connected=$(echo "$devices_json" | jq -r ".[] | select(.name == \"$device\" or .address == \"$device\") | .connected")
            local icon="󰂯"
            
            if [ "$is_connected" = "true" ]; then
                icon="󰂱"
            fi
            
            # Add device to popup
            sketchybar --add item "bluetooth.device.$index" popup.bluetooth
            sketchybar --set "bluetooth.device.$index" \
                       icon="$icon" \
                       label="$device" \
                       click_script="blueutil --connect \"$device\" 2>/dev/null; sketchybar --set bluetooth popup.drawing=off; $PLUGIN_DIR/bluetooth.sh"
            
            ((index++))
        fi
    done < <(echo "$devices_json" | jq -r '.[] | .name // .address')
    
    # Remove the placeholder devices item
    sketchybar --remove bluetooth.devices 2>/dev/null || true
}

# Function to update the display
update_display() {
    local connected_device=$(get_connected_device)
    local icon="󰂯"  # Bluetooth icon
    
    if [ "$connected_device" != "Not Connected" ]; then
        icon="󰂱"  # Connected Bluetooth icon
    fi
    
    sketchybar --set "$NAME" icon="$icon" label="$connected_device"
}

# Main script logic
case "$SENDER" in
    "refresh")
        refresh_popup_devices
        ;;
    *)
        update_display
        ;;
esac 