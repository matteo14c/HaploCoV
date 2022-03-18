use strict;

my %arguments=
(
"--infile"=>"na",
"--dir"=>"align",                  # directory with alignment files. Defaults to current dir
#####OUTPUT file#############################################
"--out"=>"ASSIGNED_out.tsv" #file #OUTPUT #tabulare
);

check_arguments();



########################################################################################
# Populate score matrix. 
#
my @initscores=();

#######################################################################################
# list of variants that define the groups. 
my $lvarFile=$arguments{"--infile"};

######################################################################################
# Populate score matrix

my %pos=();
open(IN,$lvarFile);
unless (-e $lvarFile)
{
	print "The file $lvarFile was not found in the current directory\nThis file is required for running assign_HGs_2021.pl\n";
	print_help();
}


my @decode=();
my %pos=();

my $iclus=0;
while(<IN>)
{
        push(@initscores,0);
        my ($clus,@var)=(split());
        #print "$clus\n";
        foreach my $var (@var)
        {
                next if $var eq "none";
                push(@{$pos{$var}},$iclus);
        }
        $decode[$iclus]=$clus;
        $iclus++;

}

my $dir=$arguments{"--dir"};
my $ofile=$arguments{"--out"};
open(OUT,">$ofile");
my @files=<$dir/*_form.txt>;
if (scalar @files == 0)
{
	#die("no input files were found in the input directory!\nPlease run align.pl before running this script\nPlease see the manual in the Github repo for more details\n";
}


my @genomes=();
print OUT "ID group\n";
######################################################################################
# read every file

foreach my $f (@files)
{
	my @scores=@initscores;
	
	##########################################################
	# Trim names to remove the suffix

	my $name=$f;
	$name=~s/_form.txt//;
	$name=~s/\.\d+//;
	$name=~s/$dir//;
	$name=~s/\///;

	#########################################################
	# store variants seen in this genome
	my %Ihave=%{read_snp($f)};

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
	my $cl=$decode[$imax];
	print OUT "$name $cl\n";
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
        print "This utility can be used assign SARS-CoV-2 genomes a classification. The main inputs consist in a file with a list of variants\n";
        print "and their characteristic mutations (outout of augmentClusters.pl) and a collection of files with allele variants. One file\n";
	print "for every genome included in the analysis. These files are the main output of align.pl Please make sure that align.pl is executed BEFORE launching this script\n";
        print ":\n";
        print "##INPUT PARAMETERS\n\n";
        print "--infile <<filename\t input file with the list of variants and their characteristic mutations\n(this is the output of augmentClusters.pl)";
        print "--dir <<directory>>\tinput directory. Should contain the files produced by align.pl (.snps format)\nDefaults to current directory";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--out <<name>>\tName of the output file. Defaults to ASSIGN_out.tsv\n";
        print "\n##EXAMPLES:\n\n";
        print "1# input is multi-fasta (apollo.fa):\nperl align.pl --multi apollo.fa\n\n";
}

sub read_snp
{
        my $file=$_[0];
        my %dat_final=();
        open(IN,$file);
        while(<IN>)
        {
                #print;
                chomp();
                $dat_final{$_}=1;
        }
        return(\%dat_final);
}
