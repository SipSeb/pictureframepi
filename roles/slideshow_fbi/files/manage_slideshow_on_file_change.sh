#!/bin/bash

. /usr/local/lib/slideshow_functions.sh

pics_dir=/home/pi/Pictures
slideshow_dir=/home/pi/Slideshow
file=$1
action=$2

function reload_slideshow {
  if [ -e /tmp/slideshow_reload ] ; then
    return
  else
    touch /tmp/slideshow_reload
    # let some more files come in
    sleep 20
    sudo /usr/local/bin/show_slideshow.sh reload 2> /dev/null
    rm /tmp/slideshow_reload
  fi
}

case $action in
IN_CREATE | IN_MOVED_TO)
  generate_slideshow_pic ${pics_dir}/${file} ${slideshow_dir}
  ;;
IN_DELETE | IN_MOVED_FROM)
  delete_slideshow_pic $file ${slideshow_dir}
  ;;
esac

reload_slideshow