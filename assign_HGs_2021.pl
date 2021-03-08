use strict;

my %arguments=
(
"--dir"=>"align",                  # directory with alignment files. Defaults to current dir
#####OUTPUT file#############################################
"--out"=>"ASSIGNED_out.tsv" #file #OUTPUT #tabulare
);

check_arguments();



########################################################################################
# Populate score matrix. 
#
my @initscores=(-1);

#######################################################################################
# list of variants that define the haplogroups. Downloaded from github repo. hard-coded
# and there should be no reason to change it
my $lvarFile="listVariants.txt";

######################################################################################
# Populate score matrix

my %pos=();
open(IN,$lvarFile);
unless (-e $lvarFile)
{
	print "The file listVariants.txt was not found in the current directory\nThis file is required for running assign_HGs_2021.pl\nPlease download all the files from the Github repository again\n.";
}
while(<IN>)
{
	push(@initscores,0);
	my ($clus,@var)=(split());
	foreach my $var (@var)
	{
		push(@{$pos{$var}},$clus);
	}
	
}

my $dir=$arguments{"--dir"};
my $ofile=$arguments{"--out"};
open(OUT,">$ofile");
my @files=<$dir/*_ref_qry.snps>;
if (scalar @files == 0)
{
	#die("no input files were found in the input directory!\nPlease run align.pl before running this script\nPlease see the manual in the Github repo for more details\n";
}


my @genomes=();
print OUT "ID HG\n";
######################################################################################
# read every file

foreach my $f (@files)
{
	my @scores=@initscores;
	
	##########################################################
	# Trim names to remove the suffix

	my $name=$f;
	$name=~s/_ref_qry.snps//;
	$name=~s/\.\d+//;
	$name=~s/$dir//;
	$name=~s/\///;

	#########################################################
	# store variants seen in this genome
	my %Ihave=();	

	open(IN,$f);
	my %ldata=();
	while(<IN>)
	{
		next unless $_=~/NC_045512.2/;
                my ($pos,$b1,$b2)=(split(/\s+/,$_))[1,2,3];
		my $label="$pos\_$b1|$b2";
		$Ihave{$label}=1;
	}

	#######################################################
	# compare with variants that define clusters

	foreach my $pos (sort {$a<=>$b} keys %pos)
	{
		my @clusters=@{$pos{$pos}};
		if ($Ihave{$pos})
		{
			# I have it: +3
			foreach my $cl (@clusters)
			{
				$scores[$cl]+=3;
			}
		}else{
			# I don't -1
			foreach my $cl (@clusters)
                        {
                                $scores[$cl]-=1;
                        }
		
		}		
	}
	my $max=-100;
	my $i=0;
	my $imax=0;
	# find max score
	foreach my $s (@scores)
	{
		$imax=$i if $s>$max;
		$max=$s if $s>$max;
		$i++;
	}
	shift(@scores);
	$imax=1 if $imax==0;
	print OUT "$name $imax\n";
}


######################################################################################################################################################################
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

sub print_help
{
        print "This utility can be used assign SARS-CoV-2 genomes to HGs, as defined in Chiara et al 2021. Please see: https://doi.org/10.1093/molbev/msab049\n";
        print "A helper script, align.pl is included in the github repo. This script should be used to align SARS-CoV-2 genomes to the reference genome\n";
	print "The output of  align.pl should be provided as the input Please make sure that align.pl is executed BEFORE launching this script\n";
        print ":\n";
        print "##INPUT PARAMETERS\n\n";
        print "--dir <<directory>>\tinput directory. Should contain the files produced by align.pl (.snps format)\nDefaults to current directory";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--out <<name>>\tName of the output file. Defaults to ASSIGN_out.tsv\n";
        print "\n##EXAMPLES:\n\n";
        print "1# input is multi-fasta (apollo.fa):\nperl align.pl --multi apollo.fa\n\n";
}

