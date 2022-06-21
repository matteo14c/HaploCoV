use strict;

my %arguments=
(
"--dfile"=>"na",
"--metafile"=>"linearDataSorted.txt",                  # directory with alignment files. Defaults to current dir
#####OUTPUT file#############################################
"--out"=>"ASSIGNEDScore_out.tsv" #file #OUTPUT #tabulare
);

check_arguments();


#######################################################################################
# read parameters
my $lvarFile=$arguments{"--dfile"};
my $metafile=$arguments{"--metafile"};
my $ofile=$arguments{"--out"};
print "$metafile\n";

check_input_arg_valid();

######################################################################################
# Populate score matrix
my ($initscores,$decode,$pos)=populate_matrix($lvarFile);

######################################################################################
# assign genomes
assign($initscores,$decode,$pos,$ofile);


#####################################################################################
# do read stuff
#
sub populate_matrix
{
	my @initscores=();
	my $lvarFile=$_[0];
	open(IN,$lvarFile);
	my @decode=();
	my %pos=();
	my $iclus=0;
	while(<IN>)
	{
		chomp();
        	my ($clus,@var)=(split());
        	#print "$clus\n";
        	my $sval=-@var;
        	foreach my $var (@var)
        	{
                	next if $var eq "none";
                	push(@{$pos{$var}},$iclus);
        	}
        	push(@initscores,$sval);
        	$decode[$iclus]=$clus;
        	$iclus++;
	}
	return(\@initscores,\@decode,\%pos);
#print "@initscores\n";

}

sub assign
{
	my @initscores=@{$_[0]};
	my @decode=@{$_[1]};
	my %pos=%{$_[2]};

	open(OUT,">$ofile");
	open(IN,$metafile);
	while(<IN>)
	{
		chomp();
        	my @scores=@initscores;
        	my @vls=(split(/\t/));
        	my $lvar=$vls[-1];
		#########################################################
        	# score variants seen in this genome
		my @vars=(split(/\,/,$lvar));
        	foreach my $v (@vars)
        	{
                	# if allele not defining anything, next
			next unless $pos{$v};
			#  find clusters defined by allele
			my @clusters=@{$pos{$v}};
			# add
			foreach my $cl (@clusters)
                	{
				#$scores[$cl]+=4;  #- remove the -1 add 3
				$scores[$cl]+=2;  #  add 1
				#$scores[$cl]+=3;   # add 2
			}
		}

		########################################################
		# find max
		my $max=-1000;
        	my $i=0;
        	my $imax=0;
       		my @bests=();

        	foreach my $s (@scores)
        	{
			if ($s>$max)
			{
                		$imax=$i;
                		$max=$s;
				@bests=();
				push(@bests,$imax);
			}elsif($s==$max){
				push(@bests,$i);
			}
                	$i++;
        	}
        	my $cl=$decode[$imax];
		my $multi="no";
		if ($#bests>0)
		{
			my $N=@bests;
			$multi="$N:$cl";
			for (my $b=1;$b<=$#bests;$b++)
			{
				$multi.="-$decode[$bests[$b]]";
			}
		}
		if ($vls[9] ne "Unassigned" && $vls[9] ne "NA" && $vls[9] ne "None")
		{
			$vls[9]=$cl;
		}
		if ($vls[9] eq "Unassigned" || $vls[9] eq "NA" || $vls[9] eq "None")
		{
			$multi=$cl;
		}
		push(@vls,$multi);
		my $outS=join("\t",@vls);
		print OUT "$outS\n";

	}
}


######################################################################################
# IN/OUT control
#
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
                        warn("All those moments will be lost in time, like tears in rain.\n Time to die!\n"); #HELP.txt
                        print_help();
                }
        }
}

sub check_input_arg_valid
{
        if ($arguments{"--metafile"} eq "na" ||  (! -e ($arguments{"--metafile"})))
        {
                print_help();
                my $f=$arguments{"--metafile"};
                die("Invalid metadata file provided. $f does not exist!");
        }
	if ($arguments{"--dfile"} eq "na" ||  (! -e ($arguments{"--dfile"})))
        {
                print_help();
                my $f=$arguments{"--dfile"};
                die("Invalid metadata file provided. $f does not exist!");
        }

}


sub print_help
{
        print " This utility can be used assign SARS-CoV-2 genomes a classification.\n";
        print " The main inputs consist in a file with a list of variants\n";
        print " and their characteristic mutations (output of augmentClusters.pl or any equivalent file) \n";
	print " and a metadata file in HaploCoV format.\n";
        print "##INPUT PARAMETERS\n\n";
        print "--dfile <<filename\t input file with the list of variants and their characteristic mutations\n(this is the output of augmentClusters.pl)\n";
        print "--metafile <<filename>>\tfile with metadata in .tsv format\n";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--out <<name>>\tName of the output file. Defaults to ASSIGNEDScore_out.tsv\n";
        print "\n##EXAMPLES:\n\n";
	print "perl assign_HGs_2021.pl --dfile defining.txt --metafile metadata.tsv\n"
}

