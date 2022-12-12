#!/bin/bash

{
   URL=https://github.com/yasunari/ascolorbox.git
   t3=$(basename $URL .git)

   [ -e "$t3" ] && rm -rf "$t3"
   git clone $URL $t3

   texmfhome=$(kpsewhich --var-value TEXMFHOME)

   [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
   [ -e "$texmfhome/tex/$t3" ] && rm -r  $texmfhome/tex/$t3
   [ -L "$texmfhome/tex/$t3" ] && rm     $texmfhome/tex/$t3
   ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3

   echo
   echo kpsewhich -all ascolorbox.sty の結果は以下の通り
   kpsewhich -all ascolorbox.sty | /usr/bin/perl -pne 's%'$HOME'%~%'
}
