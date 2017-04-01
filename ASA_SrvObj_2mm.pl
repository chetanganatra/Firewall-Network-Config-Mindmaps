
# CG - 8 May 2011, Script to generate MindMaps for ASA PIX Firewall Config File - Service Objects
# Command Line Param - Config File Name; Output to Console

use Text::ParseWords;

open (CFG, $ARGV[0]) or die("File not found or No input file provided : [$ARGV[0]]!\n");

# Access Lists
my @ACL=();
my @SrvObj=();
my $SrvObjects=0;
my $TotalSrvObjects=0;
my @SingleObj=();
my $tmp='';

$Position=0;

while (<CFG>) {
    $CurrLine = $_;
	chomp($CurrLine);
	$CurrLine =~ s/^\s*(.*\S)\s*$/$1/;
 	@token = quotewords('\s+',0,$CurrLine);
	if (($token[0] eq 'object-group') && ($token[1] eq 'service')){
		if(@SingleObj) { push(@SingleObj,"_END_SRVOBJ_"); splice(@SingleObj,1,0,$SrvObjects); push(@SrvObj,@SingleObj); }
		@SingleObj=();		
		$SrvObjects=0;		
		$TotalSrvObjects++;
		push(@SingleObj,"_START_SRVOBJ_:".$token[2]."_".$token[3]);
	};
	if ($token[0] eq 'port-object') {
		$SrvObjects++;
		if ($token[1] eq 'eq') { push(@SingleObj,$token[2]); }
		else { push(@SingleObj,$token[2].":".$token[3]); }
	};
	
}

if(@SingleObj) { push(@SingleObj,"_END_SRVOBJ_"); splice(@SingleObj,1,0,$SrvObjects); push(@SrvObj,@SingleObj); }

print "<map version=\"0.8.1\">\n";
print "<node TEXT=\"Service Objects [$TotalSrvObjects]\">\n";

$Cntr=0;
$ObjName='';
foreach my $tmp (@SrvObj)
{
if ($tmp eq "_END_SRVOBJ_") { print "</node>\n"; }
elsif (substr($tmp,0,14) eq "_START_SRVOBJ_") 
	{ 
	$Cntr=0; $ObjName = substr($tmp,15); 
	}
elsif ($Cntr==1)
	{
	if ($tmp eq 0) { print "<node COLOR=\"#ff3333\" ID=\"$ObjName\" STYLE=\"bubble\" TEXT=\"$ObjName\">\n"; }
		else { print "<node ID=\"$ObjName\" STYLE=\"bubble\" FOLDED=\"true\" TEXT=\"$ObjName [$tmp]\">\n";  }
	}
else 
	{ print "\t<node ID=\"$tmp\" STYLE=\"fork\" TEXT=\"$tmp\"/>\n"; 
	}
$Cntr++;
}

print "</node>\n";
print "</map>\n";




sub PrintNode{
# Node, Style, Position
$Str="<node ID=\"".$_[0]."\" TEXT=\"".$_[0]."\" ";
if ((@_ > 0) && ($_[1] ne "")) { $Str = $Str." STYLE=\"".$_[1]."\" "; }
if ((@_ > 1) && ($_[2])) { 
	if ($_[2] % 2) {
	$Str  = $Str." POSITION=\"left\""; 
	} else { $Str  = $Str." POSITION=\"right\""; }
	}
$Str = $Str."/>";
print "$Str\n";
}

close (CFG);

# Comments Below

=for 

 $i=0;
 foreach $item (@ACL)
 {  print "$i: $item\n"; $i++; } 
print "======================================\n";
 $i=0;
 foreach $item (@NetObj)
 {  print "$i: $item\n"; $i++; } 
print "======================================\n";
 $i=0;
 foreach $item (@SrvObj)
 {  print "$i: $item\n"; $i++; } 

 close (CFG);

=cut

# Chetan Ganatra 