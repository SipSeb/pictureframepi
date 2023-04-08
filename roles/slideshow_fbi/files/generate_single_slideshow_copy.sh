#!/bin/bash

. /usr/local/lib/slideshow_functions.sh

if [ -z "$1" ] ; then
  echo "Please enter the filename as first and only parameter!"
  exit 1
fi

FILE=$1

source=/home/pi/Pictures
destination=/home/pi/Slideshow

generate_slideshow_pic "$FILE" "$destination"
