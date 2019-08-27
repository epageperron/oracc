#!/usr/bin/perl
use warnings; use strict; use open 'utf8'; use utf8;
binmode STDIN, ':utf8'; binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
use lib "$ENV{'ORACC'}/lib";

use ORACC::CBD::XML;
use ORACC::CBD::PPWarn;
use ORACC::CBD::Util;
use ORACC::CBD::Bases;

my %args = pp_args();
$ORACC::CBD::nonormify = 1;

my @base_cbd = ();

if ($args{'base'}) {
    @base_cbd = setup_cbd(\%args,$args{'base'});
    if (pp_status()) {
	pp_diagnostics();
	die "$0: can't align bases unless base glossary is clean. Stop.\n";
    }
} else {
    die "$0: must give base glossary with -base GLOSSARY\n";
}

my @cbd = setup_cbd(\%args);

if (pp_status()) {
    pp_diagnostics();
    die "$0: can't align bases unless incoming glossary is clean. Stop.\n";
}

bases_init(\%args);
my %bases = bases_align(\%args, \@base_cbd, \@cbd, undef);
bases_term();

if ($args{'apply'}) {
    my $curr_entry = '';
    my %curr_map = ();
    $ORACC::CBD::Bases::serialize_ref = 1;
    for (my $i = 0; $i <= $#cbd; ++$i) {
	next if $cbd[$i] =~ /^\000/;
	if ($cbd[$i] =~ /^[-+>]*\@entry\S*\s+(.*?)\s*$/) {
	    $curr_entry = $1;
	} elsif ($cbd[$i] =~ /^\@bases/) {
	    if ($bases{$curr_entry}) {
		my %curr_bases = %{$bases{$curr_entry}};
		$cbd[$i] = '@bases '.bases_serialize(%curr_bases);
		if ($curr_bases{'#map'}) {
		    %curr_map = %{$curr_bases{'#map'}};
		} else {
		    %curr_map = ();
		}
	    } else {
		%curr_map = ();
	    }
	} elsif ($cbd[$i] =~ /^\@form/) {
	    if (scalar %curr_map) {
		my ($this_base) = ($cbd[$i] =~ m#\s/(\S+)#);
		if ($curr_map{$this_base}) {
		    my $b = $curr_map{$this_base};
		    $cbd[$i] =~ s#^(.*?\s+)/\S+(.*)$#$1/${b}$2#;
		}
	    }
	}
	print $cbd[$i], "\n";
    }
} else {
    pp_diagnostics();
}

1;
