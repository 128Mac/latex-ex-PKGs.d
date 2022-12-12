#!/bin/bash

{
    ARC=zzARCHIVES
    USR="emath:$(date +%Y)"

    DLURL=http://emath.la.coocan.jp/sty

    t3=emath
    [ -d $ARC  ] || mkdir -p $ARC
    [ -d $t3   ] && rm -rf $t3

    mkdir $t3

    #cd $t3

    # 丸ごとパック
    URL=http://emath.s40.xrea.com/allinone.htm

    zipfile=$(
        curl --silent --location $URL |
            grep 'emath.s40.xrea.com.*zip' |
            tr '<">' '\n'|
            grep zip
           )

    curl --silent --location -O $DLURL/$zipfile

    unzip -q -d $t3 -o $zipfile
    find $t3 -iname '*.zip' -not -iname $zipfile |
        while read zip ; do
            unzip -q -d $t3 -o $zip
            rm $zip
        done
    rm $zipfile

    # 訂正版
    URLTEISEI=http://emath.s40.xrea.com/teisei.htm

    curl --silent --location $URLTEISEI |
        sed '/<!---/,/--->/d;/----------/,$d' |
        tr '<"/>( )' '\n' |
        grep zip |
        uniq |
        while read zipfile ; do
            curl --silent --location -O $DLURL/$zipfile
            unzip -q -d $t3 -o $zipfile
            rm $zipfile
        done

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo Download URL: $URL

    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename | sort | head)
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | /usr/bin/perl -pne 's%'$HOME'%~%'
}
