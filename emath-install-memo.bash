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
                    next unless ( /href.*zip/);
		    s%</*(font|p)[^<>]*>%%ig;
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

    hoteiZIP=$(    mySel 'lime.cgi\?hotei'  0 $infoINFO )
    hoteiURL=$(    mySel 'lime.cgi\?hotei'  1 $infoINFO )

    perlZIP=$(     mySel 'emathpl'          0 $infoINFO )
    perlURL=$(     mySel 'emathpl'          1 $infoINFO )

    curl --silent --location --output $ARC/$marugotoZIP $marugotoURL
    curl --silent --location --output $ARC/$teiseiZIP   $teiseiURL
    [ -n "$hoteiZIP" ] && curl --silent --location --output $ARC/$hoteiZIP    $hoteiURL
    curl --silent --location --output $ARC/$perlZIP     $perlURL

    if [ -n "$hoteiZIP" ] ; then
        emath=$(basename $marugotoZIP .zip)-$(basename $teiseiZIP .zip)-$(basename $hoteiZIP .zip)
    else
        emath=$(basename $marugotoZIP .zip)-$(basename $teiseiZIP .zip)
    fi

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

    function gitBranch() {
        zip=$1
        url=$2
        if [ -f "$ARC/$zip" ] ; then

            git -C $emath checkout --quiet -b $(basename $zip .zip)
            unzip -q -o -d $emath $ARC/$zip && rm $ARC/$zip
            git -C $emath add .
            git -C $emath commit --quiet -am "$(basename $zip .zip) from $url"
        fi
    }
    # 訂正版で置き換え
    # ブランチを切っておく
    gitBranch "$teiseiZIP" "$teiseiURL"
    gitBranch "$hoteiZIP"  "$hoteiURL"

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
