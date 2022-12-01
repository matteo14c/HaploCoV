use strict;

############################################################
# Arguments
#
my %arguments=
(
"--metafile"=>"na",          # max time
"--posFile"=>"na",
"--dist"=>2,
"--suffix"=>"N",
"--size"=>100,
"--tmpdir"=>"novelGs",
"--deffile"=>"linDefMu",
"--outfile"=>"na"
);
#
##############################################################
# Process input arguments and check if valid
check_arguments();
check_input_arg_valid();
#
#

#############################################################
# Get arguments
#
my $metafile=$arguments{"--metafile"};
my $posFile=$arguments{"--posFile"};
my $dist=$arguments{"--dist"};
my $prefix=$arguments{"--suffix"};
my $size=$arguments{"--size"};
my $outdir=$arguments{"--tmpdir"};
my $outfile=$arguments{"--outfile"};
my $deffile=$arguments{"--deffile"};

check_exists_command('mkdir') or die "$0 requires mkdir to create a temporary directory\n";

unless (-e $outdir)
{
        system ("mkdir $outdir")==0||die();
}


my ($Hpos,$LPos)=build_L_pos($posFile);
my ($data,$have)=compress_groups($metafile,$Hpos,$outdir,$deffile);
allocate_groups($data,$have,$dist,$size,$outdir,$prefix,$outfile);


######################################################################
# Subs
#

sub compute_dist
{
        my %HG=%{$_[0]};
        my %printed=%{$_[1]};
        my $dist=100;
        foreach my $hg (keys %printed)
        {
                my $Ldist=0;
		foreach my $allele (keys %{$printed{$hg}})
		{
		        $Ldist++ unless $HG{$allele};
		}
                foreach my $allele (keys %HG)
                {
                        $Ldist++ unless $printed{$hg}{$allele}
                }
                $dist=$Ldist if $Ldist<$dist;
        }
        return $dist;
}

sub compress_groups
{
	my $file=$_[0];
	my %HFpos=%{$_[1]};
	my $outdir=$_[2];
	my $deffile=$_[3];
	open(IN,$file);
	
	my %Dlin=();

	if ($deffile ne "na")
	{
		%Dlin=%{read_def($deffile)}; 
	}else{
		%Dlin=%{build_def($file)}
	}

	# 2 identify genomes with common patterns of HF variants within a lineage
	# and store them
	#
	#print " #2\n";
	open(IN,$file);
	my %candNew=();
	my %listVarNew=();
	while(<IN>)
	{
		chomp();
		my ($lin,$var)=(split(/\t/))[9,10];
		next if $lin eq "";
                next if $lin eq "Unassigned";
                next if $lin eq "NA";

		my @vars=sort(split(/\,/,$var));
		my $genomeString="";
		my $Nvar=0;
		foreach my $vr (@vars)
		{

			#commentato xché: cosa succede invece se mancano varianti?
			#next if $Dlin{$lin}{$vr};
			next unless $HFpos{$vr} || $Dlin{$lin}{$vr};
			$genomeString.="$vr ";
			$listVarNew{$lin}{$vr}++;
			$Nvar++;
		}
		chop($genomeString);
		$candNew{$lin}{$genomeString}++ if $Nvar>=$dist;
	}
=pod
	#print " #3\n";
	# write out lineage specific files 
	foreach my $lin (keys %candNew)
	{
		next if $lin eq "";
		next if $lin eq "Unassigned";
		next if $lin eq "NA";
		print "compressing $lin\n";
		my @Gss= sort { $candNew{$lin}->{$b} <=> $candNew{$lin}->{$a}} keys(%{$candNew{$lin}});
		open(OUT,">./$outdir/$lin\_compressed.csv");
		my @HFs= sort keys %{$listVarNew{$lin}};
		print OUT " @HFs tot\n";
		my $N=0;
		foreach my $G (@Gss)
		{
			my $num=$candNew{$lin}{$G};
			next unless $num>10 || $num/$Clin{$lin}*100>1;
			$N++;
			print OUT "ID$N";
			my @mutsG=(split(/\s+/,$G));
			my %haveM=();
			foreach my $m (@mutsG)
			{
				$haveM{$m}=1;
			}
			foreach my $h (@HFs)
                        {
                        	my $val=$haveM{$h} ? $haveM{$h} : 0;
                                print OUT " $val";
                       	}
                        print OUT  " $num\n";
		}	
		close(OUT);
	}
=cut
	return(\%candNew,\%Dlin)
}

