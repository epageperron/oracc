#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8;
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
use lib "$ENV{'ORACC'}/lib";

use ORACC::CBD::PPWarn;
use ORACC::CBD::Util;
use ORACC::CBD::Map;

use Data::Dumper;

$ORACC::CBD::nonormify = 1;
$ORACC::CBD::nosetupargs = 1;
my %args = pp_args();

my @base_cbd = ();

if ($args{'base'}) {
    @base_cbd = setup_cbd(\%args,$args{'base'});
    if (pp_status()) {
	pp_diagnostics();
	die "$0: can't apply map to glossary unless it's clean. Stop.\n";
    }
} else {
    die "$0: must give base glossary for mapping with -base GLOSSARY\n";
}
my $map = shift @ARGV;
if ($map) {
    if (-r $map) {
	my %map = map_load($map,'glos');
	# print Dumper \%map; exit 1;
	my @c = map_apply_glo(@base_cbd);
	foreach (@c) {
	    print "$_\n" unless /^\000$/;
	}
    } else {
	die "$0: can't read map file $map\n";
    }
} else {
    die "$0: must give map on command line\n";
}

1;
