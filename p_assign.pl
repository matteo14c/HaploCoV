#!/usr/bin/perl -w
use strict;

my %arguments=
(
"--dfile"=>"na",
"--infile"=>"na",                  # directory with alignment files. Defaults to current dir
"--nproc"=>8,
"--update"=>"T",
#####OUTPUT file#############################################
"--outfile"=>"na" #file #OUTPUT #tabulare
);

check_arguments();


#######################################################################################
# read parameters
my $lvarFile=$arguments{"--dfile"};
my $metafile=$arguments{"--infile"};
my $nProc=$arguments{"--nproc"};
my $ofile=$arguments{"--outfile"};
my $update=$arguments{"--update"};

if ($lvarFile eq "linDefMut" && $update eq "T")
{
	download_refMut();
}

check_input_arg_valid();
check_exists_command('split') or die "$0 requires split to split the input file\n";
check_exists_command('tail') or die "$0 requires tail to concatenate input files\n";
check_exists_command('mv') or die "$0 requires mv to rename files\n";

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
			exec("perl assign.pl --infile $file --dfile $lvarFile  --outfile $file\_Assign.tmp") || die "can't exec $!";
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
	if (-e $ifile)
	{
		my $randTempName=sprintf "%08X", rand(0xffffffff);
		print "IMPORTANT!\n The output file $ifile does already exist. Renaming the old file to $ifile.$randTempName\n";
		system ("mv $ofile $ifile.$randTempName")==0||die("could not rename the pre-existing output file $ifile\n");
	}

	open(OO,">$ifile");
	print OO "genomeID\tcollectionD\toffsetCD\tdepositionD\toffsetDD\tcontinent\tarea\tcountry\tregion\tpangoLin\tlistV\talt\n";
	close(OO);
	foreach my $f (@files)
	{
		system ("tail -n +2 $f\_Assign.tmp >> $ifile")==0||die();
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
			die("Reason:\nInvalid parameter $act provided\n");
                }
        }
}

sub download_refMut
{
        print "I will now download the most recent version of linDefMut to assign Pango lineages\n";
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
        if ($arguments{"--infile"} eq "na" ||  (! -e ($arguments{"--infile"})))
        {
                print_help();
                my $f=$arguments{"--infile"};
                die("Reason:\nInvalid metadata file provided: $f. Please provide a valid file!");
        }
        if ($arguments{"--dfile"} eq "na" ||  (! -e ($arguments{"--dfile"})))
        {
                print_help();
                my $f=$arguments{"--dfile"};
                die("Reason:\nInvalid metadata file provided. $f does not exist!");
        }
	if ($arguments{"--nproc"}<0){
		print_help();
		my $n=$arguments{"--nproc"};
                die("Reason:\nCan not allocate a negative number of processors. $n provided!");

	}
	if ($arguments{"--outfile"} eq "na" || $arguments{"--outfile"} eq "." )
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Reason:\n$f is not a valid name for the output file. Please provide a valide name using --outfile");
        }

	if ($arguments{"--update"} ne "T" && $arguments{"--update"} ne "F"){
		print_help();
                my $f=$arguments{"--update"};
                die("Reason:\nNo valid argument provided to --update. --update was set to $f. This parameter can only be \"T\"=true or \"F\"=false!");
	
	}


}


sub print_help
{
        print " This utility can be used assign SARS-CoV-2 genomes a classification.\n";
        print " The main inputs consist in a file with a list of variants\n";
        print " and their characteristic genomic variants (designations file),\n";
        print " and a metadata file in HaploCoV format.\n";
        print "##INPUT PARAMETERS\n\n";
        print "--dfile <<filename>>\t Designations file. If linDefMut is used, the most recent version will be\n";
	print "                    \t downloaded from the HaploCoV github repository. See below;\n";
        print "--infile <<filename>>\tfile with metadata in HaploCoV format;\n";
	print "--nproc <<number>>\t number of processors/cores to use. Defaults to 8;\n";
	print "--update <<logical>>\t update linDefmut to the most recent version? T=true. F=false. Default=T.\n";
        print "\n##OUTPUT PARAMETERS\n\n";
        print "--outifile <<name>>\tName of the output file. Defaults to ASSIGN_out.tsv\n";
	print "\n##IMPORTANT\n";
        print "--dfile --infile and --outfile are mandatory parameters\n";
        print "\n##EXAMPLE:\n";
        print "perl p_assign.pl --dfile defining.txt --infile HaploCoV.tsv --nproc 8 --outfile assigned.txt\n"
}

