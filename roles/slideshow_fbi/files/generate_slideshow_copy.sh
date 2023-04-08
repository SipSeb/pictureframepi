#!/bin/bash

. /usr/local/lib/slideshow_functions.sh

source=/home/pi/Pictures
destination=/home/pi/Slideshow

rm $destination/* || true

for file in $source/*.{jpg,JPG} ; do 
  generate_slideshow_pic "$file" "$destination"
done
