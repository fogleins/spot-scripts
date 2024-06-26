#!/bin/bash

# ha a python script nem fut: pip3 install termcolor

# sima tobbszintes album eseten lehet, hogy elfogadhatoan mukodik, de olyan esetben, amikor az alalbumok
# nem a teljes albummal egyszerre kerulnek exportra, nagy valoszinuseggel nem jo
# a permissionok valtozasat mindig ellenorizd az export utan
# read -r -p "A script hasznalata csak egyszintes album eseten javasolt. Biztosan folytatod? [i/n] " response
# if [[ "$response" =~ ^([iI])$ ]] ; then
#     : # no op
# else
#     echo "exiting"
#     exit 1;
# fi


export_start=`date +%s`
drive_name="teamdrive-$(date +%Y)"
album_path=""
scripts_dir="/home/${USER}/scripts"

# flagek kezelese
while getopts 'd:a:' flag; do
  case "${flag}" in
    d) drive_name="${OPTARG}" ;;
    a) album_path="${OPTARG}" ;;
    *) echo "Ismeretlen flag. Hasznalat: -d drive_neve: az rclone.conf-ban beallitott driveok kozul az, amelyikrol exportalni szeretnel. -a album_neve a driveon belul az album eleresi utja. Pl: teamdrive-2021:/20211014_levelup eseten: -d teamdrive-2021 -a 20211014_levelup"
       exit 1 ;;
  esac
done

if [ "$album_path" == "" ]; then
    echo "Add meg az album driveon beluli eleresi utjat."
    exit 1
fi

check_json() {
    json_path="./${album_path}/info.json"
    cat ${json_path}
    read -r -p "json rendben? (i/n) " json_response
    if [[ "$json_response" =~ ^([iI])$ ]] ; then
        : # no op
    else # ha a json hibas, megnyitjuk szerkesztesre
        nano ${json_path}
    fi
}

check_album_exists() {
    albums=`find /mnt/archive/google_drive_downloads -maxdepth 2 -type d -name ${album_path}`
    if [ "$albums" != "" ]; then
        read -r -p "Ez az album már exportálásra került. Biztosan újraexportálod? (i/n) " album_exists_response
        if [[ "$album_exists_response" =~ ^([iI])$ ]] ; then
            : # no op
        else # ha nem akarjuk újraexportálni, akkor leállunk
            exit 1
        fi
    fi
}

update_permissions() {
    # fotok es a teljes mappa jogosultsagainak frissitese
    # ${album_path:0:4} az evet adja vissza (albumnev elso negy karaktere)
    # a valtozok utan szereplo ket vesszo (,,) a string valtozo kisbetusiteset szolgalja,
    # ugyanis a python script minden albumnevet kisbetusit a hugo miatt
    album_path_filesystem="/srv/spotweb/web_images/${album_path:0:4}/${album_path,,}"
    chmod -R 775 ${album_path_filesystem}
    chgrp -R users ${album_path_filesystem}

    # md jogosultsagainak modositasa
    md_path_filesystem="/srv/spotweb/content/photo/${album_path:0:4}/${album_path,,}.md"
    chmod 775 ${md_path_filesystem}
    chgrp users ${md_path_filesystem}

    # a public/photo/2021 permission errorok javitasa
    public_html_path="/srv/spotweb/public/photo/${album_path:0:4}/${album_path}"
    chmod -R 775 ${public_html_path}
    chgrp -R users ${public_html_path}

    # ez nem volt tesztelve, lehet, hogy jol mukodik, de olyan tobbszintes album eseten,
    # ahol az alalbumokat nem egyidoben exportaljuk, szinte biztos, hogy nem jo, ilyenkor a
    # script hasznalata nem is javasolt

    # tobbszintes album eseten a contentben mappa jon letre, ennek a permissionjeit is frissitjuk
    mla_content_path="/srv/spotweb/content/photo/${album_path:0:4}/${album_path,,}"
    # ha letezik ilyen nevu directory
    if [ -d "$mla_content_path" ] ; then
        chmod -R 775 ${mla_content_path}
        chgrp -R users ${mla_content_path}
    fi

    # public/ jogosultsagok modositasa 755-rol 775-re
    # a find visszaadja a mappat, amiben a html es az xml rw-r--r--, ezert a mappan belul ezeket is modositjuk (R flag)
    find "/srv/spotweb/public/" -perm 755 -exec chgrp -R users {} \; -exec chmod -R 775 {} \;
}

check_album_exists
echo "Export inditasa a kovetkezo helyen talalhato albumra: ${drive_name}:/${album_path}"

# &&-ekkel kotjuk ossze, hogy csak akkor fusson le a kovetkezo, ha az elozo sikeresen lefutott
cd /mnt/archive/google_drive_downloads/${USER}/ &&
rclone copy ${drive_name}:/${album_path} ./${album_path} -P --transfers=20 --exclude=**NO**EXPORT** --ignore-case &&
check_json && 
source ${scripts_dir}/.py3-libs/bin/activate &&
python3 ${scripts_dir}/spot_export_SimonMod.py -i ./${album_path}/ -l ./logs/${album_path,,}.log &&
bash ${scripts_dir}/convert.sh ./logs/${album_path,,}.log &&
cd /srv/spotweb &&
hugo --noTimes
update_permissions
deactivate # deactivate python venv
export_end=`date +%s`
echo "Az album exportalasa $((export_end-export_start)) masodperc alatt befejezodott."

# TODO: tobbszintes albumnal is meg lehetne nezni, pl ha a content/photo/2021-en belul van album_neve nevu mappa, akkor abban rekurzivan at lehetne allitani
echo "Ne felejtsd el ellenorizni, hogy a jogosultsagok megfeleloen modositva lettek-e az exportalt album fajljain. Tobbszintes album eseten a script ezeket meg sem probalja modositani!"
printf "\n\n"
echo "Permissionok:"
echo "/srv/spotweb/web_images/${album_path:0:4} mappaban:"
ls -la /srv/spotweb/web_images/${album_path:0:4}/ | grep ${album_path,,}
echo "2048-on belul:"
ls -la /srv/spotweb/web_images/${album_path:0:4}/${album_path,,}/2048 | tail -n 10
echo "contenten belul:"
ls -la /srv/spotweb/content/photo/${album_path:0:4}/ | grep ${album_path,,}
