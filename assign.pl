use strict;

my %arguments=
(
"--dfile"=>"na",
"--infile"=>"na",                  # directory with alignment files. Defaults to current dir
#####OUTPUT file#############################################
"--outfile"=>"na" #file #OUTPUT #tabulare
);

check_arguments();


#######################################################################################
# read parameters
my $lvarFile=$arguments{"--dfile"};
my $metafile=$arguments{"--infile"};
my $ofile=$arguments{"--outfile"};

check_input_arg_valid();

######################################################################################
# Populate score matrix
my ($initscores,$decode,$pos)=populate_matrix($lvarFile);

######################################################################################
# assign genomes
assign($initscores,$decode,$pos);


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
	print OUT "genomeID\tcollectionD\toffsetCD\tdepositionD\toffsetDD\tcontinent\tarea\tcountry\tregion\tpangoLin\tlistV\talt\n";
	open(IN,$metafile);
	my $header=<IN>;
        my @fields=(split(/\t/,$header));
        my $fields=@fields;
        unless ($fields==11 || $fields==12)
        {
                die("\n The input is not in the expected format: I got $fields columns,\n but I expect 10 (HaploCoV formatted file) or 11(HaploCoV formatted file+assign.pl).\n\n Please provide a valid file.\n\n");
        }

	while(<IN>)
	{
		chomp();
        	my @scores=@initscores;
        	my @vls=(split(/\t/));
        	my $lvar=$vls[10];
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
			#print "$i $s\n";
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
		#if ($vls[9] ne "Unassigned" && $vls[9] ne "NA" && $vls[9] ne "None")
		#{
		$vls[9]=$cl;
			#}
			#if ($vls[9] eq "Unassigned" || $vls[9] eq "NA" || $vls[9] eq "None")
			#{
			#$multi=$cl;
			#}
		if ($#vls==10)
		{
			push(@vls,$multi);
		}elsif($#vls==11){
			$vls[11]=$multi;
		}
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
			die("Reason:\nInvalid parameter $act provided\n");
                }
        }
}

sub check_input_arg_valid
{
        if ($arguments{"--infile"} eq "na" ||  (! -e ($arguments{"--infile"})))
        {
                print_help();
                my $f=$arguments{"--infile"};
                die("Reason:\nInvalid metadata file provided. $f does not exist! Please provide a valid input file with --infile\n");
        }
	if ($arguments{"--dfile"} eq "na" ||  (! -e ($arguments{"--dfile"})))
        {
                print_help();
                my $f=$arguments{"--dfile"};
                die("Reason:\nInvalid metadata file provided. $f does not exist!");
        }
	if ($arguments{"--outfile"} eq "na" || $arguments{"--outfile"} eq "." )
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Reason:\n$f is not a valid name for the output file. Please provide a valide name using --outfile");
        }



}


sub print_help
{
        print " This utility can be used assign SARS-CoV-2 genomes a classification.\n";
        print " The main inputs consist in a file with a list of SARS-CoV-2 variants\n";
        print " and their characteristic genomic variants (Designations file) \n";
	print " and a metadata file in HaploCoV format.\n";
        print "##INPUT PARAMETERS\n\n";
        print "--dfile <<filename\t designations file (viral variants and defining genomic variants);\n";
        print "--infile <<filename>>\t input file in HaploCoV format;\n";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--outfile <<name>>\tName of the output file.\n";
	print "\n##IMPORTANT\n";
	print "All the parameters are mandatory/required\n";
        print "\n##EXAMPLE:\n";
	print "perl assign.pl --dfile defining.txt --infile HaploCoV.tsv --outfile HaploCoV.assigned.tsv\n"
}

