#!/usr/bin/perl

use strict;
use warnings;


my $lineNo =1;
my @lineArray;
my @rowArray;
my $index=0;

#while(my $row = <stdin>){
#	chomp $row;
#
#	#if($row =~ m/^\+[ ]*B/g){
#	if($row =~ /\+[\W]*if/){
#		$rowArray[$index] = $row;
#		$lineArray[$index] = $lineNo;
#		$index++;		
#	}
#
#	$lineNo++;
#}


#concat the lines
my $file="";
while(my $row = <stdin>){
	$file = $file.$row;	
}
#print("$file");

#if($file =~ m/\+[\t ]*(if[ ()\[\]='"&|!*+\w\d]*)/){
while($file =~ m/\+[\W ]*(if[\t\w+=_\-!| (*&><\.%,:'"\[\] \)]*)/gm){
	print "$1\n";
}


#for (my $i=0; $i<@lineArray; $i++)
#{
#	print("$lineArray[$i]");
#	print("$rowArray[$i]\n");
#}
