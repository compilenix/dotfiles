#!/bin/bash
# vim: sw=4 et

if [ "$1" == "inc" ]; then
   amixer -q sset Master 2%+
fi

if [ "$1" == "dec" ]; then
   amixer -q sset Master 2%-
fi

if [ "$1" == "mute" ]; then
   amixer -q sset Master toggle
fi


AMIXER=$(amixer sget Master)
VOLUME=$(echo $AMIXER | grep 'Right:' | awk -F'[][]' '{ print $2 }' | tr -d "%")
MUTE=$(echo $AMIXER | grep -o '\[off\]' | tail -n 1)
if [ "$VOLUME" -le 20 ]; then
    ICON=audio-volume-low
else if [ "$VOLUME" -le 60 ]; then
         ICON=audio-volume-medium
     else
         ICON=audio-volume-high
     fi
fi
if [ "$MUTE" == "[off]" ]; then
    ICON=audio-volume-muted
fi

NOTI_ID=$(~/.local/bin/notify-send.py "Volume $VOLUME%" \
                         --hint string:image-path:$ICON boolean:transient:true \
                         --replaces-process "volume-popup" --expire-time 1000)

