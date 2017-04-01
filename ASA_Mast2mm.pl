
# CG - 8 May 2011, Script to generate MindMaps for ASA PIX Firewall Config File - Master MM
# Command Line Param - Config File Name; Output to Console

use Text::ParseWords;

open (CFG, $ARGV[0]) or die("File not found or No input file provided : [$ARGV[0]]!\n");

# Access Lists

my %MasterHash=();
my @SericeObjects=();
my @NetObjects=();
my @SingleObj=();
my $tmp='';

$Objects=0;

while (<CFG>) {
    $CurrLine = $_;
	chomp($CurrLine);
	$CurrLine =~ s/^\s*(.*\S)\s*$/$1/;
 	@token = quotewords('\s+',0,$CurrLine);
	if ($token[0] eq 'object-group') {
		$Objects++;
		$MasterHash{"$token[2]"} = 0 unless exists $MasterHash{"$token[2]"} 
		}
}	

while (($Obj, $Cnt) = each %MasterHash)
{
	seek(CFG,0,SEEK_SET);
	while (<CFG>) {
    $CurrLine = $_;
	chomp($CurrLine);
	$CurrLine =~ s/^\s*(.*\S)\s*$/$1/; 	$CurrLine = $CurrLine." ";
 	@token = quotewords('\s+',0,$CurrLine);
	if (($token[0] eq 'access-list') && ($token[2] ne 'remark')){
		if($CurrLine =~ /\s$Obj\s/) { $MasterHash{$Obj} = ++$Cnt; }
		}
	}

}	



print "<map version=\"0.8.1\">\n";
print "<node TEXT=\"Object Usage\">\n";

$Cntr=0;

while (($Obj, $Cnt) = each %MasterHash)
{
 if ($Cnt==0) { print "\t<node COLOR=\"#ff3333\" ID=\"$Obj\" STYLE=\"fork\" TEXT=\"$Obj\"></node>\n";  } 
 else { print "\t<node ID=\"$Obj\" STYLE=\"fork\" TEXT=\"$Obj [$Cnt]\"></node>\n";  } 
}


print "</node>\n"; # Closure of Core Node
print "</map>\n";  # Closure of Map 

close (CFG);

# Chetan Ganatra 