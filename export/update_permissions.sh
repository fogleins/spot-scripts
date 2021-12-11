# neha a hugo build errorok miatt nem frissulnek a permissionok
# az export_all_in_one.sh hasznalataval, ilyenkor hasznos ezt a
# scriptet hasznalni, hogy a manualis atirogatast elkerulhessuk

album_path=""

while getopts 'a:' flag; do
  case "${flag}" in
    a) album_path="${OPTARG}" ;;
    *) echo "Ismeretlen flag."
       exit 1 ;;
  esac
done

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
}

update_permissions && 
ls -la /srv/spotweb/web_images/${album_path:0:4}/ | grep ${album_path,,} && 
ls -la /srv/spotweb/web_images/${album_path:0:4}/${album_path,,}/2048 | tail -n 10 && 
ls -la /srv/spotweb/content/photo/${album_path:0:4}/ | grep ${album_path,,} &&
ls -la /srv/spotweb/public/photo/${album_path:0:4} | grep ${album_path}
