#!/usr/bin/perl

use strict;
use warnings;

if (scalar(@ARGV) > 0){
    my $hostname = $ARGV[0];
    my ($true_name, $aliases, $addrtype, $addrlength, @addrs) = gethostbyname($hostname);

    if (defined $true_name) {
	my ($a, $b, $c, $d) = unpack('C4', $addrs[0]);

	print "$a.$b.$c.$d\n";
    }
};
