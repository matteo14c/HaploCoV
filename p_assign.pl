#!/usr/bin/perl -w
use strict;

my %arguments=
(
"--dfile"=>"na",
"--metafile"=>"na",                  # directory with alignment files. Defaults to current dir
"--nproc"=>8,
#####OUTPUT file#############################################
"--out"=>"na" #file #OUTPUT #tabulare
);

check_arguments();


#######################################################################################
# read parameters
my $lvarFile=$arguments{"--dfile"};
my $metafile=$arguments{"--metafile"};
my $nProc=$arguments{"--nproc"};
my $ofile=$arguments{"--out"};

if ($lvarFile eq "linDefMut")
{
	download_refMut();
}

check_input_arg_valid();
check_exists_command('split') or die "$0 requires split to split the input fasta file\n";
check_exists_command('cat') or die "$0 requires cat to concatenate input fasta files\n";


my $files=split_file($metafile,$nProc);
parallel_assign($files,$lvarFile);
merge($files,$ofile);


sub parallel_assign
{
	my @files=@{$_[0]};
	my $numP=@files;
	my @childs=();
	for (my $i=0;$i<$numP;$i++)
	{
		my $pid=fork();
		my $file=$files[$i];
		unless (defined($pid))
		{
			die "Cannot fork a child: $!";
		}elsif ($pid == 0) {
			#print "Printed by $i $file child process\n";
			exec("perl assign.pl --metafile $file --dfile $lvarFile  --out $file\_Assign.tmp") || die "can't exec $!";
			exit(0);
		}else {
			push(@childs,$pid);
		}
	}
	#print "@childs\n";
	foreach(@childs){
		my $tmp=waitpid($_,0);
	}
	foreach my $f (@files)
	{
		system ("rm $f")==0||die("I can not remove temporary files\n");
	}
}

sub split_file
{
	my $ifile=$_[0];
	my $proc=$_[1];
	my $Totlines=`wc -l $ifile`;
	chomp($Totlines);
	$Totlines=(split(/\s+/,$Totlines))[0];
	my $nlines=int($Totlines/($proc))+1;
	#print "$Totlines $nlines\n";
	system("split -d -l $nlines $ifile SPLITcovidSeq")==0||die();
	my @files=<SPLITcovidSeq*>;
	#print "@files\n";
	return(\@files);	
}

sub merge
{
	my @files=@{$_[0]};
	my $ifile=$_[1];
	foreach my $f (@files)
	{
		system ("cat $f\_Assign.tmp >> $ifile")==0||die();
		system ("rm $f\_Assign.tmp")==0||die();
	}
}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
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

sub download_refMut
{
        print "I will now donload the most recent version of linDefMut to assign Pango lineages\n";
	print "will rename the old copy to linDefMut.old\n";
	if (-e "linDefMut")
	{
		system("mv linDefMut.old")==0||die("could not remove the old version of linDefMut")
	}
        print "Downloading linDefMut from the github repo. Please download this file manually, if this fails\n";
        check_exists_command('wget') or die "$0 requires wget to download the genome\nHit <<which wget>> on the terminal to check if you have wget\n";
        system("wget https://raw.githubusercontent.com/matteo14c/HaploCoV/updates/linDefMut")==0||die("Could not retrieve the reference annotation used by HaploCov\n")

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
	if ($arguments{"--nproc"}<0){
		print_help();
		my $n=$arguments{"--nproc"};
                die("Can not allocate a negative number of processors. $n provided!");

	}
	if ($arguments{"--out"} eq "na")
        {
                print_help();
                my $f=$arguments{"--out"};
                die("Reason:\nNo valid output file provided. --outfile was set to $f. This is not a valid name!");
        }


}


sub print_help
{
        print " This utility can be used assign SARS-CoV-2 genomes a classification.\n";
        print " The main inputs consist in a file with a list of variants\n";
        print " and their characteristic mutations (outout of augmentClusters.pl).\n";
        print " and a metadata file (see align.pl) with metadata associated to.\n";
        print " each genome file\n";
        print "##INPUT PARAMETERS\n\n";
        print "--dfile <<filename>>\t input file with the list of variants and their characteristic mutations\n(this is the output of augmentClusters.pl)\n";
        print "--metafile <<filename>>\tfile with metadata in .tsv format\n";
	print "--nproc <<number>>\t number of processors/cores to use. Default 8\n";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--out <<name>>\tName of the output file. Defaults to ASSIGN_out.tsv\n";
	print "\n##IMPORTANT\n";
        print "--dfile --metafile and --out are mandatory parameters\n";
        print "\n##EXAMPLE:\n";
        print "perl p_assign.pl --dfile defining.txt --metafile linearDataSorted.txt --nproc 8 --out assigned.txt\n"
}

