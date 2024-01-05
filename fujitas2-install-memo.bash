#!/usr/bin/env bash

PATH=/usr/bin:$PATH
{
    URL=http://xymtex.com/fujitas2

    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    t3=$(basename $URL)

    [ -d "$t1" ] || mkdir $t1

    stys=$( find $t1 -type f -iname '*.sty' )

    if [ -z "$stys" ] ; then

        curl --silent --location $URL/texlatex/ |
            grep '<A HREF.*sty' |
            awk -F'"../|"' '{ print $2}' |
            while read x ; do
                y=$(basename $x)
                curl --silent --location $URL/$x |
                    iconv -f CP932 -t UTF-8 > $t1/$y
            done
       nkf=$( which nkf )
       if [ -n "$nkf" ] ; then
           find $t1 -iname '*.sty' |
               while read sty ; do
                   nkf -Lu -w --overwrite $sty
               done
       fi
    fi
    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    [ -d "$texmfhome/tex"     ] || mkdir -p  $texmfhome/tex
    [ -e "$texmfhome/tex/$t3" ] && rm    -rf $texmfhome/tex/$t3
    [ -L "$texmfhome/tex/$t3" ] && rm    -rf $texmfhome/tex/$t3
    ln -s                      $(pwd)/$t3    $texmfhome/tex/$t3

    echo
    echo Download URL: $URL/texlatex/index.html
    echo
    t4=$( find $t3 -iname '*.sty' | head -3 | xargs -L 1 basename )
    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'

}
