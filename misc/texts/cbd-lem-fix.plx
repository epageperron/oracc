#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8;
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';

# This is the program that takes the history file resulting from glossary
# edits and applies it to the corpus.  It does so using the table of file:line
# locations and signatures, by editing the signatures according to the history
# file, generating a new instance lemmatization, and rewriting the occurrences
# of the new lemmatizations via the wid2loc table (actually generated by
# wid2lem).

###
### Exit status =
###	0 for changes applied successfully
###	1 for error
###	2 for no table needed
###

use lib "$ENV{'ORACC'}/lib";
use ORACC::CBD::History;
use ORACC::L2GLO::Util;
use ORACC::Texts::Util;

use Data::Dumper;

# get a hash of the changes made in the history file
my %h = history_map();
open(H,'>history.dump'); print H Dumper \%h; close(H);

# read the wid2lem data and determine which signatures change according
# to the history file; keep a list of changes to be made by file:line:wid
my %changes = ();
my %s = wid2lem_sigs('01bld/wid2lem.tab');
my @n = ();
foreach my $s (keys %s) {
    my %p = parse_sig($s);
    my $ocore = "$p{'cf'}\[$p{'gw'}//$p{'sense'}\]$p{'pos'}'$p{'epos'}";
    my $n = '';
    if ($h{$ocore}) {
	$changes{$s} = $h{$ocore};
    }
}

if (scalar keys %changes > 0) {
    print Dumper \%changes;
} else {
    warn "$0: no 01bld/from-xtf.glo so no corpus fixes applied\n";
    exit 2;
}

# apply the changes in the change list

# report which projects have changed so that we can trigger git checkins
# and oracc rebuilds

1;
