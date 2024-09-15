#!/bin/bash

SIZE=2048
LOGO_PATH="/home/SPOT/logo-invert-watermark-size.png"
# WORKING_DIRECTORY="/run/media/simon/Seagate Expansion Drive/Képek Lightroom/vm-share/2021-09-24/dj-watermark/"

mkdir ./watermark
for file in *; do
    if [ -f "$file" ]; then
	echo [ CONVERT ] $file
        convert $file -strip -quality 95 -thumbnail ${SIZE}x${SIZE} ${LOGO_PATH} -gravity southeast -geometry +30+30 -composite ./watermark/"${file:0:-4}.jpg"
    fi
done
