#!/bin/bash

source /usr/local/etc/slideshow.env

# just sleep 2 seconds to let system come up
sleep 2

function detect_network {
	# TODO: Make it work with other networks, too
	attempts=0
	current_ip=""
	while [ -z $current_ip ] ; do
		current_ip=`ip -o a | egrep 'eth0|wlan0|enp0' | grep 'inet 192' | awk '{ print $4 }' | cut -d '/' -f 1`
		if [ -z $current_ip ] ; then
			sleep 1
		fi
		attempts=$(expr $attempts + 1)
		if [ $attempts -gt 15 ] ; then
			current_ip="kein Netz"
			break
		fi
	done
}


function cleanup_fbi {

	slideshowRunning=`pidof fbi`
	if [ -n "$slideshowRunning" ] ; then
		for pid in $slideshowRunning ; do
			kill -HUP $pid
		done
	fi
	# TODO: Generate Image when first collecting data
}

# String containing pictures to show
thisShow=""

if [ -n "$1" ]; then
  if [ "$1" = "reload" ]; then
    convert /usr/local/share/frame_welcome.jpg -font Helvetica-Bold -pointsize 80 -fill white -draw "text 250,450 '${newImagesMsg}'" -pointsize 40 -draw "text 450,500 '${restartingMsg}'" /tmp/welcome.jpg
    cleanup_fbi
    fbi -d /dev/fb0 -T 1 -a --noverbose /tmp/welcome.jpg
  fi
else

  # Standard Startup Mode
  convert /usr/local/share/frame_welcome.jpg -font Helvetica-Bold -pointsize 80 -fill white -draw "text 350,450 '${welcomeMsg}'" -pointsize 30 -draw "text 360,500 '${frameMailAddress}'" /tmp/welcome.jpg
  cleanup_fbi
  fbi -d /dev/fb0 -T 1 -a --noverbose /tmp/welcome.jpg
  
  # wait 1 second and do it again to prevent long terminal screen
  sleep 2
  cleanup_fbi
  fbi -d /dev/fb0 -T 1 -a --noverbose /tmp/welcome.jpg

  current_ip=""
  detect_network

  convert /usr/local/share/frame_welcome.jpg -font Helvetica-Bold -pointsize 80 -fill white -draw "text 350,450 '${welcomeMsg}'" -pointsize 30 -draw "text 360,500 '${frameMailAddress}'" -pointsize 40 -draw "text 80,750 'IP-Adresse: ${current_ip}'" /tmp/willkommen.jpg

  cleanup_fbi
  fbi -d /dev/fb0 -T 1 -a --noverbose /tmp/willkommen.jpg
fi

rm -f /tmp/new*jpg
newcounter=0
for newfile in `find $dir -type f -mtime -${newDays}`; do
  convert $newfile -font Helvetica-Bold -pointsize 80 -fill red -draw "text 80,160 '${newMsg}'" /tmp/new${newcounter}.jpg
  thisShow="$thisShow /tmp/new${newcounter}.jpg"
  newcounter=$(expr $newcounter + 1)
done

picCount=0
for i in `ls -1 $dir | shuf` ; do
	picCount=$(expr $picCount + 1)
	thisShow="$thisShow ${dir}/$i"
	if [ $picCount -gt $maxItems ] ; then break ; fi
done

cleanup_fbi
fbi -d /dev/fb0 -T 1 -a --blend 500 -t $duration --verbose --readahead $thisShow

