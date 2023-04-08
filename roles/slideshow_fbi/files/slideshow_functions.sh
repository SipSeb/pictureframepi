#!/bin/bash

source /usr/local/etc/slideshow.env

function clean_filename {
  file=$1
  echo $file | sed 's/ /_/g'
}

function fix_rotation {
  file=$1
  rotate=0
  mirror=0
  IMAGE_ROTATION=`identify -format '%[EXIF:Orientation]' ${file} 2> /dev/null`
  [ -z "$IMAGE_ROTATION" ] && return
  [ $IMAGE_ROTATION -eq 1 ] && return
  [ $IMAGE_ROTATION -eq 8 ] && rotate=270
  [ $IMAGE_ROTATION -eq 3 ] && rotate=180
  [ $IMAGE_ROTATION -eq 6 ] && rotate=90
  # need to mirror 
  if [ $IMAGE_ROTATION -eq 7 ] ; then
    rotate=270
    mirror=1
  fi
  if [ $IMAGE_ROTATION -eq 4 ] ; then
    rotate=180
    mirror=1
  fi
  if [ $IMAGE_ROTATION -eq 5 ]; then
    rotate=90
    mirror=1
  fi
  if [ $IMAGE_ROTATION -eq 2 ] ; then
    mirror=1
  fi
  if [ $rotate -gt 0 ] ; then
    rotation_args="$rotation_args -rotate $rotate"
  fi
  if [ $mirror -gt 0 ] ; then
    rotation_args="$rotation_args -flop"
  fi
}

function generate_slideshow_pic {
  file=$1
  destination=$2
  rotation_args=""
  fix_rotation "$file"
  clean_filename=$(clean_filename "$file")
  echo "${file} => ${destination}/`basename ${clean_filename}`"
  convert "$file" ${CONVERT_EXTRA_PARAMS} -resize "${SCREEN_RESOLUTION}>" -quality ${IMAGE_QUALITY} ${rotation_args} "${destination}/`basename ${clean_filename}`"
  touch -d "$(date -R -r "${file}")" "${destination}/`basename ${clean_filename}`"
}

function delete_slideshow_pic {
  file=$1
  dir=$2
  clean_filename=$(clean_filename "$file")
  if [ -e "${dir}/${clean_filename}" ] ; then
    rm "${dir}/${clean_filename}"
  fi
}
