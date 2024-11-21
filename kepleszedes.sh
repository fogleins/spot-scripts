#!/bin/bash

# használat: ./kepleszedes.sh fajllista leiro [album_path]
    # fajllista: leszedendő képek listája, egy txt, mely soronként egy fájlnevet tartalmaz (elérési út és kiterjesztés nélkül)
    # leiro: az az md, amelyből el kell távolítani a képeket; a script futtatásakor a leírót tartalmazó könyvtárban kell állnunk
    # album_path: az /srv/spotweb/web_images mappán belüli elérési útja; ha nincs megadva, akkor az egész web_images mappát ellenőrizzük (lassabb)

fajllista="$1"
leiro="$2"

while read filename; do
    filename="${filename}.jpg"
    (jq --arg filename "$filename" 'del(.photos[] | select(.filename == $filename))' ${leiro} > tmp.md && mv tmp.md ${leiro}) && echo "[INFO] ${filename} törölve a leíróból" || echo "[WARN] ${filename} nem került törlésre a leíróból"
    chmod 775 ${leiro}
    chgrp users ${leiro}
    find /srv/spotweb/web_images/$3 -name ${filename} -exec rm {} \; -exec echo -n "[INFO] " \; -exec echo -n {} \; -exec echo " törölve" \; || echo "[WARN] ${filename} nem került törlésre a web_images mappából"
done < ${fajllista}
