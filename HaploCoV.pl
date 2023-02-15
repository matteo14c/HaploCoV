#!/usr/bin/perl -w
use strict;

###########################################################
### Arguments
#
my %arguments=
(
"--file"=>"na",         # name of the input file
"--locales"=>"na",
"--path"=>"./",         # max time
"--param"=>"parameters",          # min time
"--varfile"=>"n",
);
#
#############################################################
###Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
check_exists_command('mkdir') || die("The unix shell mkdir program is needed to create a directory for storing indermediate files!\n");
check_exists_command('mv') || die("The mv command is required to rename temporay files!\n");
##

my $P=0.05;
my $NW=4;

###############################################################
##

my $paraFile=$arguments{"--param"};
my ($parameters,$prev,$wlen)=process_parameters($paraFile);
print "$paraFile\n";

$P=$prev if $prev ne "NA";
$NW=$wlen if $wlen ne "NA";
my %parameters=%$parameters;

my $haploCOV=$arguments{"--path"};
my $locales=$arguments{"--locales"};
my $reference=$arguments{"--file"};
my $varfile=$arguments{"--varfile"};

##############################################################
#
my %configuration=%{process_locales($locales,$reference)};

##############################################################
#
foreach my $file (keys %configuration)
{
	my @list=@{$configuration{$file}};
	print "$file @list\n";
}

process_data(\%configuration,\%parameters,$varfile);
#############################################################
#
sub process_data
{
	my %configuration=%{$_[0]};
	my %parameters=%{$_[1]};
	my $varfile=$_[2];
	
	my $augmentString=$parameters{"augmentClusters.pl"};
	my $afString=$parameters{"computeAF.pl"};
	my $linString=$parameters{"LinToFeats.pl"};
	my $reportString=$parameters{"report.pl"};
	my $assignString=$parameters{"p_assign.pl"};
	my $increaseString=$parameters{"increase.pl"};
	
	foreach my $reference (keys %configuration)
	{
        	my @lvarFiles=@{$configuration{$reference}};

		
		#2 compute novel groups and compute reports
        	foreach my $file (@lvarFiles)
        	{
			my $opath="$reference\_$file\_results";
                	my $path=guess_path($reference,$file);
			my $ofile=augment($reference,$file,$path,$augmentString);
               		my ($score,$features)=score($ofile,$linString,$reportString);
			my ($prevalence,$assigned)=prevalence($reference,$ofile,$assignString,$increaseString);
			my $randTempName=sprintf "%08X", rand(0xffffffff);

			if (-e "$opath")
			{
				print "IMPORTANT!\n The destination directory $opath already exists.\n I will rename the \"old\" directory to $opath.$randTempName\n";
				system("mv $opath $opath.$randTempName")==0||die("could not rename the directory with temporary files\n");
			}
                        
			system("mkdir $opath")==0||die();
                	
			my @files=($ofile,$score,$prevalence,$features,$assigned);
			push(@files,$path) if $file eq "custom";
					
			print " step #4 Move temporary files to $opath\n";
			foreach my $temp (@files)
			{
				system("mv $temp $opath")==0||die("could not move temporary file $temp to directory $opath\n");
			}

                	my $otp="$reference\_$file.rep";
			if (-e "$otp")
			{
				print "IMPORTANT!\n The output file $otp does already exist. Renaming the old file to $otp.$randTempName\n";
				system ("mv $otp $otp.$randTempName")==0||die("could not rename the pre-existing output file $otp\n");
			}
			my $ovf=$varfile eq "n" ?  "NA" : "$reference\_$file.var"; 
			if (-e $ovf)
			{
				print "IMPORTANT!\n The output file $ovf does already exist. Renaming the old file to $ovf.$randTempName\n";
                                system ("mv $ovf $ovf.$randTempName")==0||die("could not rename the pre-existing output file $ovf\n");

			}
                	generate_final_report($opath,$ofile,$score,$prevalence,$NW,$P,$otp,$ovf,$varfile);
			print "final results written to $otp\n\n";
        	}
	}

}



