#!/bin/bash

# File to store the PID of the countdown process
PID_FILE="/tmp/live_timer.pid"
# File to store the last app name
LAST_APP_FILE="/tmp/live_timer_last_app.txt"

# Function to kill existing countdown if running
kill_existing_countdown() {
    if [ -f "$PID_FILE" ]; then
        pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null; then
            kill "$pid" 2>/dev/null
            echo "Killed existing countdown process $pid" >> /tmp/live_timer.log
        fi
        rm "$PID_FILE"
    fi
}

# Function to start the countdown
start_countdown() {
    # Kill any existing countdown first
    kill_existing_countdown
    
    # Start new countdown in background
    (
        local seconds=30
        while [ $seconds -gt 0 ]; do
            sketchybar --set $NAME label="Live: $seconds" drawing=on
            sleep 1
            ((seconds--))
        done
        sketchybar --set $NAME drawing=off
        rm "$PID_FILE" 2>/dev/null
    ) &
    
    # Save the PID of the new countdown process
    echo $! > "$PID_FILE"
    echo "Started new countdown process $!" >> /tmp/live_timer.log
}

# Only process front_app_switched events
if [ "$SENDER" = "front_app_switched" ]; then
    CURRENT_APP="$INFO"
    echo "Current app: $CURRENT_APP" >> /tmp/live_timer.log

    # Read the last app from file, if it exists
    if [ -f "$LAST_APP_FILE" ]; then
        LAST_APP=$(cat "$LAST_APP_FILE")
    else
        LAST_APP=""
    fi
    echo "Last app: $LAST_APP" >> /tmp/live_timer.log

    # Save the current app for next time
    echo "$CURRENT_APP" > "$LAST_APP_FILE"

    # If we switched to Live, kill the countdown
    if [[ "$CURRENT_APP" =~ [Ll]ive ]]; then
        echo "Switched to Live, killing countdown" >> /tmp/live_timer.log
        kill_existing_countdown
        sketchybar --set $NAME drawing=off
    # If we switched away from Live, start the countdown
    elif [[ "$LAST_APP" =~ [Ll]ive ]]; then
        echo "Switched away from Live, starting countdown" >> /tmp/live_timer.log
        start_countdown
    else
        echo "No relevant app switch, doing nothing" >> /tmp/live_timer.log
    fi
fi 