sub build_def
{
	my $file=$_[0];
	my %Dlin=();
	my %Clin=();
	open(IN,$file);
	while(<IN>)
        {
                chomp();
                my ($lin,$var)=(split(/\t/))[9,10];
                next if $lin eq "";
                next if $lin eq "Unassigned";
                next if $lin eq "NA";

                $Clin{$lin}++;
                my @vars=(split(/\,/,$var));
                foreach my $vr (@vars)
                {
                        $Dlin{$lin}{$vr}++;
                }
        }
        foreach my $lin (sort{$a<=>$b} keys %Dlin)
        {
                my $tot=$Clin{$lin};
                foreach my $var (keys %{$Dlin{$lin}})
                {
                        my $prev=$Dlin{$lin}{$var}/$tot;
                        delete $Dlin{$lin}{$var} if $prev<0.5;
                }
        }
	return (\%Dlin);
}

sub read_def
{
	my $file=$_[0];
	open(IN,$file);
	my %Dlin=();
	open(IN,$file);
	while(<IN>)
	{
		chomp();
		my ($lin,@lmut)=(split());
		foreach my $var (@lmut)
		{
			$Dlin{$lin}{$var}=1;
		}
	}
	return(\%Dlin);
}

sub allocate_groups
{
	my %data=%{$_[0]};
	my %have=%{$_[1]};
        my $dist=$_[2];
        my $minsize=$_[3];
        my $outdir=$_[4];
	my $prefix=$_[5];
	my $varFile=$_[6];
	#my %Clin=%{$_[7]};

	open(OUT,">$outdir/$varFile.log");
	open(MAIN,">$varFile");
	my @Gs=keys %data;
	#print "	#3\n";
	foreach my $G (@Gs)
	{
		next if $G eq "";
                next if $G eq "Unassigned";
                next if $G eq "NA";
		
		#print "$G\n";

		my %printedHG=();
		# 1 Fore every lineage
		# take candidate sublineages
		my @subGs= sort { $data{$G}->{$b} <=> $data{$G}->{$a}} keys(%{$data{$G}});
		# 2 build list of characteristic mutations
		my @HGpos=keys %{$have{$G}};
		my %HGdata=();
		my %HGprint=();
                foreach my $v (@HGpos)
                {
                	my ($pos,$allele)=(split(/\_/,$v))[0,1];
                	$HGdata{$pos}=$v;
			$HGprint{$v}=1;
                	$printedHG{$G}{$v}=1;
               	}
		
		# move up to print also all the HGs, or delete: so you simply "merge"
		# now delete
		print MAIN "$G";
		foreach my $pos (sort{$a<=>$b} keys %HGdata)
		{
			print MAIN " $HGdata{$pos}";
		}
		print MAIN "\n";

		# set start id and a empty list of lineages already printed
		my $start=1;
        	
		print OUT "$G\n";
		my $id=0;
        	foreach my $sub (@subGs)
		{
			my $id++;
                	my $tot=$data{$G}{$sub};

			next unless $tot>=$size; #|| ($tot/$totG>=0.01 && $tot>$size/2);

			# novel group: defined by HG muts
			# not necessarily
			my %localHG=();#%HGdata;
			my %localPrint=();#%HGprint;
			
			my @add=split(/\s+/,$sub);
			# add group specific muts
			my $count=@add;
			foreach my $add (@add)
			{
				my ($pos,$allele)=(split(/\_/,$add))[0,1];
				$localHG{$pos}=$add;
				$localPrint{$add}=1;

			}

			# if phenetic with all the other groups >= dist. keep
                	my $HGdist=compute_dist(\%localPrint,\%printedHG);
                	if ($HGdist>=$dist)
                	{
                        	print OUT "ID$id $count $HGdist $tot > $start\n";
                        	print OUT "$G.$prefix$start";
                        	print MAIN "$G.$prefix$start";
                        	foreach my $pos (sort{$a<=>$b} keys %localHG)
                        	{
                                	print OUT " $localHG{$pos}";
                                	print MAIN " $localHG{$pos}";
                                	$printedHG{$start}{$localHG{$pos}}=1;
                        	}
                        	print OUT "\n";
                        	print MAIN "\n";
                       	 	$start++;
                	}
        	}
	}
	
}

