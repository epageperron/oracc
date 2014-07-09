#!/usr/bin/perl
use warnings; use strict; use open ':utf8'; use utf8;
binmode STDOUT, ':utf8'; binmode STDERR, ':utf8';
use lib '/usr/local/oracc/lib';
use ORACC::P3::Slicer;
use File::Temp qw/tempdir/;
use Data::Dumper;
use integer;
use Encode;

# P3 is controlled by the following top-level variables:
# ===================================-==================
#
# p3prod: the producer for the list being paged--list, srch
#
# p3mode: the slicing policy for the list--full or zoom
#
# p3what: the display policy for the list--page or item
# 
# p3type: the data being listed or searched--cat, xtf, tra, cbd
#
# p3form: the UI state--full or mini
#
# p3outl: the outline state--default, special or none
#
# Each of these variables is computed on entry to p3-pager.plx,
# inserted into the %rt array and echoed into the hidden fields
# on return.

sub xsystem;

my $oraccbin = "/usr/local/oracc/bin";
my $oraccbld = "/usr/local/oracc/bld";
my $oracclib = "/usr/local/oracc/lib";
my $oraccpub = "/usr/local/oracc/pub";
my $oraccwww = "/usr/local/oracc/www";

my $force_page = 0;
my $no_html = "/usr/local/oracc/www/no_html.xml";
my $oas_instance = '';
my $oas_template = "/usr/local/oracc/lib/data/oas-template.xml";
my $ood_mode = 0;
my %p = ();
my @pg_args = ();
my $projtype = '';
my $proxy_host = '';
my %rt = ();
my $verbose = 1;

%p = decode_args(@ARGV);

p3_oas_triage()
    if $p{'referer'} && $p{'referer'} =~ m,/as,;

$p{'p3OSspecial'} = `/usr/local/oracc/bin/oraccopt $p{'project'} outline-special-sort-fields`
    unless $p{'p3OSspecial'};
$p{'p3OSdefault'} = `/usr/local/oracc/bin/oraccopt $p{'project'} outline-default-sort-fields`
    unless $p{'p3OSdefault'};

arg_state();
setup_navigation();
set_p3_state();

my $orig_referer = $p{'referer'} || '';
if ($p{'glos'}) {
    $p{'referer'} = "/$p{'project'}/$p{'glos'}";
}
warn "p3-pager: referer set from $orig_referer => $p{'referer'}\n"
    if $p{'referer'};

$ood_mode = $p{'project'} =~ m#/ood/#;
if ($ood_mode) {
    $rt{'otlmode'} = 'none';
} else {
    $rt{'otlmode'} = 'some';
}

if ($rt{'prod'} eq 'list') {
    if ($p{'glos'}) {
	$rt{'cetype'} = $p{'p3cetype'};
	if ($p{'gxis'}) {
	    $rt{'itemtype'} = $p{'itemtype'} = $rt{'#list_type'} = 'xtf';
	    xsystem("/usr/local/oracc/bin/xis", '-f', "/usr/local/oracc/bld/$p{'project'}/$p{'glos'}/$p{'glos'}.xis", '-i', $p{'gxis'}, '-o', "$p{'tmpdir'}/results.lst");
	    $p{'#list'} = "$p{'tmpdir'}/results.lst";
	    set_list_items();
	    $p{'uimode'} = 'mini';
	} else {
	    $rt{'#list_type'} = 'cbd';
	    $rt{'itemtype'} = $p{'itemtype'} = 'cbd';
	    $rt{'viewtype'} = $p{'viewtype'} = 'page';
	    if ($p{'glet'} && $p{'glet'} ne '#all') {
		open(T,"/usr/local/oracc/pub/$p{'project'}/cbd/$p{'glos'}/letter_ids.tab") || die;
		my $x = <T>;
		close(T);
		Encode::_utf8_on($p{'glet'});
		my ($lid) = ($x =~ /(?:^|\t)$p{'glet'}\t(\S+)/);
		$p{'#list'} = "/usr/local/oracc/pub/$p{'project'}/cbd/$p{'glos'}/$lid.lst";
	    } else {
		$p{'#list'} = "/usr/local/oracc/pub/$p{'project'}/cbd/$p{'glos'}/entry_ids.lst";
	    }
	    set_list_items();
	}
    } elsif ($p{'adhoc'}) {
	p3adhoc();
    } elsif ($p{'list'} eq '_all') {
	$p{'#list'} = "/usr/local/oracc/pub/$p{'project'}/cat/pqids.lst";
	$rt{'#list_type'} = 'cat';
	unless (-r $p{'#list'}) {
	    p3srch($p{'list'});
	    $p{'list'} = '';
	} else {
	    set_list_items();
	}
    } elsif ($p{'asrch'} && $p{'asrch'} eq 'yes') {
	$p{'#list'} = $p{'list'};
	$p{'tmpdir'} = $p{'list'};
	$p{'tmpdir'} =~ s,/results.lst,,;
	if ($p{'srchtype'} eq 'txt' || $p{'srchtype'} eq 'lem') {
	    $rt{'#list_type'} = 'xtf';
	} else {
	    $rt{'#list_type'} = $p{'srchtype'};
	}
	set_list_items();
    } elsif ($p{'list'} =~ /\.xtl$/) {
    } else {
	$p{'#list'} = "/usr/local/oracc/www/$p{'project'}/lists/$p{'list'}";
	$rt{'#list_type'} = 'cat';
	set_list_items();
    }

} else { # srch

    if ($p{'asrch'} eq 'yes') {
	$rt{'#index'} = $p{'srchtype'};
    } else {
	$rt{'cetype'} = $p{'p3cetype'};
	p3srch();
    }
    unless ($rt{'#list_type'}) {
	if ($rt{'#index'} eq 'txt' || $rt{'#index'} eq 'lem') {
	    $rt{'#list_type'} = 'xtf';
	} elsif ($p{'glos'}) {
	    $rt{'#list_type'} = 'cbd';
	} else {
	    $rt{'#list_type'} = $rt{'#index'};
	}
    }
}

