#!/bin/bash

{
    ARC=zzARCHIVES
    URL=http://emath.s40.xrea.com/xdir/othersty/eclarith.zip
    USR=emath:$(date +%Y)

    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    find $ARC -iname $t1 -delete
    curl --silent --location --user $USR --output $ARC/$t1 --remote-time $URL

    t2=$(zipinfo -1 $ARC/$t1 | head -1)
    t3=$(basename $t2 .sty)            ; unzip -q -o -d $t3 $ARC/$t1

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

    find $ARC '(' -iname $t1 -o -iname $t2 ')' -delete
    find $ARC -depth -empty -delete
}
