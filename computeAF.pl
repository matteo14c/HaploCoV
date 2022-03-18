use strict;

############################################################
### Arguments
#
my %arguments=
(
"--file"=>"na",         # name of the input file
"--maxT"=>750,      	# max time
"--minT"=>-10, 		# min time
"--interval"=>10,
"--minCoF"=>1,
"--minP"=>3,
"--alndir"=>"./snps",
"--outdir"=>"./metadata"
);
#
#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
##


my $file=$arguments{"--file"};
my $alndir=$arguments{"--alndir"};
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
my %data=%{metadataToLists($file,$alndir)};
my ($alleles,$total)=build_list_alleles($alndir);
my @LofP=keys %$alleles; 
process_data(\%data,$max_time,$min_time,$increment,$minAF,$minP,$alndir,$outdir);

#########################################################
# subs


sub process_data
{
	my %data=%{$_[0]};
	my $max_time=$_[1];
	my $min_time=$_[2];
	my $interval=$_[3];
	my $increment=$_[4];
	my $minCoff=$_[5];
	my $freqCoff=$_[6];
	my $alndir=$_[7];
	my $outdir=$_[8];
	my @Ws=();
	my %final_data=();
	my %freqPos=();	
	for(my $t=$min_time;$t<=$max_time;$t+=$increment)
	{
		my $w_start=$t;
		my $w_end=$t+$interval;
		my %genomes=();
		for(;$w_start<=$w_end;$w_start++)
		{
			push(@Ws,"$w_start\_$w_end");
			if ($data{$w_start})
			{
				foreach my $spec (keys %{$data{$w_start}})
				{
					foreach my $level (keys %{$data{$w_start}{$spec}})
					{
						my @LocalLG=@{$data{$w_start}{$spec}{$level}};
	                               		push(@{$genomes{$spec}{$level}},@LocalLG);
#
					}
				}
			}
		}
		foreach my $spec (keys %genomes)
		{
			foreach my $level (keys %{$genomes{$spec}})
			{
				my @genomes=@{$genomes{$level}{$spec}};
				my $M=@genomes;
				my %variants=%{genomes_To_variants(\@genomes)};
				foreach my $pos (@LofP)
				{
					my $value= $variants{$pos} ? $variants{$pos}/$M*100 : 0;
					push (@{$final_data{$pos}{$spec}{$level}},$value);
				}
			}
		}

	}
	foreach my $pos (@LofP)
	{
		foreach my $spec (keys %{$final_data{$pos}})
		{
			foreach my $level (keys %{$final_data{$pos}{$spec}})
			{
				open(OUT,">$outdir/$level\_AFOT.txt");
				print OUT " @Ws\n";
				my @data=@{$final_data{$pos}{$spec}{$level}};
				my $sum=0;
				my $zeros=0;
				foreach my $d (@data)
               			{
                       			$sum++ if $d>=$minCoff;
                       			$zeros++ if $d>0;
               			}
				if ($sum>=$freqCoff)
               			{
                       			push(@{$freqPos{$spec}{$pos}},$level);
               			}
               			print OUT "$pos @data\n" if $zeros>0;
			}
		}
	}
	foreach my $spec (keys %freqPos)
	{
		
		open(OUT,">$outdir/$spec\_list.txt");
		foreach my $pos (keys %{$freqPos{$spec}})
		{
			my @list=@{$freqPos{$spec}{$pos}};
			my $lstring=join(",",@list);
			print OUT "$pos\t$lstring\n";
		}

	}

}

sub genomes_To_variants
{
	my @Lg=@{$_[0]};
	my %dat_final=();
	foreach my $g (@Lg)
	{
		open(IN,$g);
		warn("can't read $g\n") unless -e $g;
        	while(<IN>)
        	{
			chomp();
			$dat_final{$_}++;
        	}
	}
	return \%dat_final;
}


sub metadataToPos
{
	my $keepFile="metaDkeep";
	open(ON,$keepFile);
	my %lock=();
	while(<ON>)
	{
		chomp();
		$lock{$_}=1;	
	}
	return \%lock;
}

sub areas
{
	my $areaFile="areaFile";
	open(AR,$areaFile);
	my %areas=();
	while(<AR>)
	{
		chomp();
		my ($country,$area)=(split(/\t/));
		$areas{$country}=$area;
	}
	return(\%areas);
}

