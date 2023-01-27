#!/usr/bin/perl -w
use strict;
use POSIX;

############################################################
### Arguments
#
my %arguments=
(
"--file"=>"na",         # name of the input file
"--days"=>7,         # max time
"--minFC"=>2,          # min time
"--minP"=>0.05,
"--nInt"=>4,
"--minG"=>10,
"--pass"=>"T",
#
"--outfile"=>"na"
);
#
#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
##



my $dataFile=$arguments{"--file"};
my $days=$arguments{"--days"};
my $minFC=$arguments{"--minFC"};
my $minP=$arguments{"--minP"};
my $nInt=$arguments{"--nInt"};
my $minNumGenomes=$arguments{"--minG"};
my $pass=$arguments{"--pass"};

my $outfile=$arguments{"--outfile"};
if ($outfile eq "na")
{
	$outfile="$dataFile.prev";
}

#
my %stored=();
my %totals=();
my %decode=();
#


open(IN,$dataFile);
my $header=<IN>;
my @fields=(split(/\t/,$header));
my $fields=@fields;
unless ($fields==11 || $fields==12)
{
	die("\n The input is not in the expected format: I got $fields columns,\n but I expect 10 (HaploCoV formatted file) or 11(HaploCoV formatted file+assign.pl).\n\n Please provide a valid file.\n\n");
}
unless ($fields[9] eq "pangoLin")
{
	die("\n Your 10th column is called $fields[9], but the name should be pangoLin. Is the file in HaploCoV format?\n\n Please check.\n\n");
}

while(<IN>)
{
	my ($genome,$date1,$days1,$date2,$days2,$continent,$area,$country,$region,$lineage,$string)=(split(/\t/));
	my ($yy,$mm,$dd)=(split(/-/,$date1));
	next unless $dd;
	next if $date1 eq "NA";	
	next if $yy<2019;
	
	my $iv=ceil($days1/$days);
	$decode{$iv}=$date1 unless $decode{$iv};

	next if $lineage eq "";
	next if $lineage eq "Unassigned";	

	$region="$area\:\:$country\:\:$region";
	$country="$area\:\:$country";


	$stored{$iv}{$lineage}{$area}++ if $area ne "NA" && $area ne "";
	$stored{$iv}{$lineage}{$country}++ if $country ne "NA" && $country ne "";
	$stored{$iv}{$lineage}{$region}++ if $region ne "NA" && $region ne "";

	#increase totals
	$totals{$iv}{$area}++ if $area ne "NA" && $area ne "";
        $totals{$iv}{$country}++ if $country ne "NA" && $country ne "";
        $totals{$iv}{$region}++ if $region ne "NA" && $region ne "";

}

open(OUT,">$outfile");
foreach my $interval (sort {$a<=>$b} keys %stored)
{
	my @compare=();
	my $compareS="#Interval:";
	my $isViable=1;
	for (my $c=0;$c<$nInt;$c++)
	{
		my $ivP=$interval+$c;
		unless ($stored{$ivP} && $totals{$ivP})
		{
			$isViable=0;
			last;
		}
		push(@compare,$ivP);
		$compareS.=" $decode{$ivP}";
	}
	next unless $isViable;
	print OUT "$compareS\n";
	print OUT "#lineage region";
	for (my $c=0;$c<$nInt;$c++)
	{
		print OUT " I$c:prev"
	}
	for (my $c=0;$c<$nInt;$c++)
	{
		print OUT " I$c:totG"
	}
	print OUT "PASS\n";

	foreach my $lineage (sort keys %{$stored{$interval}})
	{
		foreach my $level (sort keys %{$stored{$interval}{$lineage}})
		{
			#print "$level $lineage, $stored{$interval}{$lineage}{$level}\n";
			next if $stored{$interval}{$lineage}{$level}<=$minNumGenomes;
			my @counts=();
			my @prevalence=();
			my @totals=();
			foreach my $ivP (@compare)
			{
				#print "$ivP\n";
				my $tot=$totals{$ivP}{$level} ? $totals{$ivP}{$level} : 0;
				my $totL=$stored{$ivP}{$lineage}{$level} ? $stored{$ivP}{$lineage}{$level} : 0;
				my $prev= $tot==0 ? "NA" : $totL/$tot;
				push(@prevalence,$prev);
				push(@counts,$totL);
				push(@totals,$tot);
			}
			my $doI=toPrint(\@prevalence,\@counts);
			if ($pass eq "T")
			{
				print OUT "$lineage $level @prevalence @totals $doI\n" if $doI==1;
			}else{
				print OUT "$lineage $level @prevalence @totals $doI\n";
			}
		}
		
	}
	print OUT "#end of interval\n\n";
}


