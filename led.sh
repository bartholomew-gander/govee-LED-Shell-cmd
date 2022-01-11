#!/bin/bash

# Govee LED Toolkit v1.0
# Please see LICENSE for distribution info.
# MAC="INSERT_MAC_HERE_WITHIN_DOUBLE_QUOTES"

if [ -z ${MAC+x} ]; then echo "Please set up MAC variable or bake it into script"; exit; fi
HANDLE="0x0008" # For me 0x0003 and 0x0008 do not throw any warnings, but any handle seem to make device do stuff

CMD="$1"
PARAM="$2"


# Turns LED strip on.
# Usage:
#           ./led.sh on
if [ "$CMD" == "on" ]; then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e00040100000000ef > /dev/null
    echo "Govee LED Toolkit v1.0"
    echo "Turned LED strip on. Use './led.sh off' to turn off."

# Turns LED strip off. DOES NOT set brightness to 0.
# Usage:
#           ./led.sh off
elif [ "$CMD" == "off" ]; then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e00040000000000ef > /dev/null
    echo "Govee LED Toolkit v1.0"
    echo "Turned LED strip off. Use './led.sh on' to turn on."

# Set brightness to a percentage of 255 (0-100).
# NOTE: Any percentage below 7 causes some LEDs to turn on, but not others; an inaccurate colour may be produced.
# Usage:
#           ./led.sh br 25
#           ./led.sh br 64
elif [ "$CMD" == "br" ]; then
    pcnt=$PARAM # TODO: Add validation between 0 and 100 (0x64)
    code=$(echo 7e0001${pcnt}00000000ef) # Zeros were being truncated for some reason; put code in separate variable to fix this
    gatttool -b $MAC --char-write-req --handle $HANDLE --value $code > /dev/null #main gatttool command
    
# Changes colour to specfied RGB values.
# Usage:
#           ./led.sh colour <r> <g> <b>
# Examples:
#           .led.sh colour 00 ff 00
#           .led.sh colour d9 14 00
elif [ "$CMD" == "colour" ]; then
    check=$(printf '%x' $(( 0x33 ^ 0x05 ^ 0x02 ^ 16#$2 ^ 16#$3 ^ 16#$4 ))) #XOR checksum calculation
    wait # was to prevent hci0 problems, might remove
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503$2$3$400ef > /dev/null #main gatttool command
    echo "Changed colour to #"$2$3$4

# Changes colour to a preset.
# Available presets are: red, orange, burnt_orange, yellow, turquoise, green, blue, purple, and pink.
# Usage:
#           ./led.sh [preset]
# Examples:
#           ./led.sh red
#           ./led.sh purple
elif [ "$CMD" == "red" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503FF000000ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "orange" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503ff750000ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "burnt_orange" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503d9140000ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "yellow" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503ffff0000ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "turq" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e00050300ffff00ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "green" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e00050300FF0000ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "blue" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e0005030000FF00ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "purple" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e0005037500ff00ef > /dev/null
    echo "Changed colour to "$1
elif [ "$CMD" == "pink" ];then
    gatttool -b $MAC --char-write-req --handle $HANDLE --value 7e000503ff00e300ef > /dev/null
    echo "Changed colour to "$1
else echo "Error: no valid option selected"
fi