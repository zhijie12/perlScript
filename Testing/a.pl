#!/usr/bin/perl -w

use strict;

my $match = undef;
while (my $line = <STDIN>) {
	chomp ($line);

	if ($line =~ m/^-#define ([[:alnum:]]+)/) {
		$match = $1;
		print "my line: $line\n ";
	} elsif ($line =~ m/^\+#define ([[:alnum:]]+)/) {
		if (defined ($match) && $match eq $1) {
			print "another line: $match redefined\n";
		}
	}
}