sub metadataToLists
{
	my $metadataFile=$_[0];
	my $alndir=$_[1];
	open(IN,$metadataFile);
	my $header=<IN>;
	my @vl=(split(/\t/,$header));
	my %keep=();
	my %lock=%{metadataToPos()};
	my %areas=%{areas()};
	my %data=();
	for (my $i=0;$i<=$#vl;$i++)
	{
		my $v=$vl[$i];
		$lock{$v}=$i if ($lock{$v});
	}
	my $Iv=$lock{"Virus name"};
	my $Ir=$lock{"Location"};	
	my $Id=$lock{"Collection date"};
	my $Ip=$lock{"Pango lineage"};
	#print "$Iv $Id $Ir $Ip\n";
	#open(OUT,">tmpTable.csv");
	#print OUT "name\tdate\tpango\tcontinent\tarea\tcountry\tregion\tdays\n";
	while (<IN>)
	{
		chomp();
		my @data=(split(/\t/));
		my $id=$data[$Iv];
		my $d=$data[$Id];
		my $p=$data[$Ip];
		my $location=$data[$Ir];
		my ($continent,$country,$region)=(split(/\//,$location));
        	$country=~s/\s+//g;
		my $area=$areas{$country} ? $areas{$country} : "na";
		$continent=~s/\s+//g;
		$region=~s/\s+//g;
		$id=fix_strain($id);
		$d=fix_date($d);
		my $delta=diff_d($d);
		$max_time=$delta if $delta>$max_time;
		my $genome="./$alndir/$id\_form.txt";
		print OUT "$id\t$d\t$p\t$continent\t$area\t$country\t$region\t$delta\n";
		push(@{$data{$delta}{"global"}{"ALL"}},$genome);
		push(@{$data{$delta}{"areas"}{$area}},$genome);
		push(@{$data{$delta}{"countries"}{"$country"}},$genome)
	}
	return(\%data);
}

sub fix_strain
{
        my $strain=$_[0];
        $strain=~s/hCoV-19\///;
        $strain=~s/\//\_/g;
        $strain=~s/\s+//g;
        $strain=~s/Lu\`an/Luan/g;
        $strain=~s/Lu\'an/Luan/g;
        $strain=~s/\$//g;
        $strain=~s/\(//g;
        $strain=~s/\)//g;
        $strain=~s/\'//g;
        return($strain);
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


sub build_list_alleles
{
	my $dir=$_[0];
	my @files=<./$dir/*_form.txt>;
	my $total=0;
	my %data=();
	foreach my $f (@files)
	{
        	$total++;
        	open(IN,$f);
        	while(<IN>)
        	{
                	chomp;
                	$data{$_}++;
        	}
	}
	return(\%data,$total)
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
	unless (-e $arguments{"--alndir"})
	{
		print_help();
		my $m=$arguments{"--alndir"};
		die("$m does not exist\nPlease provide a valid input directory\n")
	}

}

sub print_help
{
        print " This utility is meant to 1) read a metadata table file; 2) read allele variant files from\n"; 
	print " a user specified folder and 3) compute allele global frequencies over time, and allele frequencies\n ";
        print " over time in macroAreas and countries.\n";    
	print " The final outputs will consist in a list of high frequency allele variants at differnt geographic\n";
	print " granularity (global,country, and  macroAreas)\n";
        print " Users need to provide as the main input the medata table, and a folder where allele variants files\n"; 
	print " (in SNP.txt format) are stored\n";
	print " These are the only mandatory parameters. Optional parameters can also be specified including:\n";
	print " minimum allele frequency threshold, and allele persistence threshold (see below): the beginning and end\n";
	print " of the time interval to analyse\n";
	print " and the \"size\" in days of overlapping time-windows which are computed within the main interval\n";
	print " all the output files will be written in a user specified output directory (see --outdir). Outputs will\n"; 
	print " include a complete table with iallele frequencies, for every country and macroarea as well as\n";
	print " 3 special files with the list of high frequency alleles (as defined by users specification)\n";
	print " These files are used by augment.pl to identify novel variants of SARS-CoV-2 within an existing nomenclature\n";  
	print "##INPUT PARAMETERS\n\n";
        print "--file <<filename>>\t provides the metadata file\n";
        print "--maxT <<integer>>\t defaults to 750 upper bound of time interval\n";
        print "--minT <<integer>>\t defaults to -10 lower bount od the time interval\n";
	print "--interval <<integer>>\t defaults to 10, size in days of overlapping time windows\n";
	print "--minCoF <<float>>\t defaults to 0.01, minimum AF for high frequency alleles \n";
	print "--minP <<integer>>\t defaults to 3, minimum persistence (number of intervals) for high freq alleles\n";
	print "--alndir <<dirname>>\t defaults to \"./snps\", directory where allele variant files are stored\n";
	print "--outdir <<dirname>>\t defaults to \"./metadata\", output directory\n";
        print "\nTo run the program you MUST provide at least --file\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is metadata.tsv:\nperl compute.pl --file metadata.tsv\n\n";
}
