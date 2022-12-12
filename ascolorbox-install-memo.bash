#!/bin/bash

{
   URL=https://github.com/yasunari/ascolorbox.git
   t3=$(basename $URL .git)

   [ -e "$t3" ] && rm -rf "$t3"
   git clone $URL $t3

   texmfhome=$(kpsewhich --var-value TEXMFHOME)

   [ -d "$texmfhome/tex"     ] || mkdir  $texmfhome/tex
   [ -e "$texmfhome/tex/$t3" ] && rm -rf $texmfhome/tex/$t3
   ln -s                      $(pwd)/$t3 $texmfhome/tex/$t3
}
