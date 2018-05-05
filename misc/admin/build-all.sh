#!/bin/sh

function fail {
    echo "$*. Stop."
    exit 1
}

if [ ! -r 00lib/config.xml ]; then
    fail "no 00lib/config.xml"
else
    project=`proj-from-conf.sh`
fi
projbuild="00bin/${project}-build-all.sh"
if [ -r $projbuild ]; then
    $projbuild
else
    subs=`list-subprojects.sh $project`
    oracc update
    for a in $subs ; do (cd $a ; oracc resources ; oracc build) ; done
    oracc resources
    oracc build clean
fi