# set up the Slicer inputs
if (!$ood_mode && (!$p{'glos'} || $p{'gxis'})) {
    if ($rt{'#list_type'} eq 'xtf' && !$p{'item'}) {
	my $ce_arg = set_ce_arg();
	xsystem('/usr/local/oracc/bin/wm', "-p$p{'project'}", $ce_arg, "-i$p{'tmpdir'}/results.lst", "-o$p{'tmpdir'}/wm.out");
	$p{'#list'} = "$p{'tmpdir'}/wm.out";
    }
    if ($p{'item'} && $rt{'#list_type'} =~ /^tra|xtf$/) {
	xsystem('/usr/local/oracc/bin/p3-collapse.plx', "$p{'tmpdir'}/results.lst", "$p{'tmpdir'}/collapsed.out");
	$p{'#list'} = "$p{'tmpdir'}/collapsed.out";
	set_list_items();
    }
    if ($p{'#listitems'}) {
	setup_pg_args();
	my($pg_order,$input) = ORACC::P3::Slicer::page_setup($p{'tmpdir'}, $p{'#list'}, $p{'cetype'} eq 'kwic');
	
	# set up the input for the content maker
	ORACC::P3::Slicer::page_info($p{'tmpdir'}, $pg_order, $input, $p{'cetype'} eq 'kwic', $p{'project'}, @pg_args);
	
	# generate the outline
	ORACC::P3::Slicer::page_outline($pg_order, @pg_args);
    }
} else {
    ORACC::P3::Slicer::glos_info(%p);
}

set_runtime_vars();

# generate the content
## in page mode emit the pth page
## in item-mode emit the ith item of the pth page

#if ($p{'glos'} && $p{'glet'}) {
#    if ($p{'glet'} =~ /html$/) {
#	$rt{'#content_url'} = "/usr/local/oracc/www$p{'glet'}";
#    } else {
#	$rt{'#content_url'} = "/usr/local/oracc/www/$p{'project'}/cbd/$p{'glos'}/$p{'glet'}.html";
#	
#    }
#} elsif ($p{'item'} == 0) {
if ($p{'item'} == 0) {
    run_page_maker() unless !$rt{'pages'};
} else {
    run_item_maker();
}

# echo the template including outline/content as we go
print "Content-type: text/html; Encoding=utf-8\n\n"
    unless $p{'noheader'};

run_form_maker("/usr/local/oracc/lib/data/p3-template.xml");

# close and exit
EXIT:
{
    close(STDOUT);
    ## if -d $tmpdir rm -fr $tmpdir
    exit 0;
}

####################################################################

sub
ce_data_info {
    my $nth = shift;
    my @ret = ();
    my $xce = load_xml("$p{'tmpdir'}/content.xml");
    if ($xce) {
	my @cedata = tags($xce,'http://oracc.org/ns/ce/1.0','data');
	my $cenode = $cedata[$nth-1];
	if ($cenode) {
	    my $line = $cenode->getAttribute('line-id');
	    my $ctxt = $cenode->getAttribute('context-id');
	    if ($line) {
		push(@ret, '-stringparam', 'line-id', $line);
		push(@ret, '-stringparam', 'frag-id', $ctxt)
		    if $ctxt;
	    }
	}
    }
    @ret;
}

sub
decode_args {
    my %tmp = ();
    foreach my $a (@_) {
	warn "$a\n";
       	my($k,$v) = ($a =~ /^(.*?)=(.*)$/);
	$tmp{$k} = $v;
    }

    if ($tmp{'from-uri'} && $tmp{'from-uri'} eq 'yes') {
	if ($tmp{'list'}) {
	    $tmp{'p3setlinks'} = $tmp{'list'};
	} else {
	    $tmp{'p3setgloss'} = $tmp{'list'};
	}
    }

    if ($tmp{'project'} eq '#auto') {
	if ($tmp{'tmpdir'} && -r "$tmp{'tmpdir'}/search.txt") {
	    my $s = `cat $tmp{'tmpdir'}/search.txt`;
	    $s =~ /\#(\S+)/;
	    $tmp{'project'} = $1;
	    $s =~ /\!(\S+)/;
	    $rt{'srchtype'} = $tmp{'srchtype'} = $1;
	} else {
	    warn "p3-pager.plx: unable to auto-set project\n";
	}
    }

    # From here on we can guarantee that project is set

    # If project is a glossary force the pager to display a glossary
    $projtype = `/usr/local/oracc/bin/oraccopt $tmp{'project'} type`;
    if ($projtype eq 'glossary') {
	unless ($tmp{'glos'}) {
	    $tmp{'glos'} = `/usr/local/oracc/bin/oraccopt $tmp{'project'} pager-default-glo`;
	}
    }

#    if ($tmp{'asrch'} && $tmp{'asrch'} eq 'yes') {
#	return %tmp;
#    }
#    $tmp{'asrch'} = 'no';
 
    $tmp{'tmpdir'} = tempdir(CLEANUP => 0) unless $tmp{'tmpdir'};
    $tmp{'#qsrch'} = -s "$tmp{'tmpdir'}/search.txt"
	unless $tmp{'asrch'} && $tmp{'asrch'} eq 'yes';
    if ($tmp{'#qsrch'} && $tmp{'srchindex'}) {
	$tmp{'defindex'} = $tmp{'srchindex'};
    } else {
	$tmp{'defindex'} = '#any';
    }

    warn "args: ", Dumper \%tmp;
    # set up some defaults if not all values are given
    $tmp{'cetype'} = 'line' unless $tmp{'cetype'};
    $tmp{'item'} = 0 unless defined $tmp{'item'};
    $tmp{'itemset'} = 0 unless defined $tmp{'itemset'};
    unless ($tmp{'list'} || $tmp{'adhoc'} || $tmp{'srch'} || $tmp{'glos'}) {
	my $special_list = `/usr/local/oracc/bin/oraccopt $tmp{'project'} outline-special-list-name`;
	if ($special_list) {
	    $tmp{'list'} = $special_list;
	    $tmp{'p3outl'} = $tmp{'state'} = 'special' unless $tmp{'p3outl'};
	} else {
	    $tmp{'list'} = '_all';
	    $tmp{'p3outl'} = $tmp{'state'} = 'default' unless $tmp{'p3outl'};
	}
    } elsif ($tmp{'p3outl'}) {
	$tmp{'state'} = $tmp{'p3outl'};
    } else {
	$tmp{'state'} = $tmp{'p3outl'} = 'default';
    }

    $tmp{'page'} = 1 unless $tmp{'page'};
    $tmp{'pageset'} = 1 unless $tmp{'pageset'};
    $tmp{'pagesize'} = 25 unless $tmp{'pagesize'};
    $tmp{'p3do'} = 'default' unless $tmp{'p3do'};
    $tmp{'zoom'} = '0' unless $tmp{'zoom'};
    $tmp{'setlang'} = 'en' unless $tmp{'setlang'};
    $tmp{'translation'} = $tmp{'setlang'};
    if (exists $tmp{'unicode'}) {
	$tmp{'unicode'} = 1;
    } else {
	$tmp{'unicode'} = 0;
    }

    $tmp{'uimode'} = 'full' unless $tmp{'uimode'};
    warn "defindex $tmp{'defindex'}\n";
    warn "+defaults: ", Dumper \%tmp;
    %tmp;
}

