#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include "resolver.h"

void
oid(const char *e2)
{
  print_hdr();
  execl("/usr/bin/perl", "perl", "/Users/stinney/orc/bin/oid-resolver.plx",
	project,
	e2,
	NULL);
}
