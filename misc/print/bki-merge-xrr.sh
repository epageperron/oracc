#!/bin/sh
xsltproc $ORACC_BUILDS/lib/scripts/bki-flatten-rr.xsl $1 \
    | xsltproc $ORACC_BUILDS/lib/scripts/bki-group-rr.xsl - \
	       >`dirname $1`/bki-flat-rr.xml
