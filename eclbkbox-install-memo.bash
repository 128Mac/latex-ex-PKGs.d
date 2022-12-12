#!/bin/bash

{
    ARC=zzARCHIVES
    # URL=http://sitmathclub.web.fc2.com/temp/eclbkbox.sty
    URL=http://mechanics.civil.tohoku.ac.jp/bear/bear-collections/style-files/eclbkbox.lzh


    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    [ -f "$ARC/$t1" ] || curl --silent --location --output $ARC/$t1 --remote-time $URL

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
    kpsewhich -all $t4 | /usr/bin/perl -pne 's%'$HOME'%~%'
}