sub toPrint
{
	my @prevs=@{$_[0]};
	my @counts=@{$_[1]};
	my $doI=1;
	
	if ($prevs[-1] eq "NA"){
		$doI=0;
                return($doI);
	}elsif($prevs[-1]<$minP){
		$doI=0;
		return($doI);
	}
	
	foreach my $c (@counts)
	{
		if ($c <=$minNumGenomes)
		{
			$doI=0;
			return($doI);
		}
	}
	#for (my $i=0;$i<$#prevs;$i++)
	#{
	my $ratio=$prevs[-1]/$prevs[0];
	if ($ratio<$minFC)
	{
		$doI=0;
		return($doI);
	}
	#}	
	return ($doI);
}


######################################################################
## Functions for input control and help
##

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
			die("Reason:\nInvalid parameter $act provided\n");
                }
        }
}

sub check_input_arg_valid
{
        if ($arguments{"--file"} eq "na" ||  (! -e ($arguments{"--file"})))
        {
                print_help();
                my $f=$arguments{"--file"};
                die("Reason:\nNo valid input file provided: $f. Please provide a valid file!");
        }
        if ($arguments{"--days"}<0)
        {
                print_help();
                my $m=$arguments{"--days"};
                die("Reason:\nNumber of days needs to be >0. $m provided\n");
        }
        if ($arguments{"--minP"}<0)
        {
                print_help();
                my $m=$arguments{"--minP"};
                die("Reason:\nMininimum prevalence can not be <0. $m provided\n");
        }
        if ($arguments{"--minFC"}<0)
        {
                print_help();
                my $m=$arguments{"--minFC"};
                die("Reason:\nMinimum FC can not be <0. $m provided\n");
        }
        if ($arguments{"--minG"}<0)
        {
                print_help();
                my $m=$arguments{"--minG"};
                die("Reason:\nMinimum number of genomes can not be <0. $m provided\n");
        }
	if ($arguments{"--nInt"}<0)
        {
                print_help();
                my $m=$arguments{"--nInt"};
                die("Reason:\nNumber of intervals can not be <0. $m provided\n");
        }
	if ($arguments{"--pass"} ne "T" && $arguments{"--pass"} ne "F"){
		print_help();
		my $m=$arguments{"--pass"};
		die("Reason:\nPASS needs to be either T or F.  $m provided\n");
	}

	
}


sub print_help
{
        print " This utility is meant to:\n";
        print " 1) read a metadata table oin HaploCoV format;\n";
        print " 2) compute the prevalence of SARS-CoV-2 variants at different locales\n";
        print " (i.e. country, regions or macorAreas), and generate a detailed report\n";
	print " with the list of SARS-CoV-2 variants that have increased their prevalence.\n\n";
        print " The final output will consist in a large file, with the complete list of lineages\n";
        print " or variants that have increased their prevalence during any time-interval included\n";
        print " in the file by a factor greater or equal than --minFC.\n";
        print " The main input is the medata-table in HaploCoV format \n";
        print " --file is the only mandatory parameter. Optional parameters include:\n\n";
        print " 1) the size, in days of time units used for computing the prevalence (--days). Defaults to 7;\n";
        print " 2) the minimum level of increase in prevalence to report (--minFC);\n";
        print " 3) a prevalence threshold, value below the threshold will not be reported (--minP)\n";
       	print " 4) the number of time units to include in the analysis (--nInt)\n";
	print " 5) the minimum number of genome sequence assigned to a lineage, for considering it in the analysis\n";
	print " this is used in conjuction with --minP, to filter out estimates supported only by a limited\n";
	print " number of genomes/data (--minG)";
	print " 6) a logical value (T=true, F=FALSE) to specify whether the report should include only lineages that\n";
	print " passed the user-defined thresholds, or all the lineages included in the file\n";
        print " 7) a name for the output file where the output files will be stored\n\n";
        print " The report produced by this tool be used to detect novel variants of SARS-CoV-2 that are increasing their\n";
        print " prevalence in time, at different levels of geographic granularity\"\n\n";
        print "##INPUT PARAMETERS\n\n";
        print "--file <<filename>>\t provides the HaploCoV formatted file\n";
        print "--days <<integer>>\t size of time units used to estimate the prevalence, in days. Defaults to 7:\n";
        print "--minFC <<integer>>\t minimum fold of increase in prevalence. Defaults to 2: 2fold increase;)\n";
        print "--nInt <<integer>>\t number of consecutive time units used to form and interval. Defaults to 4;\n";
        print "--minP <<integer>>\t minimum level of prevalence. Defaults to 0.05;\n";
	print "--minG <<integer>>\t minimum number of genomes (only lineages associated with --minG or more are reported). Defaults to 10;\n";
        print "--pass <<logical>>\t defaults to T (true),include only variants that fulfilled all the criteria specified by\n";
       	print "                  \t--minFc, --minP and --minG in the report, if set to F (false) all variants will be reported instead;\n";
	print "--outfile <<filname>>\t output file. Defaults to <<infile>>.prev\n";
        print "\nTo run the program you MUST provide at least --file\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is metadata.tsv:\nperl increase.pl --file metadata.tsv\n";
	print "2# output will be saved in metadata.tsv.prev\n";
}


