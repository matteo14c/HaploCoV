use strict;

############################################################
### Arguments
#
my %arguments=
(
"--file"=>"na",         # name of the input file
"--maxT"=>900,      	# max time
"--minT"=>-10, 		# min time
"--interval"=>10,
"--minCoF"=>1,
"--minP"=>3,
"--outdir"=>"./metadataAF",
);
#
#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
##


my $file=$arguments{"--file"};
my $outdir=$arguments{"--outdir"};
my $max_time=$arguments{"--maxT"};
my $min_time=$arguments{"--minT"};
my $interval=$arguments{"--interval"};
my $minAF=$arguments{"--minCoF"};
my $minP=$arguments{"--minP"};
my $increment=$interval/2;

check_exists_command('mkdir') or die "$0 requires mkdir to create a temporary directory\n";
unless (-e $outdir)
{
        system("mkdir $outdir")==0||die ("can not create temporary directory $outdir\n");
}

###########################################################
# process the data

process_data($file,$max_time,$min_time,$interval,$increment,$minAF,$minP,$outdir);

#########################################################
# subs

sub buildlistPos
{
	my $c=0;
	my $infile=$_[0];
	open(IN,$infile);
	my %index=();
	my $maxL=0;
	while(<IN>)
	{
		my($d,$lvar)=(split(/\t/))[2,-1];
		if ($d ne "NA" && $d>$maxL)
		{
			$maxL=$d
		}
		my @vrs=(split(/\,/,$lvar));
		foreach my $v (@vrs)
		{
			$index{$v}++;
		}
		$c++;
		print "$c\n" if $c % 1000000==0;
	}
	my @vars= keys %index;
	return(\@vars,$maxL);
}


sub process_data
{

	my $file=$_[0];
	my $max_time=$_[1];
	my $min_time=$_[2];
	my $interval=$_[3];
	my $increment=$_[4];
	my $minCoff=$_[5];
	my $freqCoff=$_[6];
	my $outdir=$_[7];
	my @Ws=();
	my @zeros=();

	for(my $t=$min_time;$t<=$max_time;$t+=$increment)
        {
                my $w_start=$t;
                my $w_end=$t+$interval;
                push(@Ws,"$w_start\_$w_end");
		push(@zeros,0);
	}
	

	#print "@Ws\n";

	my %final_data=();
	my %freqPos=();	
	my $Tstart=$min_time;
	my $Tend=$Tstart+$interval;
	my $index=0;
	my %countInterval=();
	my $c=0;
	open(IN,$file);
	while(<IN>)
	{
		chomp();
		my($d,$area,$country,$lvar)=(split(/\t/))[2,6,7,-1];
                next if $d eq "NA";
		next if $d<$min_time;
		while ($d>=$Tend)
                {
			$Tstart+=$increment;
			$Tend+=$increment;
			$index++;
                }

		
		my $t0=$Tstart;
		my $t1=$Tend;
		my $local_i=$index;
		my @vrs=(split(/\,/,$lvar));
               	
	       	while($d>=$t0 && $d<$t1)
		{
			#print "$d $area $country $lvar $t0 $t1 $local_i\n";
	
			$countInterval{"global"}[$local_i]++;
                	$countInterval{$area}[$local_i]++;
                	$countInterval{$country}[$local_i]++;
		
			foreach my $v (@vrs)
                	{
                        	$final_data{"global"}{"global"}{$v}[$local_i]++;	
				$final_data{"areas"}{$area}{$v}[$local_i]++;
				$final_data{"countries"}{$country}{$v}[$local_i]++;
                	}
			$t0+=$increment;
			$t1+=$increment;
			$local_i++;
		}
                $c++;
		print "$c\n" if $c % 1000000==0;
	
	}
	foreach my $spec (keys %final_data)
	{
		foreach my $level (keys %{$final_data{$spec}})
		{
			next if $level eq "na";
			open(OUT,">$outdir/$level\_AFOT.txt");
			print OUT " @Ws\n";
			foreach my $pos (keys %{$final_data{$spec}{$level}} )
			{
				my @data= @{$final_data{$spec}{$level}{$pos}};
				my @odata=();
				my $sum=0;
				for (my $i=0;$i<=$#Ws;$i++) 
               			{
					unless($data[$i])
					{
						push(@odata,0);
					}else{
						my $val=$data[$i]/$countInterval{$level}[$i]*100;
						push(@odata,$val);
						$sum++ if $val>=$minCoff
					}
               			}
				if ($sum>=$freqCoff)
               			{
                       			push(@{$freqPos{$spec}{$pos}},$level);
               			}
               			print OUT "$pos @odata\n";
			}
		}
	}	
	foreach my $spec (keys %freqPos)
	{
		
		open(OUT,">$spec\_list.txt");
		foreach my $pos (keys %{$freqPos{$spec}})
		{
			my @list=@{$freqPos{$spec}{$pos}};
			my $lstring=join(",",@list);
			print OUT "$pos\t$lstring\n";
		}

	}

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
                }
        }
}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
}

