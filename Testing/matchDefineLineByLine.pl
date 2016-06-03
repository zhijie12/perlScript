#!/usr/bin/perl

use strict;
use warnings;

#version 1


#TODO support for multiple files.

#my $filename = '../linux-stable-security/output/zfcp_aux.c.txt';
#open(my $file, '<:encoding(UTF-8)', $filename) 
#	or die "could not open file '$filename' $!";

my $tmpAuthor=undef;
my $tmpCommit=undef; 

my $pIndex=0;
my @pArray=undef;
my @pAuthorArray=undef;
my @pCommit=undef;

my $nIndex =0;
my @nArray;
my @nAuthorArray=undef;
my @nCommit=undef;

my $bIndex=0;
my @badAuthor;
my @badAuthorCount=undef;

#while (my $row = <$file>) {
while (my $row = <stdin>){
	chomp $row;
	if($row =~ m/Author: (.*)/){ #find author then get the rest of the line 
		$tmpAuthor= $1;
		#print("Author: $tmpAuthor\n")
	}

	if($row =~ m/commit \+?([ \w]{40})/ ){ #find commit, the optional supports both with + and no plus in the commit

		$tmpCommit = $1;
		#print("commit: $tmpCommit\n");	
	}


	if($row =~ m/^-#define ([[:alnum:]_]+)/) { #find -define and save them with the author 
		#print("$1\n"); 
		$nAuthorArray[$nIndex] = $tmpAuthor;
		$nArray[$nIndex] = $1;
		$nCommit[$nIndex] = $tmpCommit;
		$nIndex++;
       	}

	elsif($row =~ m/^\+#define ([[:alnum:]_]+)/) {  #find +define and save them with the author 

		$pAuthorArray[$pIndex] = $tmpAuthor;
		$pArray[$pIndex] = $1;	
		$pCommit[$pIndex] = $tmpCommit;
		$pIndex++;
	}

	for(my $i=0; $i<@nArray && ($pIndex-1) > 0 &&@nArray > 0; $i++){	


		if($nArray[$i] eq $pArray[$pIndex-1] && 
			$nCommit[$i] ne $pCommit[$pIndex-1] ){

			#print("$pCommit[$pIndex-1]\n");
			#print("$nArray[$i]\n");
			#print("$pAuthorArray[$pIndex-1]\n");
			#print("\n");

			my $tmpBadAuthor = $pAuthorArray[$pIndex-1];
			
			#my $badAuthorC = @badAuthor;
			#print("@badAuthor");
			#$badAuthor[0] = $tmpBadAuthor;


			if(@badAuthor == 0){
				$badAuthor[$bIndex] = $tmpBadAuthor;
				$badAuthorCount[$bIndex] = 1;
				$bIndex++;

			}
			else{
				#my %params = map { $_ => 1 } @badAuthor;
				#if(exists ($params{$tmpBadAuthor})){
				#	print("hello: $tmpBadAuthor \n");
				#}
				my $n=0;
				for($n=0; $n<@badAuthor; $n++){
					if($badAuthor[$n] eq $tmpBadAuthor){
						$badAuthorCount[$n]++;
						last;
					}
				}
				if($n == @badAuthor){
					$badAuthor[$bIndex] = $tmpBadAuthor;
					$badAuthorCount[$bIndex] = 1;
					$bIndex++;
				}

			}
			
			$nArray[$i] = ""; #after match, set as empty so will not repeat
			last;
		}
	}			

}

for(my $i=0; $i<@badAuthor; $i++){
	#print("$badAuthor[$i]       \t| $badAuthorCount[$i] \n");
	printf "%-70s %-20s \n", $badAuthor[$i], "| Times: $badAuthorCount[$i]";

}
