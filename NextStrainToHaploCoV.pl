use strict;

############################################################
### Arguments
#
my %arguments=
(
"--metadata"=>"na",      	# max time
"--outfile"=>"na" 		# min time
);
#
#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
##

my $metadata=$arguments{"--metadata"}; #file con varianti
my $ofile=$arguments{"--outfile"};

check_exists_command('sort') || die("The shell sort command is required to sort the output file\n");

my $refile="GCF_009858895.2_ASM985889v3_genomic.fna";
unless (-e $refile)
{
        download_ref();
}

my $ref=indexFA($refile);

###########################################################
# process the data

my ($data,$fileTosplit)=metadataToLists($metadata,$ofile,$ref);

#########################################################
# subs


sub metadataToLists
{
	my $c=0;
	my $metadataFile=$_[0];
	my $ofile=$_[1];
	my $ref=$_[2];
	open(OUT,">$ofile");
	my %areas=%{areas()};	
	open(IN,$metadataFile);
	my $header=<IN>;
	while (<IN>)
	{
		chomp();
		my @data=(split(/\t/));
		my $nfil=@data;
		if ($nfil!=52)
		{
			die ("Input file is in an unknown format: expected 52 tab delimited columns!\nGot $nfil\n");
		}
		my $id=$data[0];
		$id="NA" if $id eq "?";
		my $d=$data[6];
		my $s=$data[28];
		my $p=$data[20];
		$p="NA" if $p eq "?";
		my $continent=$data[7];
		my $country=$data[8];
		my $region=$data[9];
		my $alleles=$data[49];
		my $ins=$data[48];
		my $del=$data[47];
		my $lvar=build_listVar($alleles,$ins,$del,$ref);

		$id=fix_strain($id);
        	$country=~s/\s+//g;
		my $area=$areas{$country} ? $areas{$country} : "NA";
		$continent=~s/\s+//g;
		$region=~s/\s+//g;
		$continent="NA" if $continent eq "";
		$country="NA" if $country eq "";
		$region="NA" if $region eq "";
		
		$p="NA" if $p eq "";
		$d=fix_date($d);
		$s=fix_date($s);

		my $delta=diff_d($d);
		my $delta_sub=diff_d($s);
		print OUT "$id\t$d\t$delta\t$s\t$delta_sub\t$continent\t$area\t$country\t$region\t$p\t$lvar\n";

	}
	system("sort -n -k 3 $ofile  > $ofile.srt")==0||die("could not sort the output file by date\n");
        system("mv $ofile.srt $ofile")==0||die("could not sort the output file by date\n");

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
	$date = "NA" if $date eq "XXXX-XX-XX";
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

sub build_listVar
{
	my $var=$_[0];
	my $ins=$_[1];
	my $del=$_[2];
	my $seq=$_[3];
	my $ovar=();
	my @vars=(split(/\,/,$var));
	foreach my $v (@vars)
	{
		my $ref=substr($v,0,1);
		my $pos=substr($v,1,length($v)-2);
		my $alt=chop($v);
		next if $ref=~/[RYSWKMBDHVN]/;
		next if $alt=~/[RYSWKMBDHVN]/;
		#print "$v $ref $pos $alt\n";
		#die();
		$ovar.="$pos\_$ref|$alt,";
		#print "$v $ovar\n";
	}
	if ($ins ne "")
	{
		my @ivars=(split(/\,/,$ins));
		foreach my $i (@ivars)
		{
			next unless $i=~/\:/;
			my ($pos,$alt)=(split(/\:/,$i));
			my $ref=$alt;
			next if $ref=~/[RYSWKMBDHVN]/;
			$ref=~s/[ACTGN]/\./g;
			$ovar.="$pos\_$ref|$alt,";
		}
	}
	if ($del ne "")
	{
		my @dvars=(split(/\,/,$del));
		foreach my $d (@dvars)
                {
			next unless $d=~/\-/;
                        my ($s,$e)=(split(/-/,$d));
			my $length=$e-$s+1;
			my $ref=substr($seq,$s-1,$length);
                        my $alt=$ref;
			next if $ref=~/[RYSWKMBDHVN]/;
                        $alt=~s/[ACTGN]/\./g;
			$ovar.="$s\_$ref|$alt,";
                }

	}
	chop($ovar);
	#print "$ovar\n";
	return($ovar);
}

sub areas
{
        my $areaFile="areaFile";
        unless (-e $areaFile)
        {
                download_areas();
        }
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

sub download_areas
{
        print "Area file, not found in the current folder\n";
        print "Align.pl will try to Download the file from github\n";
        print "Please download this file manually, if this fails\n";
        check_exists_command('wget') or die "$0 requires wget to download areafile\nHit <<which wget>> on the terminal to check if you have wget\n";
        system("https://raw.githubusercontent.com/matteo14c/HaploCoV/master/areaFile")==0||die("Could not retrieve the required file areafile. The file is not in the current folder. Please download it!\n");

}

sub download_ref
{
        print "Reference genome file, not in the current folder\n";
        print "addToTable.pl will try to Download the reference genome from Genbank\n";
        print "Please download this file manually, if this fails\n";
        check_exists_command('wget') or die "$0 requires wget to download the genome\nHit <<which wget>> on the terminal to check if you have wget\n";
        check_exists_command('gunzip') or die "$0 requires gunzip to unzip the genome\n";
        system("wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz")==0||die("Could not retrieve the reference genome\n");
        system("gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz")==0 ||die("Could not unzip the reference genome");

}

sub indexFA
{
        my $fasta=$_[0];
        open(IN,$fasta);
        my $seq="";
        while(<IN>)
        {
                chomp;
                $seq.=$_;
        }
        return($seq);
}


sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
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


sub check_input_arg_valid
{
        if ($arguments{"--metadata"} eq "na" ||  (! -e ($arguments{"--metadata"})))
        {
                print_help();
                my $f=$arguments{"--file"};
                die("Reason:\nNo valid input file provided. $f does not exist!");
        }
	if ($arguments{"--outfile"} eq "na")
	{
		print_help();
		my $f=$arguments{"--outfile"};
                die("Reason:\nNo valid output file provided. --outfile was set to $f. This is not a valid name!");
	}
}

sub print_help
{
        print " This utility is meant to 1) convert metadata of SARS-CoV-2 isolates from Nextstrain";
	print " to HaploCov format\n";
	print " The final output will consist in a metadata table in HaploCov format, which can\n";
	print " be used as the input to several other utilities in HaploCoV\n";
	

	print "##INPUT PARAMETERS\n\n";
        print "--metadata <<filename>>\t metadata file\n";
	print "--outfile <<filename>>\t output metadata file in HaploCoV format. Defaults to\n";
        print "\n Mandatory parameters: --metadata \n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is metadata.tsv:\nperl compute.pl --metadata metadata.tsv  --outfile HaploCoV_formattedMetadata\n\n";
}
