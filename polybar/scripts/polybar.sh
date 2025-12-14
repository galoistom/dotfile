#!/bin/bash

killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config.ini
# Replace 'example' with the name of your bar definition in config.ini
polybar example &
