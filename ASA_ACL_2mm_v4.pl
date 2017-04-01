
# CG - 8 May 2011, Script to generate MindMaps for ASA PIX Firewall Config File - ACL
# Command Line Param - Config File Name; Output to Console
# v3 introduces ZoneToo => acl name !

use Text::ParseWords;
use Switch;

open (CFG, $ARGV[0]) or die("File not found or No input file provided : [$ARGV[0]]!\n");

# Access Lists

my @MasterTable=();
my @SingleRule=();
my @UniqNodes = ();
my @AllFromTo = ();

my $tmp='';

while (<CFG>) {
    $CurrLine = $_;
	$List = $Access = $Proto = $From = $To = $PortAct = '';
	@SingleRule=();
	chomp($CurrLine);
	$CurrLine =~ s/^\s*(.*\S)\s*$/$1/;
 	@token = quotewords('\s+',0,$CurrLine);
	if (($token[0] eq 'access-list') && ($token[2] ne 'remark')){
		$List=$token[1];
		$Access=$token[3];
		$Proto=$token[4];
		switch ($token[5])
		{
		case "any" 	{$From = "ANY";		$ToProcess=6; }
		case "host" {$From = $token[6];	$ToProcess=7; }
		case "object-group" {$From = $token[6];		$ToProcess=7; }
		else {$From = $token[5].":".$token[6];	$ToProcess=7; }
		}
		switch($token[$ToProcess])
		{
		case "any" {$To = "ANY"; $ToProcess++;}
		case "host" {$To = $token[$ToProcess+1]; $ToProcess+=2;}
		case "object-group" {$To = $token[$ToProcess+1]; $ToProcess+=2;}
		else {$To = $token[$ToProcess].":".$token[$ToProcess+1]}
		}
		switch($token[$ToProcess])
		{
		case "eq" {$PortAct = $token[$ToProcess+1]; $ToProcess++;}
		case "range" {$PortAct = $token[$ToProcess+1].":".$token[$ToProcess+2]; $ToProcess+=2;}
		case "object-group" {$PortAct = $token[$ToProcess+1]; $ToProcess+=2;}
		else {$PortAct = $token[$ToProcess];}
		}
		$RuleEntry=$List."~".$Access."~".$Proto."~".$From."~".$To."~".$PortAct;
		push(@MasterTable,$RuleEntry);
	}	
}

@MasterTable=sort(@MasterTable);

print "<map version=\"0.8.1\">\n";
print "<node TEXT=\"Access Controls\">\n";

# Get UniqNodes Out
# %seen = (); foreach $item (@AllFromTo) { push(@UniqNodes, $item) unless $seen{$item}++; }
$Cntr=1;
my $CurrACL = $CurrFrom = '';
foreach my $temp (@MasterTable)
{
my ($List,$Access,$Proto,$From,$To,$PortAct) = split "~",$temp;
	if ($List ne $CurrACL)
		{
			if ($CurrACL ne '') { print "\t\t</node>\n\t</node>\n"; }
			$CurrACL=$List;
			$CurrFrom='';	
			if($Cntr==1)
			{
			$Cntr=0;
			print "\t<node ID=\"$CurrACL\" TEXT=\"$CurrACL\" POSITION=\"right\">\n"; 
			}
			else
			{
			$Cntr=1;
			print "\t<node ID=\"$CurrACL\" TEXT=\"$CurrACL\" POSITION=\"left\">\n"; 
			}
		}	
	if ($From ne $CurrFrom)
		{
			if ($CurrFrom ne '') { print "\t\t</node>\n"; } 
			$CurrFrom=$From;
			print "\t\t<node ID=\"$From\" TEXT=\"$From\">\n"; 
		}
	if (($Access eq 'deny') || ($From eq 'any') || ($To eq 'any') || ($PortAct =~ /telnet|www/))
		{ print "\t\t\t<arrowlink COLOR=\"#ff3333\" DESTINATION=\"$To\" ID=\"Link_$From_$To\" ENDARROW=\"Default\" STARTARROW=\"None\"/>\n"; }
	else { print "\t\t\t<arrowlink DESTINATION=\"$To\" ID=\"Link_$From_$To\" ENDARROW=\"Default\" STARTARROW=\"None\"/>\n"; 
		}
#print "DEBUG:$List,$Access,$Proto,$From,$To\n";
}	

	
print "</node></node>\n";

print "</node>\n"; # Closure of Core Node
print "</map>\n";  # Closure of Map 

close(CFG);




# -----------------------------------------------

=for 

$Cnt=1;
foreach my $ii (@MasterTable) 
{ 
print "$ii "; 
if($Cnt++ > 5) {$Cnt=1;print "\n";}
};

exit;


# print "$List,$Access,$Proto,$From,$To\n";

for $Rule ( 0 .. $#MasterTable ) {
        print " $MasterTable[$Rule] $MasterTable[$Rule++] $MasterTable[$Rule++] $MasterTable[$Rule++]\n";
	}


$Cntr=0;

while (($Obj, $Cnt) = each %MasterHash)
{
 if ($Cnt==0) { print "\t<node COLOR=\"#ff3333\" ID=\"$Obj\" STYLE=\"fork\" TEXT=\"$Obj\"></node>\n";  } 
 else { print "\t<node ID=\"$Obj\" STYLE=\"fork\" TEXT=\"$Obj [$Cnt]\"></node>\n";  } 
}

=cut

# Chetan Ganatra 