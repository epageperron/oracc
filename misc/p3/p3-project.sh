#!/bin/sh
project=`oraccopt`
p3-project-data.plx
xsltproc ${ORACC}/lib/scripts/p3-hub.xsl 02xml/project-data.xml >02www/hub.html
if [ -r 00lib/project.css ]; then
    projcss=true
else
    projcss=false
fi
xsltproc --stringparam projcss $projcss \
    --stringparam project $project \
    ${ORACC}/lib/scripts/p3-project.xsl $ORACC/lib/data/p3-template.xml | \
    sed -e "s%@@PROJECT@@%$project%" >02pub/p3.html
sed -e "s%@@PROJECT@@%$project%" < $ORACC/lib/data/as-base.xml >02www/as.xml
chmod o+r 02pub/p3.html 02www/as.xml
cp 00lib/thumb.png 02www/thumb.png ; chmod o+r 02www/thumb.png
xsltproc $ORACC/lib/scripts/p3-social.xsl 02xml/config.xml >02www/s.html