sub generate_final_report
{
	my $folder=$_[0];
	my $def=$_[1];
	my $score=$_[2];
	my $prevalence=$_[3];
	my $intN=$_[4];
	my $minpv=$_[5];
	my $ofile=$_[6];
	my $rfile=$_[7];
	my $varfile=$_[8];

	my %ldf=();
	if ($varfile eq "b" || $varfile eq "a")
	{
		open(V,">$rfile");
		open(D,"$folder/$def");
		while(<D>)
		{
			my ($lin,@muts)=(split());
                	my $lmuts=join(' ',@muts);
			$ldf{$lin}=$lmuts;
		}
	}
	open(my $fh,">$ofile");

	my ($pass_score,$listPass_score)=process_score("$folder/$score","$folder/$def");
	my ($listP,$latestP,$above,$listPass_prevalence)=process_prevalence("$folder/$prevalence",$intN,$minpv,$pass_score);
	

	my @passBoth=();
	my @passScore=();
	my @passPrev=();

	foreach my $pass (keys %$listPass_score)
	{
		if ($listPass_prevalence->{$pass})
		{	
			push (@passBoth,$pass);
		}else{
			push(@passScore,$pass);
		}
	}

	foreach my $pass2 (keys %$listPass_prevalence)
	{
		if ($listPass_score->{$pass2})
		{
			next;
		}else{
			push(@passPrev,$pass2);
		}
	}
	my $nb=@passBoth;
	my $ns=@passScore;
	my $np=@passPrev;

	my $totNumPass=$nb+$ns+$np;

	print $fh "# A total of $totNumPass novel candidate sublineage(s)/subvariant(s) passed either the score or prevalence based thresholds\n";
	print $fh "# Of these $nb passed both the thresholds\n";
	print $fh "# $ns passed the score threshold only\n";
	print $fh "# and $np  passed the prevalence threshold only\n";

	
	if ($#passBoth>=0)
	{
		print $fh "# The following candidate variants/lineages passed both the treshold(s). A detailed report follows\n\n";
		my $b=0;
		foreach my $pass (@passBoth)
		{
			$b++;
			print $fh "######\n#$b $pass\n";
			print V "$pass $ldf{$pass}\n" if $varfile eq "b" || $varfile eq "a";
			print_passScore($pass_score->{$pass},$fh);
			print_passPrev($listP->{$pass},$latestP->{$pass},$above->{$pass},$fh);
		}
	}else{
		print $fh "# No candidate variants/lineages passed both thresholds\n";
		print $fh "# Skipping to variants that passed the score threshold\n\n";
	}


	if ($#passScore>=0)
        {
                print $fh "# The following candidate variants/lineages passed only the score treshold. A detailed report follows\n\n";
                my $s=0;
		foreach my $pass (@passScore)
                {
			$s++;
			print $fh "######\n#$s $pass\n";
                        print_passScore($pass_score->{$pass},$fh);
			print V "$pass $ldf{$pass}\n" if $varfile eq "a";	
			$listP->{$pass}{"none"}{"none"}=["NA","NA"] unless $listP->{$pass};
			$latestP->{$pass}{"none"}="NA" unless $latestP->{$pass};
			$above->{$pass}{"none"}="NA" unless $above->{$pass};
			
                        print_passPrev($listP->{$pass},$latestP->{$pass},$above->{$pass},$fh);
                }
        }else{
                print $fh "# No candidate variants/lineages passed only the score threshold\n";
                print $fh "# Skipping to variants that passed the prevalence threshold\n\n";
        }


	if ($#passPrev>=0)
	{
		my $p=0;
	       	print $fh "# The following candidate variants/lineages passed the prevalence threshold only. A detailed report follows\n\n";
	        foreach my $pass (@passPrev)
	        {
			$p++;
			print $fh "#####\n#$p $pass\n";
			print V "$pass $ldf{$pass}\n" if $varfile eq "a";
	                print_passScore($pass_score->{$pass},$fh);
	                print_passPrev($listP->{$pass},$latestP->{$pass},$above->{$pass},$fh);
	        }
	}else{
	        print $fh "# No candidate variants/lineages passed the prevalence threshold\n\n";
	}
}


sub process_score
{
	my $f=$_[0];
	my $def=$_[1];

	my %mlin=();
	my %defining=();
       	open(IN,$def);
       	while(<IN>)
        {
        	my ($lin,@muts)=(split());
		my $lmuts=join(' ',@muts);
		$mlin{$lin}=$lmuts;
                foreach my $m (@muts)
                {
                	$defining{$lin}{$m}=1;
         	}
        }


	my %ListP=();
	my %pass=();
	open(IN,$f);
	my $header=<IN>;
	while(<IN>)
	{
		chomp();
		my ($lin,$parent,$score,$scoreP,$diff,$pass)=(split(/\s+/));
		my $deFstring="\n\tdefined by: $mlin{$lin}\n\n\tgained (wrt parent):";
		foreach my $m (keys %{$defining{$lin}})
		{
			$deFstring.=" $m" unless $defining{$parent}{$m};
		}

		$deFstring.="\n\n\tlost (wrt parent):";
		foreach my $m (keys %{$defining{$parent}})
		{
		        $deFstring.=" $m" unless $defining{$lin}{$m};
		}
		$deFstring.="\n";



		$ListP{$lin}=[$parent,$score,$scoreP,$diff,$deFstring];
		$pass{$lin}++ if $pass eq "PASS";

	}
	
	return (\%ListP,\%pass);
}

sub print_passScore
{
	my @arrayData=@{$_[0]};
	my $score1=sprintf("%.2f",$arrayData[2]);
        my $score2=sprintf("%.2f",$arrayData[1]);

	my $handle=$_[1];
	print $handle "Parent: $arrayData[0]\n";
	print $handle "\nScore parent: $score1 - Score subV: $score2\n";
	print $handle "Genomic variants: $arrayData[-1]\n";
	print $handle "\n";
}


sub process_prevalence
{
	my $pfile=$_[0];
	my $n_intervals=$_[1];
	my $min_prevalence=$_[2];
	my $novel=$_[3];

	my %pass=();
	my %listP=();
	my %latestP=();
	my %intervals_above=();

	open(IN,$pfile);
	
	my $interval="NA";
	my $end="NA";
	while(<IN>)
	{
		chomp();
		if ($_=~/#Interval/)
		{
			$interval=$_;
			my ($intervalS,$intervalE)=(split(/\s/,$interval))[1,-1];
			$interval="$intervalS to $intervalE";
			$end=$intervalE;
		}else{
			next if $_=~/#lineage/;	
			my ($lin,$reg,@prevData)=(split());
			next unless $lin;
			next unless $novel->{$lin};
			my $pass=pop(@prevData);
			
			if ($pass == 1)
			{
				$listP{$lin}{$interval}{$reg}=[$prevData[0],$prevData[$n_intervals-1],$prevData[$n_intervals],$prevData[$n_intervals*2-1]];
				$pass{$lin}++;
			}
			next if $prevData[$n_intervals-1] eq "NA";
			my $P=sprintf("%.4f",$prevData[$n_intervals-1]);
			my $T=$prevData[$n_intervals*2-1];
			$latestP{$lin}{$reg}="$end $P-($T)" if $P>0;
			$intervals_above{$lin}{$reg}++ if $prevData[$n_intervals-1]>=$min_prevalence;
		}
	}
	return(\%listP,\%latestP,\%intervals_above,\%pass);
}

sub print_passPrev
{
	#                        print_passPrev($listP->{$pass},$latestP->{$pass},$above->{$pass},$fh);
	my %listP=%{$_[0]};
	my %latestP=%{$_[1]};
	my %intervals_above=%{$_[2]};
	my $handle=$_[3];
	print $handle "# Prevalence in time\n\n";
	foreach my $interval (sort keys %listP)
	{
		my $reg= keys %{$listP{$interval}};
		if ($interval eq "none")
		{
			print $handle "The candidate variant/lineage did not show an increase in prevalece greater than the threshold at any interval or locale\n\n";
			next;
		}else{
			print $handle "Interval: $interval, increase at $reg locale(s)\n";
			print $handle "\tList of locale(s):";
			foreach my $reg (sort keys %{$listP{$interval}})
			{
				my $p1=sprintf("%.2f",$listP{$interval}{$reg}[0]);
				my $t1=$listP{$interval}{$reg}[2];
				my $p2=sprintf("%.2f",$listP{$interval}{$reg}[1]);
				my $t2=$listP{$interval}{$reg}[3];
				print $handle " $reg:$p1-($t1),$p2-($t2)";
			}
			print $handle "\n\n";
		}
	}
	#print  $handle "\n";

	print $handle "Number of intervals above the prevalence threshold, by locale:\n\t";
	foreach my $reg (sort keys %intervals_above)
	{
		print $handle " $reg:$intervals_above{$reg}";
	}
	print $handle "\n";


	print $handle "\nLatest prevalence:\n";
        foreach my $reg (sort keys %latestP)	
	{
		print $handle "\t$reg $latestP{$reg}\n";
	}
	print $handle "\n";

}

sub guess_path
{
	my $reference=$_[0];
	my $file=$_[1];
	my $path="mailuu";
	if ($file eq "custom")
	{
		if (-e "metadataTMP")
                {
                 	system("rm -rf metadataTMP")==0||die("did not remove old temp file\n");
              	}
		system("mkdir metadataTMP")==0||die("no metadata directory\n");
                print "Preprocessing step, type of analysis was set to \"custom\" computing custom genomic variants file\n";
		system("perl $haploCOV/computeAF.pl --file $reference --outdir metadataTMP")==0||die("computeAF.pl exited with an error.Please see above!\n");
                $path="$haploCOV/metadataTMP/areas_list.txt";
	}
	$path="$haploCOV/alleleVariantSet/country/$file" if -e "$haploCOV/alleleVariantSet/country/$file";
        $path="$haploCOV/alleleVariantSet/HighVar/$file" if -e "$haploCOV/alleleVariantSet/HighVar/$file";
       	$path="$haploCOV/alleleVariantSet/HighFreq/$file" if -e "$haploCOV/alleleVariantSet/HighFreq/$file";
        $path="$haploCOV/$file" if -e "$haploCOV/$file";
        
	die("could not find $file in your HaploCoV installation, please make sure to have a copy of the file in the right place\n") if $path eq "mailuu";
	return ($path);
}

sub augment
{
	my $reference=$_[0];
	my $file=$_[1];
	my $path=$_[2];
	my $augmentString=$_[3];
	print "#Processing $reference $file\n";
        print " step #1 augment the nomenclature\n";
        system("perl $haploCOV/augmentClusters.pl --outfile $reference\_$file\_results.txt --metafile $reference --posFile $path $augmentString")==0||die("augmentClusters.pl exited with an error. Please see above!\n");
	return("$reference\_$file\_results.txt");
}

sub score
{
	my $infile=$_[0];
	my $linString=$_[1];
	my $reportString=$_[2];
	print " step #2 Computing variant's scores\n";
	system("perl $haploCOV/LinToFeats.pl --infile $infile --outfile $infile\_features.csv $linString")==0||die("LinToFeats.pl exited with an error. Please see above!");
	system("perl $haploCOV/report.pl --infile $infile\_features.csv --outfile $infile\_PASS.csv $reportString")==0||die("report.pl exited with an error. Please see above!"); 
	return("$infile\_PASS.csv","$infile\_features.csv");

}

sub prevalence
{
	my $input=$_[0];
	my $augment=$_[1];
	my $assignString=$_[2];
	my $increaseString=$_[3];

       print " step #3 prevalence based report \n";
       system("perl $haploCOV/p_assign.pl --dfile $augment --infile $input $assignString --outfile $input\_assigned.txt")==0||die("p_assign.pl exited with an error. Please see above!\n");
       system("perl $haploCOV/increase.pl --file $input\_assigned.txt $increaseString")==0||die("increase.pl exited with an error. Please see above!\n");
       return("$input\_assigned.txt.prev","$input\_assigned.txt");

}


sub process_locales
{
	my $localeFile=$_[0];
	my $masterFile=$_[1];
	my %out_conf=();

	print "Preprocessing: subsetting data by areas/locales\n";

	open(IN,$localeFile);
	my $header=<IN>;
	while(<IN>)
	{
		chomp();
		my ($region,$qualifier,$dateStart,$dateEnd,$alleles)=(split(/\t/));
		if ($region eq "" || $qualifier eq "" || $dateStart eq "" ||
			$dateEnd eq "" || $alleles eq "")
		{
			die("\nCould not process the following line:\n$_\nPlease check your locales file carefully.\nEach line should have exactly 5 columns.\nEmpty lines or missing values are NOT allowed.\n\n");
		}
			
		print "$region\t$qualifier\t$dateStart\t$dateEnd\n";
		my $localeWrapping="";		
		$localeWrapping="--$qualifier $region" if $region ne "world";
		system("perl $haploCOV/subset.pl $localeWrapping --startD $dateStart --endD $dateEnd --infile $masterFile --outfile $region")==0||die("subset.pl exited with an error! Please see above!\n");
	
		my $isWC= check_exists_command('wc'); 
		if ($isWC)
		{
			my $lines=`wc -l $region`;
			$lines=(split(/\s+/,$lines))[0];
			if ($lines<50)
			{
				print "$lines entries for $dateStart to $dateEnd at $region!\n";
				die ( "Execution will halt! Too few data!\nPlease make sure that you spelled your region/country/area of interest and dates correctly.\nIf so, please broaden the scope of the analysis to include at least 50 entries\n");  
			}
		}else{	
			 warn "$0 uses wc verify that input files are not empty.\nBut wc is not found in your system\nThis might cause errors!\n";

		}

		my @alleles=(split(/\,/,$alleles));
		foreach my $allele (@alleles)
		{
			push(@{$out_conf{"$region"}},$allele);
		}

	}
	return \%out_conf;
}


sub process_parameters
{
	my $file=$_[0];
	my $P="NA";
	my $W="NA";
	my %parameters=();
	my $program="";
	open(IN,$file);
	while(<IN>)
	{
		chomp();
		if ($_=~/^--/)
		{
			my ($pname,$pvalue)=(split(/\t/));
			unless ($pvalue)
			{
				die("Malformed string $_. I could not set the value for this parameter. Did you forget to specify the parameter value? are the fields separated by tab?\n");
			}
			$P=$pvalue if $pname eq "--minP";
			$W=$pvalue if $pname eq "--nInt";
			$parameters{$program}.=" $pname $pvalue";
		}else{
			next if $_=~/^#/;
			$program=$_;
			$parameters{$program}="";
		}

	}
	return(\%parameters,$P,$W);
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
			die("Reason:\nInvalid parameter $act provided\n");
                }
        }
}

sub check_input_arg_valid
{
        if ($arguments{"--file"} eq "na" ||  (! -e ($arguments{"--file"})))
        {
                print_help();
                my $f=$arguments{"--file"};
                die("Reason:\nNo valid input file provided. $f is not a valid file name, please provide one!");
        }
        if ($arguments{"--locales"} eq "na" || (! -e $arguments{"--locales"}))
        {
                print_help();
                my $m=$arguments{"--locales"};
                die("Reason:\nCould not find the \"locales\" file. $m does not exist!\n");
        }
	if (! -e ($arguments{"--param"}))
	{
		print_help();
		my $m=$arguments{"--param"};
                die("Reason:\nCould not find the \"param\" file. $m does not exist!\n");

	}
	if ($arguments{"--path"})
	{
		my $Pexec=$arguments{"--path"};
		my $warn=check_Haplocov($Pexec);
		if ($warn==0)
		{
	       		print_help();
	        	my $m=$arguments{"--path"};
	        	die("Reason:\nThe folder $m does not contain all the utilities provided by HaploCoV. Please check the --path argument. $m provided\n Please make sure that you have the following tools in $m:\n
			   1. computeAF.pl ;
			   2. augmentClusters.pl ;
			   3. LinToFeats.pl ;
			   4. report.pl ;
			   5. p_assign.pl (and assign.pl) ;
			   6. increase.pl");
		}
	}
	if ($arguments{"--varfile"} ne "a" && $arguments{"--varfile"} ne "b" && $arguments{"--varfile"} ne "n")
	{
		print_help();
		my $varfile=$arguments{"--varfile"};
		die("Reason:\n --varfile was set to: $varfile, valid values are a:any, b:both, n:none");
	}

}

sub check_Haplocov {
	my $path=$_[0];
	my $valid=1;
	$valid=0 unless -e "$path/computeAF.pl";
	$valid=0 unless -e "$path/augmentClusters.pl";
	$valid=0 unless -e "$path/LinToFeats.pl";
	$valid=0 unless -e "$path/report.pl";
	$valid=0 unless -e "$path/p_assign.pl";
	$valid=0 unless -e "$path/increase.pl";
	return ($valid);
}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
}


sub print_help
{
        print " This utility is used to:\n";
        print " Automate the execution of the complete HaploCoV workflow\n";
        print " Users need to provide:\n";
        print " 1) a \"locales\" file, where they specify the timeframe and the geographic regions to include in the\n";
	print " analyses. See the manual for more details;\n";
        print " 2) a metadata table, in HaploCoV format, as produced by addToTable.pl or NexStrainToHaploCoV.pl;\n";
        print " 3) a parameters file, to specify the parameters used by each tool in HaploCoV\n";
	print "    see \"parameters\" in the main HaploCoV repository for an example;\n";
        print " 4) the path to their installation of HaploCoV;\n";
	print " 5) (optional) specify  a \"Designations file\" with the list of novel variants identified\n"; 
	print "    by HaploCoV and their defining genomic variants should be written. See --varfile.\n\n";	
        print " For every region/area/country specified in the \"locales\" file a report will be produced (.rep file)\n";
	print " the report will include the list of candidate new lineages that increased their \"VOC-ness\" score\n";
	print " or demonstrated an increase in prevalence in the area/region/country specified by the user.\n";
	print " If --varfile is set to \"a\" or \"b\", an additional file with the complete list of the variants\n";
	print " identified by HaploCoV and their defining genomic variants (.var) file will be produced as well.\n"; 
        print " \n\nThe mandatory parameters are: --file and --locales;\n";
        print " --path, --varfile and --param are optional, and each has default values, which should work out of the box\n";
	print " Please read the manual for more details\n\n";
        print "##INPUT PARAMETERS\n\n";
        print "--file <<filename>>\t HaploCoV formatted file;\n";
        print "--locales <<filename>>\t \"locales\" file;\n";
        print "--param <<filename>>\t configuration file, defaults to \"parameters\";\n";
	print "--path <<path>>\t path to your HaploCoV installation, defaults to ./;\n";
	print "--varfile <<value>>\t n-> do not write this file;\n";
	print "                   \t b->report only variants that passed both filters (score and prevalence);\n"; 
	print "                   \t a-> report all the variants that passed any filter (score or prevalence or both)\n";
        print "\nTo run the program you MUST provide at least --file and --locales\n";
        print "both file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is metadata.tsv and locales.txt\nperl HaploCoV --file HaploCoV.tsv --locales locales.txt\n\n";
        print "2# output files, one per locale, will have the .rep extension\n";
	print "3# designation files (--varfile, optional) will have a .var extension\n";
}

