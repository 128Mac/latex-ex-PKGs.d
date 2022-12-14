#!/bin/bash

{
    URL=https://github.com/yasunari/ascolorbox.git

    t3=$(basename $URL .git)

    [ -d "$t3" ] && find "$t3" -delete
    git clone --quiet $URL $t3

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -r  $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm     $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo Download URL: $URL
    echo
    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename)
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'
}
