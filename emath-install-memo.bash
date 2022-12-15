#!/bin/bash

{
    ARC=zzARCHIVES
    USR="emath:$(date +%Y)"

    URL=http://emath.s40.xrea.com/allinone.htm
    DLURL=http://emath.la.coocan.jp/sty

    # 丸ごとパック
    zipfile=$(
        curl --silent --location $URL |
            grep 'emath.s40.xrea.com.*zip' |
            tr '<">' '\n'|
            grep zip
           )

    t3=$(basename $zipfile .zip)

    [ -d $ARC  ] || mkdir -p $ARC
    [ -d $t3   ] && rm -rf $t3

    mkdir $t3

    #cd $t3

    curl --silent --location  --output $ARC/$zipfile --remote-time $DLURL/$zipfile

    unzip  -q -o -d $ARC $ARC/$zipfile -x readme.txt

    zipinfo -1 $ARC/$zipfile -x readme.txt |
        while read zip ; do
            unzip -q -o -d $t3 $ARC/$zip
            rm $ARC/$zip
        done
    rm $ARC/$zipfile

    # 訂正版
    URLTEISEI=http://emath.s40.xrea.com/teisei.htm

    curl --silent --location $URLTEISEI |
        iconv -f sjis -t utf8 |
        sed '/<!---/,/--->/d;/----------/,$d' |
        tr '<"/>( )' '\n' |
        grep zip |
        uniq |
        while read zipfile ; do
            curl --silent --location --output $ARC/$zipfile $DLURL/$zipfile
            unzip  -q -o -d $t3 $ARC/$zipfile
            rm $ARC/$zipfile
        done

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo Download URL: $URL

    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename | sort | head)
    t4=emath.sty
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'

    perl5lib=$(
        find $(pwd)/$3 -iname '*.pl' -exec dirname {} \; |
            sort -u |
            perl -pne 's%'$HOME'%~%' |
            xargs | tr ' ' ':')
    echo
    echo "perl 連携情報 PERL5LIB=$perl5lib"

    find $ARC -depth -empty -delete
}