sub build_L_pos
{
	my $pos_file=$_[0];
	open(IN,$pos_file);
	my %HFpos=();
	my @HFpos=();
	while(<IN>)
	{
        	my $pos=(split())[0];
        	$HFpos{$pos}=1;
        	push(@HFpos,$pos);
	}
	close(IN);
	return(\%HFpos,\@HFpos);
}


######################################################################
# Functions for input control and help
#
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
	if ($arguments{"--metafile"} eq "na" ||  (! -e ($arguments{"--metafile"})))
        {
                print_help();
                my $f=$arguments{"--metafile"};
                die("Reason\:\nInvalid metadata file provided. $f does not exist!");
        }
	if ($arguments{"--posFile"} eq "na" ||  (! -e ($arguments{"--posFile"})))
        {
                print_help();
                my $f=$arguments{"--posFile"};
                die("Reason:\nInvalid list of positions file provided. $f does not exist!");
        }

        if ($arguments{"--dist"}<0)
        {
                print_help();
                my $m=$arguments{"--dist"};
                die("Reason:\nDistance between groups can not be <0. $m provided\n");
        }
	
	if ($arguments{"--size"}<0)
        {
                print_help();
                my $m=$arguments{"--size"};
                die("Reason:\nGroups size can not be <0. $m provided\n");
        }
	if ($arguments{"--outfile"} eq "na")
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Reason:\nInvalid outfile name provided. $f please provide a valide name using --outfile");
        }
	if ($arguments{"--deffile"} ne "na" && (! -e $arguments{"--deffile"} ))
	{
		print_help();
		my $f=$arguments{"--deffile"};
		die("Reason:\nInvalid lineage defining mutations file provided. $f does not exitst\n");
	}

}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
}


sub print_help
{
        print " This utility is used to derive novel sub-groups/sub lineages of SARS-CoV-2\n"; 
	print " within an existing classification\n"; 
	print " Users need to provide:\n\n"; 
	print " 1) --metafile a metadata file containing a table with the list of genetic\n"; 
	print " variants and the class/lineaged assigned to each genoneme (addToTable.pl);\n";
	print " 2) --posFile a list of high frequency genetic variants (see computeAF.pl and\n";
	print " or collections of allele-sets available from the github repo)\n\n";
	print " The tool identifies all possible sub-groups/lineages within any extant group/lineage\n";
	print " according to parameters set by the user.\n";
	print " Criteria for the definition of novel groups/subgroups are specified by:\n";
	print "	--dist minimum phenetic distance to an extant group (default 2)\n";  
	print " and --size: minimum number of distinct genomes in the group (default 100).\n";
	print " Only novel groups with a at least --dist or more additional characteristic\n"; 
	print " genetic variants, and larger than --size are reported in the final output.\n"; 
	print " The final output itself consist in a simple text file, where every line\n";
	print " reports the name of a lineage/class, and the list of characteristic allele\n";
	print " variants of that lineage\n";
	print " Newly formed lineages/classes are idenfitified by specified by --prefix.\n\n";
        print "##INPUT PARAMETERS\n\n";
	print "--metafile <<filenane>>\t metadata file\n";
        print "--posFile <<filename>>\t allele variant file: list of high frequency variants (by computeAF.pl)\n";
	print "--dist <<integer>>\t defaults to 2 minimum edit distance to create a subgroup within a lineage\n";
        print "--suffix <<character>>\t suffix for new lineages,defaults to N\n";
        print "--size <<integer>>\t minimum size for a new subgroup within a lineage, defaults to 100\n";
        print "--tmpdir <<dirname>>\t defaults to \"./novelGs\", output directory\n";
	print "--deffile <<filename>>\t defaults to \"./linDefMut\", file with lineage defining mutations\n";
        print "--outfile <<filename>>\t name of the output file\n";
	print "\n To run the program you MUST provide  --metafile, --outfile and --posFile\n";
        print " all the file needs to be in the folder from which the script is executed.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# perl augmentClusters.pl --outfile lvar.txt --metafile HaploCoV_formattedMetadata --posFile areas_list.txt \n\n";
}