su
find_xmdoutline {
    my $eproject = $p{'project'};
    my $parent_project = $eproject;
    $parent_project =~ s#/.*$##;
    if (find_xmdoutline_sub("$oraccwww/$eproject/xmdoutline.xsl")) {
	"$oraccwww/$eproject/xmdoutline.xsl";
    } elsif ($parent_project ne $eproject 
	     && find_xmdoutline_sub("$oraccwww/$parent_project/xmdoutline.xsl")) {
	"$oraccwww/$parent_project/xmdoutline.xsl";
    } else {
	"$oracclib/scripts/p3-xmd-div.xsl";
    }
}

sub
find_xmdoutline_sub {
    my $ok = (-r $_[0] ? 'found' : 'not found');
    warn "trying xmdoutline $_[0] => $ok\n";
    $ok eq 'found';
}

sub
html_by_proxy {
    my($host_project, $id) = @_;
    my $proxy_project = '';
    my $html = undef;
    my $pqid_lst = "$oraccpub/$host_project/cat/pqids.lst";
    my $pqid_entry = `grep -m 1 $id $pqid_lst`;
    chomp $pqid_entry;
    if ($pqid_entry =~ /^(.*?):/) {
	$proxy_project = $1;
	my($id4) = ($id =~ /^(....)/);
	$html = "$oraccbld/$proxy_project/$id4/$id/$id.html";
    }
    ($proxy_project, $html);
}

sub
p3adhoc {
    my $adhoc_list = "$p{'tmpdir'}/results.lst";
    my @adhoc = split(/,/, $p{'adhoc'});
    open(A, ">$adhoc_list") || die "p3-pager: can't write $p{'tmpdir'}/adhoc";
    print A join("\n", @adhoc), "\n";
    close(A);
    $p{'#list'} = $adhoc_list;
    $p{'#listitems'} = $#adhoc + 1;
    $rt{'#list_type'} = ($adhoc[0] =~ /\./ ? 'xtf' : 'cat');
    unless ($force_page) {
	$p{'item'} = 1 unless $p{'item'};
	$rt{'itemtype'} = $p{'p3itemtype'} = 'xtf';
	$rt{'viewtype'} = $p{'viewtype'} = 'item';
	$rt{'what'} = 'item';
	$rt{'outl'} = $p{'p3outl'} || 'default';
    } else {
	$p{'item'} = 0;
	$rt{'viewtype'} = $p{'viewtype'} = 'page';
	$rt{'what'} = 'page';
	$rt{'outl'} = $p{'p3outl'} || 'default';
    }
}

sub
p3srch {
    my $srchtext = shift || '';
    warn "p3srch: rt{'#index'} = $rt{'#index'}; srchtext = $srchtext\n";
    if ($rt{'#index'} eq '#any' && !$srchtext) {
	open(S, "$p{'tmpdir'}/search.txt");
	$rt{'srchtext'} = <S>;
	chomp($rt{'srchtext'});
	close(S);
	warn "search.txt in any mode=$rt{'srchtext'}\n";
	xsystem("$oraccbin/se", '-x', $p{'tmpdir'}, '-j', $p{'project'}, '-a');
    } else {
	if ($srchtext) {
	    $rt{'srchtxt'} = $srchtext;
	    $rt{'#index'} = 'cat';
	} else {
	    open(S, "$p{'tmpdir'}/search.txt");
	    $rt{'srchtext'} = <S>;
	    chomp($rt{'srchtext'});
	    close(S);
	}
	open(S, ">$p{'tmpdir'}/search.txt");
	print S "#$p{'project'} !$rt{'#index'} $rt{'srchtext'}";
	close(S);
	
	warn "search.txt in $rt{'#index'} mode=", `cat $p{'tmpdir'}/search.txt`, "\n";

	xsystem("$oraccbin/se", '-x', $p{'tmpdir'});

	if ($rt{'#index'} =~ /^cbd/) {
	    xsystem('sort', '-o', "$p{'tmpdir'}/results.lst", '-u', "$p{'tmpdir'}/results.lst");
	    my $ncount = `wc -l $p{'tmpdir'}/results.lst`;
	    chomp($ncount);
	    $ncount =~ s/^.*?(\d+).*$/$1/;
	    my $res = `cat $p{'tmpdir'}/results.xml`;
	    $res =~ s,<count>\d+,<count>$ncount,;
	    open(R,">$p{'tmpdir'}/results.xml");
	    print R $res;
	    close(R);
	} else {
	    warn "did not uniq resulst\n";
	}
    }
    set_results_xml_info();
}

sub
reinitialize {
    $p{'page'} = 1;
    $p{'zoom'} = $p{'item'} = 0;
}

