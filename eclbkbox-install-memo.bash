#!/bin/bash

{
    sevenzip=$(which 7z)
    if [ -z "$sevenzip" ] ; then
        echo このスクリプトは、lzh ファイルを取り扱うため '7z(p7zip)' を必要としています
        exit
    fi
}

{
    ARC=zzARCHIVES
    # URL=http://sitmathclub.web.fc2.com/temp/eclbkbox.sty
    URL=http://mechanics.civil.tohoku.ac.jp/bear/bear-collections/style-files/eclbkbox.lzh


    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    find $ARC -iname $t1 -delete
    curl --silent --location --output $ARC/$t1 --remote-time $URL

    t3=$(basename $URL | awk -F. '{ print $1 }')
    find . -name "$t3" -print0 | xargs -0 rm -rf

    7z x -o$t3 $ARC/$t1 > /dev/null

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo Download URL: $URL
    echo
    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename)
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'

    find $ARC '(' -iname $t1 ')' -delete
    find $ARC -depth -empty -delete
}
