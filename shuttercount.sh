#!/bin/bash

# egy mappában található minden .NEF fájlon végigmegy, és kiolvassa az exifből
#   a következő adatokat:
#       -Fájl létrehozási ideje
#       -Kamera típusa (modell)
#       -Sorozatszám (azonos modellek különböző példányainak megkülönböztetéséhez)
#       -Expószám
#
#   Használat: bash ./shuttercount.sh <kepeket-tartalmazo-mappa-eleresi-utja>  # szokozoket nem tartalmazhat!
#           vagy: cd-zzunk a képeket tartalmazó mappába és bash ./scriptet/tartalmazo/mappa/shuttercount.sh
#               a képeket tartalmazó mappa (amibe cd-ztünk) ebben az esetben sem tartalmazhat szóközt

directory="$1"

if [ "$directory" == "" ]; then
    directory=$(pwd)
# remove the trailing slash if it's given, making the concatenation easier to read
elif [ "${directory: -1}" == "/" ]; then
    directory="${directory:0:-1}"
fi

find $directory -name "*.NEF" -exec echo "" \; -exec exiftool {} \; | grep -E 'Serial Number|Shutter Count|File Modification Date/Time|Camera Model Name'

#directory="$directory/*.NEF"
#for file in $directory; do
#    exiftool $file | grep -E 'Serial Number|Shutter Count|File Modification Date/Time|Camera Model Name'
#    echo ""
#done
