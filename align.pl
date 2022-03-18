use strict;

############################################################
## Arguments

my %arguments=
(
"--file"=>"na",		 # name of the input file
"--snps"=>"./snps",	 # folder for variant calls
"--genomes"=>"./genomes" # folder for genome sequence file
);

############################################################
##Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
#

my $refile="GCF_009858895.2_ASM985889v3_genomic.fna";
unless (-e $refile)
{
        download_ref();
}

my $file=$arguments{"--file"};
my $snpsF=$arguments{"--snps"};
my $genomesF=$arguments{"--genomes"};

print "$file $snpsF $genomesF\n";

check_exists_command('mkdir') or die "$0 requires mkdir to create a temporary directory\n";

unless (-e $snpsF)
{        
	system("mkdir $snpsF")==0||die ("can not create temporary directory $snpsF\n");
}


unless (-e $genomesF)
{        
	system("mkdir $genomesF")==0||die ("can not create temporary directory $snpsF\n");
}

open(IN,$file);
my $seq="";
my $strain="";
while(<IN>)
{
	chomp();
	if ($_=~/^>(.*)/)
	{
		if ($seq ne "" && $strain ne "")
		{
			unless (-e "$snpsF/$strain\_ref_qry.snps")
			{
				my $randTempName=sprintf "%08X", rand(0xffffffff);
				$seq=fix_seq($seq);
				open(OUTFA,">$genomesF/$strain.fasta");
				print OUTFA ">$strain\n$seq\n";
				print "nucmer --prefix=$randTempName $refile $genomesF/$strain.fasta\n";
				system("nucmer -l 9 --maxmatch -c 50 --prefix=$randTempName $refile $genomesF/$strain.fasta")==0||die("no nucmer alignment $strain\n");
				#print "show-snps -Clr $randTempName.delta > snps/$strain\_ref_qry.snps\n";
				system("show-snps -Clr $randTempName.delta > $snpsF/$strain\_ref_qry.snps")==0||warn("no snps call $strain\n");
				open(OUTSNP,">$snpsF/$strain\_form.txt");
                		my %ihave=%{read_snp("$snpsF/$strain\_ref_qry.snps")};
                		foreach my $pos (sort{$a<=>$b} keys %ihave)
                		{
                        		print OUTSNP "$pos\n";
                		}
                		close(OUTSNP);
				system("rm $snpsF/$strain\_ref_qry.snps")==0||die("Failed to remove .snps intermediate file for $strain\n");
				system("rm  $randTempName.delta")==0||die("Failed to remove temp .delta file for $strain");
			}
		}
		$strain=$1;
		$strain=(split(/\|/,$strain))[0];
		$strain=fix_strain($strain);
		$seq="";
	}else{
		$seq.=$_;
	}
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

sub fix_seq
{
	my $seq=$_[0];
	$seq=~s/\.//g;
        $seq=~s/\s+//g;
        $seq=~s/\-//g;
        $seq=uc($seq);
	return($seq);
}

sub read_snp
{
        my $file=$_[0];
        open(SN,$file);
        my %ldata=();
        while(<SN>)
        {
                next unless $_=~/NC_045512.2/;
                my ($pos,$b1,$b2)=(split(/\s+/,$_))[1,2,3];
                next if $b2=~/N/;
		unless ($ldata{$pos})
		{
                	$ldata{$pos}=[$b1,$b2];
		}else{
			$ldata{$pos}[0].=$b1;
			$ldata{$pos}[1].=$b2;
		}
        }
        my %dat_final=();
        my $prev_pos=0;
        my $prev_ref="na";
        my $prev_alt="na";
        my $pos_append="na";
        foreach my $pos (sort{$a<=>$b} keys %ldata)
        {
                my  $dist=$pos-$prev_pos;
                if ($dist>1)
                {
			my $ADJ=compute_adj($prev_ref,$prev_alt);
                        $pos_append=$prev_pos-length($prev_alt)+1;
			my $pos2=$prev_pos-$ADJ;
                        $dat_final{"$pos2\_$prev_ref|$prev_alt"}=1 unless $prev_ref eq "na";
                        $prev_ref=$ldata{$pos}[0];
                        $prev_alt=$ldata{$pos}[1];
                }else{
                        $prev_ref.=$ldata{$pos}[0];
                        $prev_alt.=$ldata{$pos}[1];
                }
                $prev_pos=$pos;
        }
        $pos_append=$prev_pos-length($prev_alt)+1;
        $dat_final{"$pos_append\_$prev_ref|$prev_alt"}=1 if $prev_ref ne "na";
        return(\%dat_final);
}



sub compute_adj
{
	my $ref=$_[0];
	my $alt=$_[1];
	my $dotsR=count_dots($ref);
	my $dotsA=count_dots($alt);
	my $adjust=length($alt)-$dotsR-1;
	$adjust=0 if $adjust<0;
	return($adjust);
}

sub count_dots
{	
	my $str=$_[0];
	my @str=(split('',$str));
	my $c=0;
	foreach my $s (@str)
	{
		$c++ if $s eq ".";
	}
	return($c);
}

######################################################################
# Functions for input control and help
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

sub download_ref
{
        print "Reference genome file, not in the current folder\n";
        print "Align.pl will try to Download the reference genome from Genbank\n";
        print "Please download this file manually, if this fails\n";
        check_exists_command('wget') or die "$0 requires wget to download the genome\nHit <<which wget>> on the terminal to check if you have wget\n";
        check_exists_command('gunzip') or die "$0 requires gunzip to unzip the genome\n";
        system("wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz")==0||die("Could not retrieve the reference genome\n");
        system("gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz")==0 ||die("Could not unzip the reference genome");

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
}

sub print_help
{
        print "This utility can be used to 1) download the reference SARS-CoV-2 genome from Genbank and 2) align it with a collection\n";
        print "of SARS-CoV-2 genomes. And finally 3)Call/identify genomic variants.  On any *nix based system the script should be\n";
        print "completely capable to download the reference genome by itself.  Please download the genome yourself if this fails.\n";
        print "Input genomes, in multifasta format are provided by the --file parameter. While --snps and --genomes specify the names\n";
	print "of the directories where output files will be written\n";
	print "--snps: folder with variant calls for every genome sequence\n";
        print "--genomes: folder with single sequences in fasta format\n";
        print "##INPUT PARAMETERS\n\n";
        print "--file <<filename>>\t provides a multifasta of genome sequences\n";
        print "--snps <<dir name>>\t defaults to ./snps\n";
        print "--genomes <<dir name>>\t defaults to ./genomes\n";
        print "\nTo run the program you MUST provide at least --file\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is multi-fasta (apollo.fa):\nperl align.pl --file apollo.fa\n\n";
}


