use strict;

############################################################
### Arguments
#
my %arguments=
(
"--infile"=>"na",      # name of the input file
"--area"=>"na",      	  
"--country"=>"na",
"--region"=>"na",
"--startD"=>"na",
"--endD"=>"na",
"--lineage"=>"na",
"--outfile"=>"na" 	# outfile
);
#

#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();



my $infile=$arguments{"--infile"};
my $area=$arguments{"--area"};
my $country=$arguments{"--country"};
my $region=$arguments{"--region"};
my $startD=$arguments{"--startD"};
my $endD=$arguments{"--endD"};
my $oS=$startD;
my $oE=$endD;
my $nextNAdate=0;

if ($startD ne "na")
{
	$startD=fix_date($startD);
	$startD=diff_d($startD);
	$nextNAdate=1;
}
if ($endD ne "na")
{
	$endD=fix_date($endD);
	$endD=diff_d($endD);
	$nextNAdate=1;
}
my $lineage=$arguments{"--lineage"};
my $outfile=$arguments{"--outfile"};


die("Could not convert $startD\n") if $startD eq "NA";
die("Could not convert $endD\n") if $endD eq "NA";
die ("$oS>$oE please provide a valid start and end date\n") if ($startD > $endD && $startD ne "na" && $endD ne "na"); 


subset($infile,$area,$country,$region,$startD,$endD,$lineage,$outfile);

sub subset
{
	my $infile=$_[0];
	my $area=$_[1];
	my $country=$_[2];
	my $region=$_[3];
	my $startD=$_[4];
	my $endD=$_[5];
	
	my $lineage=$_[6];
	my $outfile=$_[7];
	open(IN,$infile);
	open(OUT,">$outfile");
	while(<IN>)
	{
		my ($id,$date,$offset,$depo,$odepo,$continent,$farea,$fcountry,$fregion,$flineage,$mut)=(split(/\t/,$_));
		next if $odepo-$offset>=60;
		#print if $lineage eq $flineage;
		next if $area ne "na" && $area ne $farea;
		next if $country ne "na" && $country ne $fcountry;
		next if $lineage ne "na" && $lineage ne $flineage;
		next if $region ne "na" && $fregion ne $region;
		next if $offset>$endD  && $endD ne "na"; 
		next if $offset<$startD && $startD ne "na";
		next if $nextNAdate=1 && $date eq "NA";
		print OUT;
	}
}

sub fix_date
{
	my $date=$_[0];
	my @vl=(split(/\-/,$date));
	if ($#vl!=2)
	{
		$date="NA";
	}
	return($date);
}

sub diff_d
{
	my $diff="NA";
	my $date=$_[0];
        my @vl=(split(/\-/,$date));
	if ($date eq "NA")
	{
		return($diff);
	}else{
		$diff=0;
		my $diffY=($vl[0]-2019)*365;
		my $diffM=(int($vl[1]-12)*30.42);
		my $diffD=$vl[2]-30;
		$diff=$diffY+$diffM+$diffD;
		return(int($diff));
	}
}

sub check_arguments
{
	my @arguments=@ARGV;
        for (my $i=0;$i<=$#ARGV;$i+=2)
        {
                my $act=$ARGV[$i];
                my $val=$ARGV[$i+1];
                if (exists $arguments{$act})
                {
                        $arguments{$act}=$val;
                }else{
                        warn("$act: unknown argument\n");
                        my @valid=keys %arguments;
                        warn("Valid arguments are @valid\n");
                        warn("All those moments will be lost in time, like tears in rain.\n Time to die!\n");
                        print_help();
                }
        }
}

sub check_input_arg_valid
{
        if ($arguments{"--infile"} eq "na" ||  (! -e ($arguments{"--infile"})))
        {
                print_help();
                my $f=$arguments{"--infile"};
                die("No valid input file provided. $f does not exist!");
        }
}

sub print_help
{
        print " This utility is meant to subset a metadata file in HaploCoV format\n"; 
	print " different conditions and filters can be applied\n";
	print " Logical AND of the filters set by the user is always applied\n";
	print " in the subset/filtration of the input data. i.e if both a region and \n";
	print " lineage are provided (--region and --lineage) only metadata of genomic \n";
	print " sequneces from that region and assigned to that lineage will be extracted\n";
	print " The final output will consist in a metadata table in HaploCov format\n";
	print " with only the subset of the data specified by the user\n\n";

	

	print "##INPUT PARAMETERS\n\n";
        print "--infile <<filename>>\t metadata file\n";
        print "--area <<filter>>\t name of a macro geographic area\n";
        print "--country <filter>>\t name of a country\n";
        print "--region <filter>>\t name of a region\n";
        print "--lineage <filter>>\t name of a lineage. Name must match extactly\n";
	print "--startD <<date: YYYY-MM-DD>>\t extract only genomes collected after this date\n";
	print "--endD <<date: YYYY-MM-DD>>\t extract only genomes collected before this date\n";
        print "Mandatory parameters are --infile and --outfile, at least one of  --area,--country,--filter\n";
        print "--lineage,--startD or --endD should be set. If no filters are specified, execution will halt\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is HaploCoV_formattedMetadata:\nperl subset.pl --infile HaploCoV_formattedMetadata --country Thailand"; 
        print "--startD 2022-05-01 --outfile Thai_HaploCoV_formattedMetadata\n\n";
}




