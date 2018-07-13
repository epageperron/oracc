#!/bin/sh
for a in `cat 00lib/super*.lst`; do
    proj=`/bin/echo -n $a | cut -d: -f1`
    (cd $ORACC_BUILDS/$proj ;
     for g in 00lib/*.glo ;
     do
	 if [ "$g" = "00lib/*.glo" ]; then
	     true
	 else
	     echo "super-check.plx working in $proj" >&2 ; cbdpp.plx -anno -chec $g
	 fi
     done)
done
