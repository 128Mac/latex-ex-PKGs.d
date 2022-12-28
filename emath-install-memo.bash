#!/bin/bash

: main && {
    ARC=zzARCHIVES

    [ -d "$ARC" ] && find $ARC -delete
    [ -d "$ARC" ] || mkdir -p $ARC

    URL=http://emath.s40.xrea.com/allinone.htm
    URLTEISEI=http://emath.s40.xrea.com/teisei.htm

    infoINFO=$(
        for url in $URL $URLTEISEI ; do
            curl --silent --location $url |
                iconv -f sjis -t utf8 |
                perl -ne '
                    exit if ( /旧訂正版/ );
                    print "$2 $1\n"    if ( /.* href="([^"]+)["]>([^<>]+[.]zip)<.*/   ) ;# 丸ごとパック/訂正
                    print "$2 $1/$2\n" if ( /.* href="([^"]+)[\/]([^"]+[0-9][.]zip)"/ ) ;# perl
                '
        done |
            sort -u
            )

    function mySel() {
        key=$1 ; shift
        val=$1 ; shift
        echo $@ |
            awk '
            {
                for ( i = 1 ; i < NF ; i += 2 ) {
                    if ( $(i+1) ~ /'$key'/  ) {
                        print $(i+'$val');
                        exit
                    }
                }
            }
            '
    }

    marugotoZIP=$( mySel 'lime.cgi\?0001'   0 $infoINFO )
    marugotoURL=$( mySel 'lime.cgi\?0001'   1 $infoINFO )

    teiseiZIP=$(   mySel 'lime.cgi\?teisei' 0 $infoINFO )
    teiseiURL=$(   mySel 'lime.cgi\?teisei' 1 $infoINFO )

    perlZIP=$(     mySel 'emathpl'          0 $infoINFO )
    perlURL=$(     mySel 'emathpl'          1 $infoINFO )

    curl --silent --location --output $ARC/$marugotoZIP $marugotoURL
    curl --silent --location --output $ARC/$teiseiZIP   $teiseiURL
    curl --silent --location --output $ARC/$perlZIP     $perlURL

    emath=$(basename $marugotoZIP .zip)-$(basename $teiseiZIP .zip)
    [ -d "$emath" ] && find $emath -delete
    mkdir -p $emath

    # 丸ごとパック展開
    unzip -q -d $emath $ARC/$marugotoZIP && rm  $ARC/$marugotoZIP
    find $emath -iname '*.zip' |
        while read zip ; do
            unzip -q -d $emath $zip
            rm $zip
        done
    git -C $emath init --quiet
    git -C $emath add .
    git -C $emath commit --quiet -am "$(basename $marugotoZIP .zip) from $marugotoURL"

    # 訂正版で置き換え
    # ブランチを切っておく
    git -C $emath checkout --quiet -b $(basename $teiseiZIP .zip)
    unzip -q -o -d $emath $ARC/$teiseiZIP && rm $ARC/$teiseiZIP
    git -C $emath add $(
        git -C $emath status |
            awk -v RS= '/Untracked/ { gsub (/.*\)/, ""); print}'
        )
    git -C $emath commit --quiet -am "$(basename $teiseiZIP .zip) from $teiseiURL"

    perl=$(basename $perlURL .zip)
    [ -d "$perl" ] && find $perl -delete
    mkdir -p $perl
    unzip -q -d $perl $ARC/$perlZIP && rm  $ARC/$perlZIP

    t3=$emath

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

    echo
    echo "Download URL: $URL"
    echo "              $URLTEISEI"

    t4=$(find $t3 -iname '*.sty'| xargs -L 1 basename | sort | head)
    t4=$(echo emath.sty $t4)
    echo kpsewhich -all emath.sty $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'

    perl5lib=$(
        find $(pwd)/$(basename $perlZIP .zip) -iname '*.pl' -exec dirname {} \; |
            sort -u |
            perl -pne 's%'$HOME'%~%' |
            xargs | tr ' ' ':')
    echo
    echo "perl 連携情報 PERL5LIB=$perl5lib"

    find $ARC -depth -empty -delete
}