sub
run_form_maker {
    my $t = shift;
    my $projectname = '';
    my $projabb = `/usr/local/oracc/bin/oraccopt $p{'project'} abbrev`;
    my $projname = `/usr/local/oracc/bin/oraccopt $p{'project'} name`;
    if ($projname =~ /^$projabb/) {
	$projectname = $projname;
    } else {
	$projectname = "$projabb : $projname";
    }
    print '<!DOCTYPE html>', "\n" unless $t =~ /\.xml$/;
    open(T,$t);
    while (<T>) {
	if (m#^\@\@ga\@\@#) {
	} elsif (/\@\@outlines\@\@/) {
	    print `cat /usr/local/oracc/xml/$p{'project'}/outline-sorter.xml`;
	} elsif (/\@\@translations\@\@/) {
	    print `cat /usr/local/oracc/xml/$p{'project'}/trans-select.xml`;
	} elsif (m#<p>\@</p>#) {
	    if ($p{'glos'}) {
		warn "run_form_maker: glos\n";
		print '<div id="p3left" class="border-right">';
		system "$oraccbin/xfrag", '-u', "/usr/local/oracc/www/$p{'project'}/cbd/$p{'glos'}/p2-toc.html";
		print '</div><div id="p3right" class="p3right80">';
		if ($rt{'#content_url'}) {
		    system "$oraccbin/xfrag", '-u', $rt{'#content_url'};
		} else {
		    if ($proxy_host) {
			xsystem "$oraccbin/proxyhost.plx", $proxy_host, "$p{'tmpdir'}/results.html";
		    } else {
			xsystem 'cat', "$p{'tmpdir'}/results.html";
		    }
		}
		print '</div>';
	    } else {
		warn "run_form_maker: non-glos\n";
		print '<div id="p3left" class="border-right">';
		if ($rt{'#outline_url'}) {
		    system 'cat', $rt{'#outline_url'};
		} else {
		    system 'cat', "$p{'tmpdir'}/outline.html";
		}
		print '</div><div id="p3right" class="p3right80">';
		if ($rt{'#content_url'}) {
		    system 'cat', $rt{'#content_url'};
		} else {
		    if ($proxy_host) {
			xsystem "$oraccbin/proxyhost.plx", $proxy_host, "$p{'tmpdir'}/results.html";
		    } else {
			xsystem 'cat', "$p{'tmpdir'}/results.html";
		    }
		}
		print '</div>';
	    }
	} elsif (m#p3:value=\"\@\@(.*?)\@\@\"#) {
	    my $atat = $1;
	    my($class,$var) = ($atat =~ /^(.*?):(.*?)$/);
	    my $rep = '';
	    my $default = '0';
	    my $fullrep = 0;
	    if ($var =~ s#/(.*)$##) {
		$default = $1;
		$default = '' unless $default; ## @@cgivar:srch/@@ means set 'srch' to empty string
	    }
	    if ($class eq 'cgivar') {
		if (defined $p{$var}) {
		    if ($var eq 'glosDisplay' && $projtype eq 'glossary') {
			$rep = $p{'project'};
			$fullrep = 1;
		    } elsif ($var eq 'list') {
			my $l = $p{$var};
			$l =~ s,^.*?/p3\.,., && $l =~ s,/results.lst,,;
			$rep = $l;
		    } else {
			$rep = $p{$var};
		    }
		} else {
		    if ($var eq 'glosDisplay') {
			if ($projtype eq 'glossary') {
			    $rep = $p{'project'};
			    $fullrep = 1;
			} else {
			    $rep = $p{'glos'};
			}
		    } else {
			$rep = $p{$var};
		    }
		}
		$rep = '' unless $rep; 
		warn "cgivar $var = $rep\n";
	    } elsif ($class eq 'runtime') {
		if (defined $rt{$var}) {
		    if ($var eq 'tmpdir') {
			$rep = $rt{$var} if $p{'asrch'} eq 'yes';
		    } else {
			$rep = $rt{$var};
		    }
		} else {
		    $rep = $default;
		}
		warn "runtime $var = $rep\n";
	    } else {
		warn "bad \@\@ class '$class'\n";
	    }
	    if (m#<(span.*?p3:value.*?)#) {
		if ($fullrep) {
		    s#>(.+)</span>#>$rep</span># || s#/>#>$rep</span>#;
		} else {
		    s#>(.+)</span>#>$1$rep</span># || s#/>#>$rep</span>#;
		}
	    } elsif (m/type="checkbox"/) {
		if ($rep && $rep ne '0') {
		    s/p3/checked="checked" p3/;
		} else {
		    s/ checked="checked"//;
		}
	    } else {
		$rep = '' unless $rep;
		s/\svalue=\".*?\"//;
		s#p3:v# value=\"$rep\" p3:v#;
	    }
	    print;
	} elsif (/\@\@/) {
	    if (/action=\"(.*?)\"/ && !/xforms/) {
		if ($p{'referer'}) {
		    s/action=\"(.*?)\"/action="$p{'referer'}"/;
		} else {
		    s/\@\@project\@\@/$p{'project'}/g;
		}
	    } elsif (/\@\@referer\@\@/) {
		s/\@\@referer\@\@/$p{'referer'}/g;
	    } elsif (/\@\@oas-instance\@\@/) {
		print $oas_instance;
		next;
	    } else {
		s/\@\@project\@\@/$p{'project'}/g
		    || s/\@\@projectname\@\@/$projectname/g
	    }
	    print;
	} else {
	    print;
	}
    }
    close(T);
}

