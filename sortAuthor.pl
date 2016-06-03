#!/usr/bin/perl

use strict;
use warnings;

#version 1
my %line;
while(my $row = <stdin>){
	chomp $row;
	if($row =~ m/(.*) \|( \d+)/){
		#print("$1 |$2\n");
		$line {$1} = $2; 
	}
}

foreach my $k (sort {$line{$a} <=> $line{$b} } keys %line){
	
	print $k.$line{$k}."\n"
}




