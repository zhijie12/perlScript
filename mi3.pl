#!/usr/bin/perl

use strict;
use warnings;

#version 1 



#my $filename = '../linux-stable-security/output/zfcp_aux.c.txt';
#open(my $file, '<:encoding(UTF-8)', $filename) 
#	or die "could not open file '$filename' $!";

my $lineBuffer;
my $leftBracket=0;
my $rightBracket=0;

my $tmpAuthor=undef;
my $tmpCommit=undef; 
my $prevCommit=undef;
my $file;
my $lineNo;
my $ifbuf=undef;

my $bIndex=0;
my @badAuthor;
my @badAuthorCount=undef;

my $nline = 1;
my %d = ();
my %d2 = ();
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

	if($row =~ m/commit ([\w]{40})/ ){ 
		#find commit, the optional supports both with + and no plus in the commit
		#print("commit: $tmpCommit\n");	
		$tmpCommit = $1;
	}

	if($row =~ m/\+{3} b\/([\w.\/\-]*)/){
		#Get the file path
		$file = $1;

#		print("$file\n");
	}



	#find -if and save them with the author, commit and line number
	if($row =~ m/^\+[\t ]*(if[\w ^~&|\{\}<>\+=()\[\]'":_.,!->%]+)/m) {  
#		print("$nline:$1\n");
		#
		#		#This part is used to match the whole of If statement
		#		$row = $1;
		#		while(){
		#			foreach my $a (split //, $row) {
		#				if($a =~ m/\(/){
		#					$leftBracket++;
		#				}elsif ($a =~ m/\)/){
		#					$rightBracket++;
		#				}
		#			}
		##			print("L: $leftBracket R: $rightBracket\n");
		#			if($leftBracket ne $rightBracket){
		#				my $tmpRow = <stdin>;
		#				$nline++;
		#				if($tmpRow =~ m/[\+\s]*(.*)/){
		#
		#					$row = $row.$1;
		##					print($row);
		#				}	
		#				$leftBracket = $rightBracket = 0;
		#				print($row."\n");
		#
		#			}
		#			else{ 
		#				#break when equal number of brackets
		#				#Can be further modified to match the whole if statement contents
		#				#However the snipplet of the git diff does not really allow this
		#				last;
		#			}
		#		}
		#

		#Hash map to find change of if statements
		$d {$tmpCommit}{$nline}{pauthor} = $tmpAuthor;		
		$d {$tmpCommit}{$nline}{file} = $file;
		$d {$tmpCommit}{$nline}{pif} = $1;
		$d {$tmpCommit}{$nline}{lineNo} = $lineNo;
		$d {$tmpCommit}{$nline}{p} = $nline;
	
		#Hash map to find the original author that wrote the if statement
		$d2{$1}{pif} = $tmpAuthor; #original author that added the if statement
		$d2{$1}{commit} = $tmpCommit; #commit to find the if statement
		$d2{$1}{lineNo} = $nline; #line number of the added if statement 
	} 

	#find +if and save them with the author, commit and line number
	elsif($row =~ m/^\-[\t ]*(if[\w ^~&|\{\}<>\+=()\[\]'":_.,!->%]+)/m) {  
		#Hash map to find change of if statements
		$d {$tmpCommit}{$nline}{nauthor} = $tmpAuthor;
		$d {$tmpCommit}{$nline}{file} = $file;
		$d {$tmpCommit}{$nline}{nif} = $1;
		$d {$tmpCommit}{$nline}{lineNo} = $lineNo;
		$d {$tmpCommit}{$nline}{n} = $nline;
		
	}

	$nline ++;
}


my $originalAuthor;
my $originalCommit;
my $originalLine;

my %bad_author = ();
foreach my $commit (keys (%d) ) {
	foreach my $line (keys %{ $d{$commit} } ){

		#Only check for those 1 line differences
		if(exists $d{$commit}{$line}{p} && exists $d{$commit}{$line-1}{n}
			&& $d{$commit}{$line}{pif} ne $d{$commit}{$line-1}{nif}){
			
			#lines of the remove&add commits
			my $pline = $d{$commit}{$line}{p}; 
			my $nline = $d{$commit}{$line-1}{n};

			$originalAuthor = $d2{ $d{$commit}{$line-1}{nif} }{pif};   #original author that added the if statement
			$originalCommit = $d2{ $d{$commit}{$line-1}{nif} }{commit};   #original author's commit
			$originalLine = $d2{ $d{$commit}{$line-1}{nif} }{lineNo};   #original author's line Number 
			
			push (@{$bad_author {$originalAuthor}}, 
				"$pline:$nline\nCommit:$commit\nFile: $d{$commit}{$line}{file}\nLineNo:$d{$commit}{$line}{lineNo}\noriginalCommit:$originalCommit\noriginalLine:$originalLine\nnif:$d{$commit}{$line-1}{nif}\npif:$d{$commit}{$line}{pif}" ); #{$d{$commit}{$line}{pauthor}}
		}	
	
	}
	#
	#	if (exists ($d{$commit}{p}) && exists ($d{$commit}{n})) { #if exist a -if and a +if in the same commit
	## 		print( "commit: $commit \n" );
	##		print(" Positive: $d{$commit}{p} $d{$commit}{pif} \n Negative: $d{$commit}{n} $d{$commit}{nif}\n");
	##		print(( ($d{$commit}{p} - $d{$commit}{n}))."\n");
	#
	#		if ( ($d{$commit}{n} - $d{$commit}{p}) == 1  #Check for 1 line difference
	#			&& $d{$commit}{pif} ne $d{$commit}{nif}  ) { #check if both if statement are different
	##			print("pushed $d{$commit}{p}\n");com
	#			my $pline = $d{$commit}{p};
	#			my $nline = $d{$commit}{n};
	#
	#			push (@{$bad_author {$d{$commit}{pauthor}}}, "$pline:$nline (Updated if statement constraints)\nCommit:$commit\nFile: $d{$commit}{file}\nLineNo:$d{$commit}{lineNo}\nnif:$d{$commit}{nif}\npif:$d{$commit}{pif}");
	##				PrevCommit:$d{$commit}{prevCommit}\n
	#		}
	#	}
}



my $nextCommit;
my $filename;

my $index=1;
my $count=1;

foreach my $k (keys (%bad_author)) {
	printf "%-80s %-0s \n", $k, "| " .  scalar (@{$bad_author {$k}});
#	print "$k |" . scalar (@{$bad_author {$k}}) . "\n";
	foreach my $lines (@{$bad_author {$k}}) {
#		print "$lines\n";
		if($lines =~ m/(.*)\nCommit:([\w]{40})\nFile: ([\w\/.\-\_]*)\nLineNo:([\w]*)\noriginalCommit:([\w]{40})\noriginalLine:([\w]*)\nnif:(.*)\npif:(.*)/){
			#All variable assignments
		
			my $line = $1;
			my $curCommit=$2;
			my $filePath=$3;
			my $lineNumber = $4;
			my $oCommit = $5;
			my $oLine = $6;
			my $nif = $7;
			my $pif = $8;
			
			#Now I have the Current Commit
			#Need to get the next commit

			#Getting the file name
			if($filePath =~ m/([\w.\-\_]*)$/){
					$filename = $1;
			}

			#Getting the next commit
			my $output = `git log -n 2 $curCommit | grep commit`;
			if($output =~ m/commit [\w]{40}\ncommit ([\w]{40})/){
				$nextCommit = $1;
			}else{
				print("No next Commit");
			}
			
			#All the print out here
			print("Entries: ".$count++." of ".scalar @{$bad_author {$k}}."\n"); #Print the count out of number of entries
			print("Filepath: $filePath\n");
			print("Line originally added: $oCommit ($oLine)\n");
			print("Added and replace: $line\n");
			print("CurCommit: $curCommit\nnextCommit: $nextCommit\n");
			print("Line Number: $lineNumber\n");
			print("nif:$nif\npif:$pif\n");
			print("\n\n");

			#All the commands here!
			#		#Checkout current file then copy outside 
			#		system("mkdir -p ../output2/$filename$index");print("\n");
			#		#Apply git diff from current and next to get the patch
			#		system("git diff --no-prefix $curCommit $nextCommit $filePath > ../output2/".$filename.$index."/".$filename."diff"); print("\n");
			#		system("git checkout $curCommit $filePath");print("\n");
			#		system("cp $filePath ../output2/$filename$index/".$filename."Curr.c");print("\n");
			#		system("echo '$lines' > ../output2/$filename$index/log.txt"); print("\n");

			#		system("git checkout $nextCommit $filePath");print("\n");
			#		system("cp $filePath ../output2/$filename$index/".$filename."Next.c");print("\n");
#			#		system("");
			#		$index++;
		}
	}
	$count=1;
	print("\n\n");
}

