#!/usr/bin/perl

use strict;
use warnings;

#version 1 



#my $filename = '../linux-stable-security/output/zfcp_aux.c.txt';
#open(my $file, '<:encoding(UTF-8)', $filename) 
#	or die "could not open file '$filename' $!";

my $tmpAuthor=undef;
my $tmpCommit=undef; 
my $prevCommit=undef;
my $file=undef;
my $lineNo;
my $ifbuf=undef;

my $bIndex=0;
my @badAuthor;
my @badAuthorCount=undef;

my $nline = 1;
my %d = ();
#while (my $row = <$file>) {
while (my $row = <stdin>){
	chomp $row;

	if($row =~ m/Author: (.*)/){ 
		#find author then get the rest of the line 
		$tmpAuthor= $1;
		#print("Author: $tmpAuthor\n")
	}

	if($row =~ m/@@ -(\w*),(\w*) \+(\w*),(\w*)/){
		$lineNo = $1;
#		print("$lineNo\n");
	}

	if($row =~ m/commit \+? ([\w]{40})/ ){ 
		#find commit, the optional supports both with + and no plus in the commit

		if(defined $tmpCommit){
			$prevCommit = $tmpCommit; 
#			print($prevCommit."\n");
		}
		$tmpCommit = $1;
		#print("commit: $tmpCommit\n");	
	}

	if($row =~ m/\+{3} b\/([\w\/.]*)/ && !defined $file){
		#Get the file path
		$file = $1;
#		print("$file\n");
	}



	if($row =~ m/^(\+[\t ]*if[\w &|<>\+=()\[\]'":_.,!->%]+)/) {  
		#find -if and save them with the author, commit and line number
#		print("$nline:$1\n");

		$d {$tmpCommit}{nauthor} = $tmpAuthor;
		$d {$tmpCommit}{pif} = $1;
		$d {$tmpCommit}{n} = $nline;
		$d {$tmpCommit}{prevCommit} = $prevCommit;
		$d {$tmpCommit}{lineNo} = $lineNo;
	} 

	elsif($row =~ m/^(\-[\t ]*if[\w &|<>\+=()\[\]'":_.,!->%]+)/) {  
		#find +if and save them with the author, commit and line number
#		print("$nline:$1\n");
		$d {$tmpCommit}{pauthor} = $tmpAuthor;
		$d {$tmpCommit}{nif} = $1;
		$d {$tmpCommit}{p} = $nline;
		$d {$tmpCommit}{prevCommit} = $prevCommit;
		$d {$tmpCommit}{lineNo} = $lineNo;
	}

	$nline ++;
}

my %bad_author = ();
foreach my $k (keys (%d))
{
	if (exists ($d{$k}{p}) && exists ($d{$k}{n})) { #if exist a -if and a +if in the same commit
# 		print( "commit: $k \n" );
#		print(" Positive: $d{$k}{p} $d{$k}{pif} \n Negative: $d{$k}{n} $d{$k}{nif}\n");
#		print(( ($d{$k}{p} - $d{$k}{n}))."\n");

		if ( ($d{$k}{p} - $d{$k}{n}) == 1 ) { #+if line number within 3 line of the -if 
#			print("pushed $d{$k}{p}\n");
			my $pline = $d{$k}{p};
			my $nline = $d{$k}{n};
			push (@{$bad_author {$d{$k}{pauthor}}}, "$pline:$nline (Updated if statement constraints)\nCommit:$k\nPrevCommit:$d{$k}{prevCommit}\nFile: $file\nLineNo:$d{$k}{lineNo}\nnif:$d{$k}{nif}\npif:$d{$k}{pif}");
		}
	}
}
my $nextCommit;
my $filename;
my $index=1;
foreach my $k (keys (%bad_author)) {
	printf "%-80s %-0s \n", $k, "| " .  scalar (@{$bad_author {$k}});
#	print "$k |" . scalar (@{$bad_author {$k}}) . "\n";
	foreach my $lines (@{$bad_author {$k}}) {
		print "$lines\n\n";
		if($lines =~ m/Commit:([\w]{40})\nPrevCommit:([\w]{40})\nFile: ([\w\/.]*)\nLineNo:([\w]*)/){
			#	print("Commit:$1\n");
			#	print("Prev C:$2\n");
			#	print("File:$3\n");
				print("Lineno:$4\n");
			#Now I have the Current Commit
			#Need to get the next commit
			my $curCommit=$1;
			my $preCommit=$2;
			my $curFile=$3;

			#Getting the file name
			if($curFile =~ m/([\w]*).c$/){
#				print("$1\n");
				$filename = $1;
			}
			
			#Getting the next commit
			my $output = `git log -n 2 $curCommit | grep commit`;
			if($output =~ m/commit [\w]{40}\ncommit ([\w]{40})/){
				$nextCommit = $1;
				print "Next Commit: $nextCommit "; print("\n");#Get the next commit
			}

			#Checkout current file then copy outside
			system("mkdir ../output/$filename$index");print("\n");
			#Apply git diff from current and next to get the patch
			system("git diff --no-prefix $curCommit $nextCommit $curFile > ../output/".$filename.$index."/".$filename."diff"); print("\n");
			system("git checkout $curCommit $curFile");print("\n");
			system("cp $curFile ../output/$filename$index/".$filename."Curr.c");print("\n");

			system("git checkout $nextCommit  $curFile");print("\n");
			system("cp $curFile ../output/$filename$index/".$filename."Next.c");print("\n");
#			system("");
				
		}
	}
	$index++;
	print("\n\n");
}

