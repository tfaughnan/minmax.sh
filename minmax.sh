#!/bin/sh

# file to store info about minimized windows
LOG=/tmp/minmax.log

# never minimize windows with these class names
IGNORE='Bspwm Polybar'

usage() {
    echo "Usage:"
    echo "$0 min"
    echo "$0 max"
    echo "$0 --help"
    exit "$1"
}

min() {
    winid="$(xdotool selectwindow)"
    [ -z "$winid" ] && exit 1
    winclass="$(xdotool getwindowclassname "$winid")"
    echo "$IGNORE" | grep -wiq "$winclass" && exit 1
    printf '%s,%s\n' "$winclass" "$winid" >> $LOG
    xdotool windowactivate --sync "$winid" windowunmap "$winid"
}

max() {
    winclass="$(cut -d, -f 1 $LOG | dmenu -i)"
    [ -z "$winclass" ] && exit 1
    winid="$(grep -E "^$winclass,[0-9]+$" $LOG | cut -d, -f 2)"
    xdotool windowmap "$winid" && sed -i "/$winclass,$winid/d" $LOG
}

[ -f $LOG ] || touch $LOG
case "$1" in
    "min") min ;;
    "max") max ;;
    "-h"|"--help") usage 0;;
    *) usage 1;;
esac
