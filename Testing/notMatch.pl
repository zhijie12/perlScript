#!/usr/bin/perl


use strict;
use warnings;

my $a =1;
while(my $row = <stdin>){
	chomp $row;
if(!($row =~ m/(Milo)/)){

	print $a."\n";
	$a+=1;
	}
}

