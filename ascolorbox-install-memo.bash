#!/bin/bash

{
    ARC=zzARCHIVES
    URL=https://github.com/yasunari/ascolorbox.git

    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    [ -f "$ARC/$t1" ] || curl --silent --location --output $ARC/$t1 --remote-time $URL

    t2=$(zipinfo -1 $ARC/$t1 | head -1)
    [ -f "$ARC/$t2" ] || unzip -q -d $ARC $ARC/$t1

    t3=$(basename $URL .git)

    [ -e "$t3" ] && rm -rf "$t3"
    git clone $URL $t3

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -r  $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm     $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    t=$(pwd)/$t3
    perl -CSD -npe '
       s/p(LaTeX2e)/$1/ if /NeedsTeXFormat/;
       s/(zw)/em/g if /zw/;
       ' $t/ascolorbox.sty > $t/myAscolorbox.sty

    diff -U0 $t/ascolorbox.sty $t/myAscolorbox.sty

    echo
    echo Download URL: $URL
    echo
    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename)
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | /usr/bin/perl -pne 's%'$HOME'%~%'

}
