#!/usr/bin/perl


use warnings;
use strict;

my $count =1;

while(my $row = <stdin>){
	chomp $row;
	if($row =~ m/([\w\-.]*$)/){
		print("$row || $1 ".$count++."\n");
		system("git log -p $row > ../cfile/$1.txt");
	}
}
