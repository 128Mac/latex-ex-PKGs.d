#!/bin/bash

{
    ARC=zzARCHIVES
    URL=http://www17.plala.or.jp/mi_kana/schlmath/schlmath.zip

    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    [ -f "$ARC/$t1" ] || curl --silent --location --output $ARC/$t1 --remote-time $URL

    t2=$(zipinfo -1 $ARC/$t1 | head -1)
    [ -f "$ARC/$t2" ] || unzip -q -d $ARC $ARC/$t1

    t3=$(basename $t2 .zip )
    [ -e "$t3" ] && rm -rf $t3
    unzip -q -d $t3 $ARC/$t2

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -r  $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm     $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo Download URL: $URL

    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename)
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | /usr/bin/perl -pne 's%'$HOME'%~%'
}
