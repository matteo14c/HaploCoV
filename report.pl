use strict;

############################################################
# Arguments
#
my %arguments=
(
"--infile"=>"na",         # name of the input file
"--scaling"=>"scalingFactors.csv",
"--outfile"=>"na",          # max time
"--suffix"=>"N"
);

############################################################
## Process input arguments and check if valid
##
check_arguments();
check_input_arg_valid();
#

##############################################################
#   Get arguments
#
#
my $scaling=$arguments{"--scaling"};
my $infile=$arguments{"--infile"};
my $prefix=$arguments{"--suffix"};
my $outfile=$arguments{"--outfile"};

##############################################################
# process arguments
#
my %hold=%{read_scaling($scaling)};
my %decode=%{read_header($infile)};
update_scaling($infile,$prefix,\%hold,\%decode);
my $vocness=compute_vocness($infile,\%hold,\%decode);
print_pass($vocness,$prefix,$outfile);


################################################################
# functions
#
sub read_scaling
{
	my $scaling=$_[0];
	open(IN,$scaling);
	my %hold=();
	while(<IN>)
	{
        	chomp();
        	my ($key,$val)=(split())[0,1];
        	$key=~s/"//g;
        	$key=~s/\./:/;
        	$hold{$key}=$val;
        }
	return(\%hold);
}

sub read_header
{
	my $infile=$_[0];
	my %decode=();
	open(IN,$infile);
	my $header=<IN>;
	chomp($header);
	my @val=(split(/\t/,$header));
	my $i=0;
	foreach my $v (@val)
	{
        	$decode{$v}=$i;
                $i++;
        }
	return(\%decode);
}

sub update_scaling
{
	my $infile=$_[0];
	my $prefix=$_[1];
	my $hold=$_[2];
	my %decode=%{$_[3]};
	while(<IN>)
	{
        	chomp();
        	my @data=(split(/\t/));
        	next if $data[0]=~/\.$prefix\d+/;
        	foreach my $k (keys %$hold)
        	{
                	die(@data) if $k eq "";
                	my $pos=$decode{$k};
                	if ($data[$pos]>$hold->{$k})
                	{
				$hold->{$k}=$data[$pos];
                	}
		
		}
        }
	open(OUT,">scaling.upd.csv");
	foreach my $k (keys %$hold)
	{
		print OUT "$k\t".$hold->{$k}."\n";
	}
}

sub compute_vocness
{
	my $infile=$_[0];
	my $hold=$_[1];
	my $decode=$_[2];
	my %vocness=();
	open(IN,$infile);
	my $head=<IN>;
	while(<IN>)
	{
        	chomp();
        	my $vocness=0;
        	my @data=(split(/\t/));
        	my $lin=$data[0];
        	foreach my $k (keys %$hold)
        	{
                	my $pos=$decode->{$k};
                	$vocness+=$data[$pos]/$hold->{$k};

        	}
        	$vocness{$lin}=$vocness;
		#print "$lin $vocness\n";
	}
	return(\%vocness);

}	

sub print_pass
{
	my %vocness=%{$_[0]};
	my $prefix=$_[1];
	my $outfile=$_[2];
	open(OUT,">$outfile");
	print OUT "newLab Parent scoreNew scorePar scoreDiff\n";
        foreach my $variant (keys %vocness)
	{
		#print "$variant\n";
		next unless $variant=~/\.$prefix\d+/;
        	my $Pvariant=$variant;
		my $score=$vocness{$variant};
		$Pvariant=~s/\.$prefix\d+//;
        	my $legacyScore=$vocness{$Pvariant};
        	next unless $vocness{$Pvariant};
        	my $diff=$score-$legacyScore;
		if ($score-$legacyScore>=1.5 && $score>=5)
		{
                	print OUT "$variant $Pvariant $score $legacyScore $diff\n";
		}	
	}
}


######################################################################################
# check input and help
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
                die("Invalid variants file provided. $f does not exist!");
        }
	if ($arguments{"--scaling"} eq "na" ||  (! -e ($arguments{"--scaling"})))
        {
                print_help();
                my $f=$arguments{"--scaling"};
                die("Invalid configuration file provided. $f does not exist!");
        }

        if ($arguments{"--outfile"} eq "na")
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Invalid outfile name provided. $f please provide a valide name using --outfile");
        }

}

sub print_help
{
        print " This utility is used compare scores as obtained by LinToFeats.pl\n";
	print " and priotitize lineages/sub lineages of SARS-CoV-2 showing an\n"; 
	print " increased score with respect to its parental lineage\n";
        print " Users are required to provide:\n";
	print " 1) --infile an input file, this corresponds to the output of LinToFeats.pl;\n";
        print " 2) the suffix used to indicate \"novel\" lineages/sublineages.This suffix\n";
       	print " MUST match that used by augmentClusters.pl. The default value is N.\n";
        print " 3) a configuration file --scaling: with the list of features used for the\n";
       	print " computation of the final score.\n\n";
        print " A complete description of the features can be found in the features.csv file\n";	print " in this github repo\n";
        print " The final output consist in a simple text file, in tsv format, where\n";
       	print " high scoring varants/sub-variants are reported\n";
        print " Please see Chiara et al 2022 (under review) for more details\n";
        print "##INPUT PARAMETERS\n\n";
        print "--infile <<filename>>\t scores compute by LinToFeats.pl \n";
        print "--suffix <<string>>\t suffix used to identify novel lineages/subvariants\n";
        print "--scaling <<filename>>\t defaults to \"scalingFactors.csv\"\n";
        print "--outfile <<filename>>\t a valid name for the output file\n";
        print "\nTo run the program you MUST provide at least --infile and --outilfe\n";
        print "all files needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is score.csv and the output pass.csv:\nperl report.pl --infile score.csv --outfile pass.csv \n\n";
}

