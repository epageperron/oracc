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
use Getopt::Long;
use Data::Dumper;

my $all = 0;
my $lang = undef;
GetOptions(
    all=>\$all,
    'lang:s'=>\$lang,
    );

die "$0: must give language with -lang option. Stop.\n"
    unless $lang;

# get a hash of the changes made in the history file
my %h = ();
if ($all) {
    %h = history_all_init();
} else {
    %h = history_etc_init();
}

open(H,'>history.dump'); print H Dumper \%h; close(H);

# read the wid2lem data and determine which signatures change according
# to the history file; keep a list of changes to be made by file:line:wid
my %changes = ();
$ORACC::Texts::Util::drop_derived = 1;
my %s = wid2lem_sigs('01bld/wid2lem.tab',undef,$lang);
my @n = ();
foreach my $sig (keys %s) {
    my $n = '';
    my $e = '';
    my $s = '';

    my %p = parse_sig($sig);
    my $ocore = "$p{'cf'}\[$p{'gw'}\]$p{'pos'}";
    my $xn = history_guess($ocore);
#    warn "$ocore got $xn back from history_guess\n";
    if ($xn ne $ocore) {
	$e = $xn;
    }
    $ocore = "$p{'cf'}\[$p{'gw'}//$p{'sense'}\]$p{'pos'}'$p{'epos'}";
    $xn = history_guess_sense($ocore);
#    warn "$ocore got $xn back from history_guess_sense\n";
    if ($xn ne $ocore) {
	$s = $xn;
    }
    if ($e && $s) {
	my %e = parse_sig($e);
	my %s = parse_sig($s);
	my $es = "$e{'cf'}\[$e{'gw'}//$s{'sense'}\]$e{'pos'}'$s{'pos'}";
	warn "merge $sig changes into $es\n";
	$changes{$sig} = $es;
    } elsif ($e) {
	$e =~ s#\]#//$p{'sense'}]#;
	warn "change $sig via entry $e\n";
	$changes{$sig} = $e;
    } elsif ($s) {
	warn "change $sig via sense $s\n";
	$changes{$sig} = $s;
    } else {
	# nothing to fix in this sig
    }
}

# generate the change list

open(C,'>changes.dump'); print C Dumper \%changes; close(C);
open(NOUT, "|err-sort.plx"); select NOUT;
if (scalar keys %changes > 0) {
    foreach my $c (keys %changes) {
	my @i = @{$s{$c}};
	foreach my $i (@i) {
	    my $new = '';
	    if (($new = has_changes($$i[1], $changes{$c}))) {
		my $loc = wid2lem_loc($$i[0]);
		$new =~ s/\s+\[/[/; $new =~ s/\]\s+/]/; $new = escape_cf_amp($new);
		print "$$loc[0]\:$$loc[1]:\t$$i[0]\t$$i[1]\t$new\t<<$changes{$c}\n";
	    }
	}
    }
} else {
    warn "$0: no changes identified.\n"; # ???
    exit 2;
}

########################################################################################

sub escape_cf_amp {
    my($cf,$rest) = ($_[0] =~ /^(.*?)(\[.*)$/);
    if ($cf) {
	$cf =~ s/\&/\\&/;
	return "$cf$rest";
    } else {
	return $_[0];
    }
}

sub has_changes {
    my ($inst,$change) = @_;
    my $new = undef;
    my $ii = $inst; $ii =~ s/\].*$/]/; $ii =~ s/^\+//;
#    warn "parse_sig ii = $ii\n";
    my %i = parse_sig($ii);
#    warn "parse_sig change = $change\n";
    my %c = parse_sig($change);
    if ($c{'gw'} =~ /^c[vn][vn]e$/) {
	$new = "$c{'cf'}\[$c{'gw'}\]";
    } else {
	if ($c{'sense'}) {
	    $c{'sense'} =~ s/,\s.*$//;
	    $c{'sense'} =~ s/^a\s+//;
	    $c{'sense'} =~ s/^to\s+//;
	    $c{'sense'} =~ s/^\(to be\)\s+//;
	    $new = "$c{'cf'}\[$c{'sense'}\]";
	}
    }
    $new = undef if unspace($ii) eq unspace($new);
    $new;
}

sub unspace {
    my $tmp = shift;
    $tmp =~ s/\s+\[/[/; $tmp =~ s/\]\s+/]/;
    $tmp;
}

#    } elsif (!$i{'sense'} && $i{'gw'} eq $c{'gw'}) {
#	$new = "$c{'cf'}\[$c{'gw'}\]";

1;
