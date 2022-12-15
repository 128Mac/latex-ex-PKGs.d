#!/bin/bash

# ln -s $(pwd)/ceosty-UTF-8\ -2/ceosty/into\ latex/ceo $texmfhome/tex/ceo
# ln -s $(pwd)/ceosty-UTF-8\ -2/ceosty/into\ tfm/ceo   $texmfhome/fonts/tfm/ceo
# ln -s $(pwd)/ceosty-UTF-8\ -2/ceosty/into\ type1/ceo $texmfhome/fonts/type1/ceo
# ln -s $(pwd)/ceosty-UTF-8\ -2/ceosty/into\ map/ceo   $texmfhome/fonts/map/ceo

{
    unar=$(which unar)
    if [ -z "$unar" ] ; then
        echo このスクリプトは、S_JIS の日本語名のファイル等を含むもの zip ファイルを utf-8 化するために unar を必要としています
        exit
    fi
}
{
    ARC=zzARCHIVES
    URL=http://hocsom.com/ceosty_settei.zip

    [ -d $ARC ] || mkdir -p $ARC

    t1=$(basename $URL)
    find $ARC -iname $t1 -delete
    curl --silent --location --output $ARC/$t1 --remote-time $URL

    t3=$(zipinfo -1 $ARC/$t1 | awk -F/ '{print $1}'| uniq)
    [ -e "$t3" ] && rm -rf "$t3"
    [ -L "$t3" ] && rm     "$t3"
    unar -quiet $ARC/$t1

    texmfhome=$(kpsewhich --var-value TEXMFHOME)

    ceo_dir=$( zipinfo -1 $ARC/$t1 | awk -F/ '{print $1}' | sort -u )
    find "$ceo_dir" -iname ceo |
        grep /into |
        while read s ; do
            d=$(
                echo "$s" |
                    sed '
                    s%/into %%
                    s%latex%tex%
                    '
             )
            s=$(echo "$s" | sed 's/ /\\&/g')
            if [  -d "$s" ] ; then
                [ -e "$d" ] && rm -r "$d"
                [ -L "$d" ] && rm    "$d"
                ln -s "$s" "$d"
            fi
        done

    echo
    echo Download URL: $URL

    t4=$(
        for k in "into latex" "into tfm" "into type1" "into map" ; do
            find "$(pwd)/$t3" -name "into *" |
                while read intodir ; do
                    find "$intodir" -type f -print0 | xargs -0 -L 1 basename
                done
        done | sort | head -5
      )
    t4="ceo.sty"

    echo

    echo kpsewhich -all $t4 の結果は以下の通り
    kpsewhich -all $t4 | perl -pne 's%'$HOME'%~%'

    find $ARC '(' -iname $t1 ')' -delete
    find $ARC -depth -empty -delete
}