sub
run_item_maker {
    my $id = undef;
    my $hilite_words = undef;
    my($newPage,$sedItem) = ();
    if ($p{'pqx_id'}) {
	# remember page we will return to; we won't recalculate this so if someone items through
	# a bunch of pages they'll just end up where they started
	$p{'xipage'} = ($p{'item'} / $p{'pagesize'}) + (($p{'item'} % $p{'pagesize'}) ? 1 : 0);

	# we've done a search and collapse to get prev/next, and we already know the id
	$id = $p{'pqx_id'};
	# grab the entry from pgwrap.out so we know its item number and hilite words
	$sedItem = `grep -v '^#' $p{'tmpdir'}/pgwrap.out | grep -n $id`;
	chomp $sedItem;
	$hilite_words = $sedItem;
	$sedItem =~ s/:.*$//;
	
	# we already called set_item_page but ignore the results because we're getting the page
	# via the ID
	$newPage = $rt{'page_selector_page_n'};
	$p{'page'} = $newPage;
	$p{'item'} = $sedItem + (($newPage-1) * $p{'pagesize'});
	if (!$hilite_words && $p{'line-id'}) {
	    $hilite_words = $p{'line-id'};
	}
	warn "pqx_id=$p{'pqx_id'}; newPage=$newPage; sedItem=$sedItem; hilite_words=$hilite_words; p{item}=$p{'item'}\n";
	$hilite_words =~ s/^\S+\s\S+\s//;
	my @h = split(/,/,$hilite_words);
	@h = map { s/^.*?://; $_; } @h;
	$hilite_words = join(',',@h);
    } else {
	# first recalibrate item and page: values{item} is an integer
	# from 1 to values{items}; we need to split it into page and
	# offset
	$sedItem = ($p{'item'} % $p{'pagesize'}) || $p{'pagesize'};
	$id = `grep -v '^#' $p{'tmpdir'}/pgwrap.out | sed -n '${sedItem}p'`;
	chomp($id);
	warn "got id=$id from list $p{'#list'} as sedItem $sedItem. newPage = $p{'page'}; thisType=$rt{'itemtype'}\n";
	if ($p{'line-id'}) {
	    $hilite_words = $p{'line-id'};
	} else {
	    $hilite_words = $id;
	    unless ($p{'#list'} =~ /collapsed.out/) {
		$hilite_words =~ s/^\S+\s\S+\s//;
		$hilite_words =~ s/(\S+)://g;
	    } else {
		$hilite_words =~ s/^\S+\s\S+\s//; # this is not really right because we should be setting pqx_id but it works for now
		my @h = split(/,/,$hilite_words);
		@h = map { s/^.*?://; $_; } @h;
		$hilite_words = join(',',@h);
	    }
	}
    }

    if ($hilite_words) {
	$hilite_words = '' unless $hilite_words =~ /\./;
    } else {
	$hilite_words = '';
    }

    warn "### hilite_words = $hilite_words\n";

    my($eproject,$eid) = ($p{'project'},'');
    if ($id =~ /^(.*?):(.*?)$/) {
	($eproject,$eid) = ($1,$2);
    } else {
	$eid = $id;
    }
    my @idinfo = ();
    $eid =~ s/_.*$//;
    $eid =~ s/^.*?://;
    $eid =~ s/\..*$//;
    my $base = $eid;
    $base =~ s/^(....).*$/$1/;
    my $xmd = "/usr/local/oracc/bld/$eproject/$base/$eid/$eid.xmd";

    if ($rt{'itemtype'} eq 'cat') {
	xsystem('xsltproc',
		'-o', "$p{'tmpdir'}/results.html",
		'/usr/local/oracc/lib/scripts/g2-xmd-HTML.xsl',
		$xmd
	    );
    } elsif ($rt{'itemtype'} eq 'xtf' || $rt{'itemtype'} eq 'tra') {
	my $line = $eid;
	$eid =~ s/\..*$//;
	if ($rt{'type'} =~ /^tra|xtf$/ && $rt{'what'} eq 'item') {
	    @idinfo = ce_data_info($sedItem);
	} else {
	    push(@idinfo, '-stringparam', 'line-id', $p{'itemline'})
		if $p{'itemline'} && $p{'itemline'} ne 'none';
	    push(@idinfo, '-stringparam', 'frag-id', $p{'itemctxt'})
		if $p{'itemctxt'} && $p{'itemctxt'} ne 'none';
	}

	my $html = $xmd;
	$html =~ s/xmd$/html/;
	if ($p{'translation'} ne 'en') {
	    if (-r "$html.$p{'translation'}") {
		$html .= ".$p{'translation'}";
	    }
	} else {
	    $html = '' unless -r $html;
	}
	unless (-r $html) {
	    ($eproject,$html) = html_by_proxy($p{'project'}, $eid);
	    unless (-r $html) {
		xsystem('cp',$no_html,"$p{'tmpdir'}/results.html");
		goto OUTLINE;
	    }
	}
	if ($eproject ne $p{'project'}) {
	    $proxy_host = $eproject;
	    warn "proxy_host = $proxy_host; project=$p{'project'}\n";
	}
	warn "cp $html $p{'tmpdir'}/results.html\n";
	xsystem('cp',$html,"$p{'tmpdir'}/results.html");
	sig_fixer($p{'project'});
	if ($hilite_words) {
	    xsystem("$oraccbin/p3-selector.plx", "$p{'tmpdir'}/results.html", $hilite_words);
	}
      OUTLINE:
	my @args = ('-stringparam', 'project', $eproject);
	if ($eid =~ /^Q/) {
	    my $eid4 = $eid;
	    $eid4 =~ s/^(....).*$/$1/;
	    my $xtl = "/usr/local/oracc/bld/$p{'project'}/$eid4/$eid/$eid.xtl";
	    if (-r $xtl) {
		push @args, '-param', 'xtl', 'true()';
	    }
	}
	xsystem('xsltproc', 
		@args,
		'-o', "$p{'tmpdir'}/outline.html",
		find_xmdoutline(),
		$xmd);
    } elsif ($rt{'itemtype'} eq 'cbd') {
	$rt{'#content_url'} = "/usr/local/oracc/www/$p{'project'}/cbd/$p{'glos'}/$id.html";
    } elsif ($rt{'itemtype'} eq 'ood') {
	xsystem("$oraccbin/xfrag /usr/local/oracc/pub/$p{'project'}/data.xml $id | xsltproc -stringparam html yes /usr/local/oracc/lib/scripts/ood-record.xsl - >$p{'tmpdir'}/results.html");
    } else {
	warn "p3-pager.plx: no handler for type = $rt{'itemtype'}\n";
    }
}

sub
run_glos_maker {
    set_runtime_vars();
    print "Content-type: text/html; Encoding=utf-8\n\n";
    run_form_maker();
}

sub
run_page_maker {
    my $vminus = $p{'page'} || 0;
    $vminus -= 1 if $vminus;
    my $ce_arg = set_ce_arg();
    my $item_offset = ($vminus) * $p{'pagesize'};
    my @offset_arg = ('-o', $item_offset);
    my @offset_param = ('-stringparam', 'item-offset', $item_offset);
    if ($rt{'#list_type'} eq 'xtf') { ## sigfixer may need adding to end of pipe here some day
	xsystem("cat $p{'tmpdir'}/pgwrap.out | $oraccbin/ce_xtf -3 $ce_arg -p $p{'project'} | $oraccbin/s2-ce_trim.plx >$p{'tmpdir'}/content.xml");
	xsystem('xsltproc', '-stringparam', 'fragment', 'yes', '-stringparam', 'project', $p{'project'}, @offset_param, 
		'-o', "$p{'tmpdir'}/results.html", '/usr/local/oracc/lib/scripts/p3-ce-HTML.xsl', "$p{'tmpdir'}/content.xml");
    } elsif ($rt{'#list_type'} eq 'cat' || $rt{'#list_type'} eq 'tra') {
	my $link_fields = `/usr/local/oracc/bin/oraccopt $p{'project'} catalog-link-fields`;
	my $lfopt = ($link_fields ? "-a$link_fields" : '');
	warn "lfopt=$lfopt\n";
	xsystem("cat $p{'tmpdir'}/pgwrap.out | $oraccbin/ce2 -3 $lfopt -S$rt{'outl'} @offset_arg -i$rt{'#list_type'} -p $p{'project'} >$p{'tmpdir'}/content.xml");
	xsystem('xsltproc', '-stringparam', 'fragment', 'yes', '-stringparam', 'project', $p{'project'}, @offset_param, 
		'-o', "$p{'tmpdir'}/results.html", '/usr/local/oracc/lib/scripts/p3-ce-HTML.xsl', "$p{'tmpdir'}/content.xml");
    } elsif ($rt{'#list_type'} eq 'cbd') {
	xsystem("cat $p{'tmpdir'}/pgwrap.out | $oraccbin/ce2 -3 -icbd/$p{'glos'} -p $p{'project'} >$p{'tmpdir'}/content.xml");
	xsystem('xsltproc', '-stringparam', 'fragment', 'yes', '-stringparam', 'project', $p{'project'}, @offset_param, 
		'-o', "$p{'tmpdir'}/results.html", '/usr/local/oracc/lib/scripts/p3-ce-HTML.xsl', "$p{'tmpdir'}/content.xml");    
    } else {
	warn "run_page_maker: no list_type set (rt{'#list_type'} == $rt{'#list_type'}\n";
    }
}

sub
set_asrch_info {
    
}

sub
set_ce_arg {
    my $ce_arg;
    warn "set_ce_arg: rt{'cetype'} == $rt{'cetype'}; rt{'#list_type'} == $rt{'#list_type'}\n";
    if ($rt{'cetype'}) {
	$ce_arg = $rt{'cetype'};
	$ce_arg =~ s/^(.).*$/-$1/;
    } elsif ($rt{'#list_type'} eq 'xtf') {
	$ce_arg = '-l';
    } else {
	$ce_arg = '';
    }
    $ce_arg;
}

sub
set_item_page {
    my $newPage = ($p{'item'} / $p{'pagesize'});
    ++$newPage if $p{'item'} % $p{'pagesize'};
    $p{'page'} = $newPage;
}

sub
set_list_items {
    $p{'#listitems'} = `wc -l $p{'#list'}`;
    chomp($p{'#listitems'});
    $p{'#listitems'} =~ s/^.*?(\d+).*?$/$1/;
    warn "set_list_items: list=$p{'#list'}; count=$p{'#listitems'}\n" if $verbose;
}

sub
arg_state {
    if ($p{'arg_item'}) {
	if ($p{'arg_item'} > 0) {
	    $p{'item'} = $p{'arg_item'};
	    $p{'p3do'} = 'viewstateItems';
	} else {
	    $p{'item'} = 0;
	}
	$p{'arg_item'} = 0;
    }
}

sub
set_p3_state {

    if ($p{'#qsrch'}) {
	$rt{'prod'} = 'srch';
	if ($p{'p3outl'} ne 'default') {
	    $rt{'sorttype'} = $p{'p3OSdefault'};
	    warn "(7) sorttype set to $rt{'sorttype'}\n";
	} else {
	    $rt{'sorttype'} = $p{'sorttype'};
	    warn "(8) sorttype set to $rt{'sorttype'}\n";
	}
	$rt{'outl'} = 'default';
	if ($p{'glos'}) {
	    $rt{'#index'} = "cbd/$p{'glos'}";
	    $rt{'srchtype'} = 'cbd';
	    $p{'glet'} = '';
	} else {
	    $rt{'#index'} = $rt{'srchtype'} = $p{'defindex'}; # $p{'p3srchtype'} ||
	}
    } else {
	$rt{'prod'} = 'list';
	$rt{'outl'} = $p{'p3outl'} || $p{'state'};
    }

    if ($p{'p3do'} eq 'qsrch') {
	$p{'item'} = 0;
	# we're going to ring-fence asrch ui so this is not going to be necessary in the end
	$p{'asrch'} = 'no';
    }

    if ($p{'zoom'} > 0) {
	$rt{'mode'} = 'zoom';
    } else {
	$rt{'mode'} = 'full';
    }

    if ($p{'form'}) {
	$rt{'form'} = $p{'form'};
    } else {
	$rt{'form'} = 'full';
    }

    if ($p{'type'}) {
	$rt{'type'} = $p{'type'};
    } elsif ($rt{'prod'} eq 'list') {
	if ($p{'glos'}) {
	    $rt{'type'} = 'cbd';
	} else {
	    $rt{'type'} = 'cat';
	}
    } else {
	if ($p{'glos'}) {
	    $rt{'type'} = 'cbd';
	} if ($p{'thisIndex'}) {
	    $rt{'type'} = $rt{'#index'};
	} else {
	    $rt{'type'} = 'cat';
	}
    }

    # Whether the item is a cat-item or a text-item is controlled by the item
    # content constructor based on the $rt{'itemtype'} parameter (set by p3itemtype).
    if ($p{'item'}) {
	$rt{'what'} = 'item';
	$rt{'outl'} = $p{'p3outl'} || 'default';
    } else {
	$rt{'what'} = 'page';
	if ($rt{'prod'} eq 'list') {
	    # some lists need default and some special--this needs more working out
	    if ($rt{'outl'} eq 'special') {
		if ($p{'p3outl'} ne 'special') {
		    $rt{'sorttype'} = $p{'sorttype'} || $p{'p3OSspecial'};
		    warn "(9) sorttype set to $rt{'sorttype'}\n";
		} else {
		    $rt{'sorttype'} = $p{'sorttype'};
		    warn "(10) sorttype set to $rt{'sorttype'}\n";
		}
	    } else {
		if ($p{'p3outl'} ne 'default') {
		    $rt{'sorttype'} = $p{'sorttype'} || $p{'p3OSdefault'};
		    warn "(11) sorttype set to $rt{'sorttype'}\n";
		} else {
		    $rt{'sorttype'} = $p{'sorttype'}|| $p{'p3OSspecial'};
		    warn "(12) sorttype set to $rt{'sorttype'}\n";
		}
	    }
	    unless ($rt{'sorttype'}) {
		$rt{'sorttype'} = `/usr/local/oracc/bin/oraccopt $p{'project'} outline-$rt{'outl'}-sort-fields`;
	    }
#	    warn "###sorttype = $rt{'sorttype'}\n";
	} else {
	    # handle special list where necessary
	}
    }
}

sub
set_results_xml_info {
    open(X, "$p{'tmpdir'}/results.xml");
    my $xinfo = <X>;
    $xinfo =~ m#<count>(.*?)<#;
    $p{'#listitems'} = $1;
    $p{'#list'} = "$p{'tmpdir'}/results.lst";
    if (-r "$p{'tmpdir'}/any") {
	open(X, "$p{'tmpdir'}/any");
	my @any = (<X>);
	close(X);
	chomp @any;
	my($any_res_index) = ($any[0] =~ /^.(\S+)/);
	if ($any_res_index eq 'txt' || $any_res_index eq 'lem') {
	    $rt{'#list_type'} = 'xtf';
	} else {
	    $rt{'#list_type'} = $any_res_index;
	}
	$rt{'srchtype'} = $p{'srchtype'} = $any_res_index; # 'srchindex' ??
    } elsif ($p{'glos'}) {
	$rt{'#list_type'} = 'cbd';
	$rt{'srchtype'} = $p{'srchtype'} = 'cbd';
    }
    warn "rt{'#list_type'} set to $rt{'#list_type'}\n";
    $xinfo =~ m#<count>(.*?)<#;
    if ($p{'glos'} && ($p{'#listitems'} == 1 || $p{'glet'})) {
	$p{'item'} = 1;
	$rt{'itemtype'} = $p{'itemtype'} = 'cbd';
	$p{'viewtype'} = 'item';
	$p{'xipage'} = 1;
	$rt{'what'} = 'item';
    }
}

sub
set_runtime_vars {
    if (open(P, "$p{'tmpdir'}/pg.info")) {
	while (<P>) {
	    next if /^\#/;
	    chomp;
	    my($k,$v) = (/^(\S+)\s+(\S+)$/);
	    $rt{$k} = $v;
	}
	close(P);
    } else {
	# this is a search with 0 results
	@rt{qw/pages items uzpage zprev znext/} = (0,0,0,0,0);
	$rt{'#outline_url'} = "/usr/local/oracc/www/empty.div";
	$rt{'#content_url'} = "/usr/local/oracc/www/noresults.div";
    }
}

sub
set_sorttype {
    if ($p{'sorttype'}) {
	$rt{'sorttype'} = $p{'sorttype'};
	warn "(1) sorttype set to $rt{'sorttype'}\n";
    } elsif ($p{'p3outl'} eq 'special') {
	$rt{'sorttype'} = $p{'p3OSspecial'};
	warn "(2) sorttype set to $rt{'sorttype'}\n";
    } elsif ($p{'p3outl'} eq 'default') {
	$rt{'sorttype'} = $p{'p3OSdefault'};
	warn "(3) sorttype set to $rt{'sorttype'}\n";
    } else { # this can't happen ...
	warn "(4) sorttype set to $rt{'sorttype'}\n";
	$rt{'sorttype'} = $p{'p3OSdefault'};
    }
}

# perform any nav actions
sub
setup_navigation {

    # Note that the button which is visible gives the current state
    # so we have to reverse them to toggle.
#    if ($p{'p3do'} eq 'itemstateText') {
#	$rt{'itemtype'} = $p{'itemtype'} = 'cat';
#    } elsif ($p{'p3do'} eq 'itemstateCat') {
#	$rt{'itemtype'} = $p{'itemtype'} = 'xtf';
#    } elsif ($p{'item'}) {
#	$rt{'itemtype'} = $p{'itemtype'};
#    }

    if ($p{'p3do'} eq 'viewstateItems') { # can be called from form or clicking on item
	$rt{'viewtype'} = $p{'viewtype'} = 'item';
	$p{'item'} = 1 unless $p{'item'};
#	unless ($p{'itemtype'}) {
#	    $rt{'itemtype'} = $p{'itemtype'} = 'xtf';
#	}
	$rt{'itemtype'} = $p{'itemtype'} = ($p{'glos'} ? 'cbd' : 'xtf');
	$p{'xipage'} = $p{'page'};
    } elsif ($p{'p3do'} eq 'viewstatePages') {
	$rt{'viewtype'} = $p{'viewtype'} = 'page';
	$p{'item'} = 0;
	$p{'page'} = $p{'xipage'} || 1;
	$force_page = 1;
	$rt{'itemtype'} = $p{'itemtype'} = ($p{'glos'} ? 'cbd' : 'cat');
    } elsif ($p{'item'}) {
	$rt{'itemtype'} = $p{'itemtype'};
    }

    if ($p{'p3do'} eq 'defaultSortstate') {
	if ($p{'p3outl'} ne 'default') {
	    $rt{'sorttype'} = $p{'sorttype'} = $p{"p3OSdefault"};
	    warn "(5) sorttype set to $rt{'sorttype'}\n";
	}
	reinitialize();
    } elsif ($p{'p3do'} eq 'specialSortstate') {
	if ($p{'p3outl'} ne 'special') {
	    $rt{'sorttype'} = $p{'sorttype'} = $p{"p3OSspecial"};
	    warn "(6) sorttype set to $rt{'sorttype'}\n";
	}
	reinitialize();
    } else {
	set_sorttype();
    }

    if ($p{'p3do'} eq 'pagefwd') {
	if ($p{'page'} < $p{'pages'}) {
	    ++$p{'page'};
	}
    } elsif ($p{'p3do'} eq 'pageback') {
	if ($p{'page'} > 1) {
	    --$p{'page'};
	}
    } elsif ($p{'p3do'} eq 'pageset') {
	if ($p{'pageset'} <= 0 || $p{'pageset'} > $p{'pages'}) {
	    $p{'page'} = 1;
	} else {
	    $p{'page'} = $p{'pageset'};
	}
    } elsif ($p{'p3do'} eq 'itemfwd') {
	if ($p{'item'} < $p{'items'}) {
	    ++$p{'item'};
	    set_item_page();
	}
    } elsif ($p{'p3do'} eq 'itemback') {
	if ($p{'item'} > 1) {
	    --$p{'item'};
	    set_item_page();
	}
    } elsif ($p{'p3do'} eq 'itemset') {
	if ($p{'item'} <= 0 || $p{'item'} > $p{'items'}) {
	    $p{'item'} = 1;
	}
	set_item_page();
    } elsif ($p{'p3do'} eq 'qsrch') {
	reinitialize();
    }
}

sub
setup_pg_args {
    $p{'page'} = 1 unless $p{'page'};
    my $tmpstate = undef;

    if ($p{'#qsrch'}) {
	$tmpstate = 'default';
    } else {
	$tmpstate = ($p{'p3outl'} =~ /^default|special$/ ? $p{'p3outl'} 
		     : ($p{'pushed-state'} ? $p{'pushed-state'} : 'default'));
    }

    @pg_args = ('-fm', "-p$p{'project'}", "-P$p{'pagesize'}", 
		"-S$tmpstate");

    if ($p{'pqx_id'}) {
	push @pg_args, "-i$p{'pqx_id'}";
    } else {
	push @pg_args, "-n$p{'page'}";
    }

    push @pg_args, '-q', if $rt{'#list_type'} eq 'cbd';
    if ($rt{'sorttype'}) {
	my $tmp = $rt{'sorttype'};
#
# Shouldn't be necessary now that Slicer is built in
#
#	$tmp =~ tr/_/^/; # escape field names like ch_no 
#
	push(@pg_args, "-s$tmp") if $tmp;
    }
    push @pg_args, "-z$p{'zoom'}" if $p{'zoom'};
    push @pg_args, '-3';
}

# sig_fixer($project)
sub
sig_fixer {
    my $p = shift;
    local($/) = undef;
    open(T, "$p{'tmpdir'}/results.html");
    my $text = <T>;
    close(T);
    $text =~ s/^<\!DOCTYPE.*?>\n//;
    my $l = '';
    my $reps = ($text =~ s/(pop1sig\()/pop1sig('$p','$l',/go);
    open(T,">$p{'tmpdir'}/results.html");
    print T $text;
    close(T);
}

sub
xsystem {
    warn "system @_\n"
	if $verbose;
    system @_;
}

#################################################################################################

sub
p3_oas_triage {
    warn "asSubmit = $p{'asSubmit'}\n";
    if ($p{'asSubmit'}) {
	$p{'tmpdir'} = "/tmp/p3$p{'list'}";
	# User has clicked on one of the buttons on the search results pager
	if ($p{'asSubmit'} eq 'edit') {
	    $oas_instance = `cat $p{'tmpdir'}/search.xml`;
	    $oas_instance =~ s/search>/search xmlns="">/;
	    print "Content-type: text/xml; charset=utf-8\n\n";
	    run_form_maker($oas_template);
	    goto EXIT;
	} else {
	    $oas_instance = `cat /usr/local/oracc/lib/data/oas-instance.xml`;
	    print "Content-type: text/xml; charset=utf-8\n\n";
	    run_form_maker($oas_template);
	    goto EXIT;
	}
    } else {
	if ($p{'asrchxf'} && $p{'asrchxf'} eq 'yes') {
	    # run the search that has come in via xforms
	    print STDERR "p3_oas_triage: running p3-asrch.sh\n";
	    system "/usr/local/oracc/bin/p3-asrch.sh", $p{'tmpdir'}, $p{'project'};
	    $p{'asrch'} = 'yes';
	    # This sets things up so p3-pager will initialize from the results
	    $p{'list'} = "$p{'tmpdir'}/results.lst";
	    if (-s $p{'list'}) {
		my $l1 = `head -1 $p{'list'}`;
		if ($l1 =~ /_/) {
		    $p{'srchtype'} = $rt{'#list_type'} = 'tra';
		} elsif (2 == $l1 =~ tr/././) {
		    $p{'srchtype'} = 'txt';
		    $rt{'#list_type'} = 'xtf';
		} else {
		    $p{'srchtype'} = $rt{'#list_type'} = 'cat';
		}
	    }
	} else {
	    # if there is no search result in the tmpdir just send out a new xform
	    $p{'tmpdir'} = "/tmp/p3$p{'list'}";
	    $p{'list'} = "/tmp/p3$p{'list'}/results.lst";
	    unless (-r "$p{'tmpdir'}/results.lst") {
		warn "p3_oas_triage: no $p{'tmpdir'}/results.lst\n";
		$oas_instance = `cat /usr/local/oracc/lib/data/oas-instance.xml`;
		print "Content-type: text/xml; charset=utf-8\n\n";
		run_form_maker($oas_template);
		goto EXIT;
	    } else {
		# Fall through to let p3-pager do it's stuff with page/item nav
		warn "p3_oas_triage: falling through using $p{'tmpdir'}/results.lst\n";
	    }
	}
    }
}

1;