sub check_input_arg_valid
{
        if ($arguments{"--file"} eq "na" ||  (! -e ($arguments{"--file"})))
        {
                print_help();
                my $f=$arguments{"--file"};
                die("No valid input file provided. $f does not exist!");
        }
	if ($arguments{"--maxT"}<0)
	{
		print_help();
		my $m=$arguments{"--maxT"};
		die("Max Time can not be <0. $m provided\n");
	}
	if ($arguments{"--interval"}<0)
        {
                print_help();
                my $m=$arguments{"--interval"};
                die("Interval can not be <0. $m provided\n");
        }
	if ($arguments{"--minCoF"}<0)
        {
                print_help();
                my $m=$arguments{"--minCoF"};
                die("Minimum AF can not be <0. $m provided\n");
        }
	if ($arguments{"--minP"}<0)
        {
                print_help();
                my $m=$arguments{"--minP"};
                die("Minimum persistence can not be <0. $m provided\n");
        }

}

sub print_help
{
        print " This utility is meant to:\n"; 
	print " 1) read a metadata table file produced addToTable.pl or an equivalent\n"; 
	print " user supplied file and;\n"; 
	print " 2) compute allele frequencies of SARS-CoV-2 genetic variants\n";  
	print " over time, globally in geographic macroAreas (see areas) and countries.\n\n"; 
	print " The final output will consist in a series of files with high frequency\n";
        print " allele variants at different geographic granularity (global, country,\n"; 
	print " and  macroAreas)\n";
        print " The main input is the medata-table produced by addToTable.pl and \n";
	print " --file is the only mandatory parameters. Optional parameters include:\n\n";
	print " 1) minimum allele frequency threshold;\n"; 
	print " 2) allele persistence threshold (see below);\n"; 
	print " 3) start and 4) of the time interval to include in the analysis\n";
	print " 5) the size of \"time\" windows at which allele frequencies are computed;\n";
	print " 6) a name for the folder where the output files will be stored\n\n";
	print " The tool will compute a table with allele frequencies over time\n";
	print " for every country and macroarea in the time-span specified by the user\n"; 
	print " (prefix AFOT_); and derive a comprehensive list of high frequency alleles\n";
        print " according to users specified criteria at global, area and country level\n";
	print " The latter can be used to identify candidate novel variants of SARS-CoV-2\n"; 
	print " within an existing nomenclature by using \"augment.pl\"\n\n";  
	print "##INPUT PARAMETERS\n\n";
        print "--file <<filename>>\t provides the metadata file\n";
        print "--maxT <<integer>>\t defaults to 900 upper bound of time interval\n";
        print "--minT <<integer>>\t defaults to -10 lower bount od the time interval\n";
	print "--interval <<integer>>\t defaults to 10, size in days of overlapping time windows\n";
	print "--minCoF <<float>>\t defaults to 0.01, minimum AF for high frequency alleles \n";
	print "--minP <<integer>>\t defaults to 3, minimum persistence (number of intervals) for high freq alleles\n";
	print "--outdir <<dirname>>\t defaults to \"./metadataAF\", output directory\n";
        print "\nTo run the program you MUST provide at least --file\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is metadata.tsv:\nperl compute_AF.pl --file metadata.tsv\n\n";
}
