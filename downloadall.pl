#read file from text

my @array=undef;
#my $filename = 'a.txt';
my $filename = 'allCfile';
open(my $file, '<:encoding(UTF-8)', $filename) 
	or die "could not open file '$filename' $!";

#Concatate the the whole file
my $myFile = undef;
my $newFile = undef;

while (my $line = <$file>) {
	chomp $line;
	
	if($line =~ m/([\w]+[\.c]+$)/){
		#print $1."\n";
		$newFile = $1;
	}

	system("git log -p --cherry $line > output/$newFile.txt\n");
	print("git log -p --cherry $line > output/$newFile.txt\n");
	}

#execute system command

#output to md5.txt 


