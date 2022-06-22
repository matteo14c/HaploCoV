use strict;

############################################################
# Arguments
#
my %arguments=
(
"--infile"=>"na",         # name of the input file
"--corgat"=>"./",
"--annotfile"=>"globalAnnot",
"--outfile"=>"na"          # max time
);
###########################################################
# download required files

download_annot();



############################################################
# Process input arguments and check if valid
#
check_arguments();
check_input_arg_valid();

#############################################################
# Get arguments
#
my $linfile=$arguments{"--infile"};
my $outfile=$arguments{"--outfile"};
my $corgat=$arguments{"--corgat"};
my $annotfile=$arguments{"--annotfile"};

my %annot_index=();

#############################################################
#

if (-e $annotfile)
{
	%annot_index=%{index_annot($annotfile)};
}

print_scores($linfile,$outfile,$corgat,$annotfile);


############################################################
#
# input processing
#

sub index_annot
{
	my $annotfile=$_[0];
	open(A,$annotfile);
	my %index=();
	my $header=<A>;
	while(<A>)
	{
		chomp();
		my @vls=(split(/\t/));
		my $key="$vls[0]\_$vls[1]\|$vls[2]";
		my $string=join("\t",@vls);
		$index{$key}=$string;
	}
	return (\%index);

}

sub read_annot
{
	my @lvars=@{$_[0]};
	my @annots=();
	foreach my $v (@lvars)
	{
		my $annot=$annot_index{$v};
		push(@annots,$annot);
	}
	return(\@annots)
}

sub compute_annot
{
        my @muts=@{$_[0]};
        my $corgat=$_[1];
        my $randTempName=sprintf "%08X", rand(0xffffffff);
        open(TOUT,">$randTempName.txt");
        foreach my $mut (@muts)
        {
                print TOUT "$mut\n";
        }
        system("perl $corgat\annotate.pl --in $randTempName.txt --out $randTempName.CorGAT_out.tsv")==0||die("no annotation");
        my $annotFile="$corgat$randTempName.CorGAT_out.tsv";
        open(ON,$annotFile);
        my @annots=();
        while(<ON>)
        {
                chomp;
                push(@annots,$_);
        }
	close(ON);
        return(\@annots);

}


sub print_scores
{
	my $linfile=$_[0];
	my $outfile=$_[1];
	my $corgat=$_[2];
	my $annotfile=$_[3];

	my @genes=qw(orf1ab spike geneE geneM geneN metaORF);
	my @quals=qw(numEpi numIncr numDecr numS numNS numDam  numINF numPos numNeg numDom numTotal);

	open(OUT,">$outfile");
	print OUT "lineage\tnum\tTRS\tCLV\tAF90\tAF50\tAF25\tAF10\tGLN\ttotal\tnumS\tnumNS\tnumD\tnumIF\tnumGlobal\tEpiGlobal\tnumEpiG";

	foreach my $g (@genes)
	{
		foreach my $q (@quals)
		{
			print OUT "\t$g:$q";
		}
	}
	print OUT "\n";

	open(IN,$linfile);


	while(<IN>)
	{
		my %annot=();
		foreach my $gene (@genes)
		{
			my @values=(0,0,0,0,0,0,0,0,0,0,0);
			$annot{$gene}=\@values;
		}
		my $GLN=0;
		my $numTRS=0;
		my $numCLV=0;
		my $AF90=0;
		my $AF50=0;
		my $AF25=0;
		my $AF10=0;
		my $total=0;
		my $S=0;
		my $N=0;
		my $D=0;
		my $F=0;
		my $numG=0;
		my $epiG=0;
		my $numEpi=0;
		my ($lin,@muts)=(split());
		my @AN=();
		if (-e $annotfile)
		{
			@AN=@{read_annot(\@muts)};
		}else{
			@AN=@{compute_annot(\@muts)};
		}
		
		$total=@muts;
		my $numlin=$#muts+1;
	
		foreach my $line (@AN)
		{
			#print "$line\n";
			my $addEpi=0;
			$numCLV++ if $line=~/clv/;
			$numTRS++ if $line=~/TRS/;	
			$GLN++ if $line=~/Glycosylation/;
			my $affectedGene="NA";
			my $predictedeffect="NA";

			my ($pos,$ref,$alt,$annot,$af,$epi,$hyphy,$mfei,$increase,$decrease,$prevalence,$uniprot)=(split(/\t/,$line));
		
			my @annots=(split/\;/,$annot);
			$numG++ if $af>=90;
			next if $af>=90;
			my $gene="";
			foreach my $annot (@annots)
			{
				$gene=(split(/\:/,$annot))[0];
				next if $gene =~/nsp/;
				next if $gene eq "orf1a";
				$gene="metaORF" if $gene ne "orf1ab" && $gene=~/orf/;
				if ($annot=~/missense/ )
				{
					$affectedGene=$gene;
					$annot{"$gene"}[4]++;
					$annot{"$gene"}[10]++;
					$N++;
					$addEpi=1;
					last;
				}elsif ($annot=~/synonymous/){
					$affectedGene=$gene;
					$annot{"$gene"}[3]++;
					$annot{"$gene"}[10]++;
					$S++;
                        		last;
				}elsif ($annot=~/stop/ || $annot=~/frameshift/){
					$affectedGene=$gene;
					$annot{"$gene"}[5]++;
					$annot{"$gene"}[10]++;
					$D++;
					$addEpi=1;
                        		last;
				}elsif ($annot=~/inframe/){
					$affectedGene=$gene;
                                	$annot{"$gene"}[6]++;	
					$annot{"$gene"}[10]++;
					$F++;
					#print "$F $annot\n";
					$addEpi=1;
                                	last;
				}	
			}
			$epiG+=$epi if $addEpi==1;
			$numEpi++ if $addEpi==1;
			$annot{$gene}[0]+=$epi if $addEpi==1 && $gene ne "";
			my @increases=(split(/\;/,$increase));
			my @decreases=(split(/\;/,$decrease));
			foreach my $i (@increases)
			{
				my $v=(split(/\:/,$i))[1];
				$annot{"$gene"}[1]+=$v;
			}
			foreach my $d (@decreases)
			{
				my $v=(split(/\:/,$d))[1];
                        	$annot{"$gene"}[2]+=$v;

			}
			if ($hyphy=~/positive/)
			{
				 $annot{"$gene"}[7]++;
			}elsif($hyphy=~/negative/){
				$annot{"$gene"}[8]++;
			}
			if ($uniprot=~/domain/){
				$annot{"$gene"}[9]++;
			}
			my @prevalences=(split(/;/,$prevalence));
			foreach my $p (@prevalences)
			{ 
				my $v=(split(/\:/,$p))[2];
				my @AF=(split(/\-/,$v));
				@AF=sort{$a<=>$b} @AF;
				my $fa=$AF[1];
				if ($fa>=90)
				{
					$AF90++;
				}elsif ($fa<90 && $fa>=50){
					$AF50++;
				}elsif ($fa<50 && $fa>=25){
					$AF25++;
				}elsif ($fa<25 && $fa>=10){
					$AF10++;
				}
			}	

		}
		if (($total-$numG)>0)
		{
			$AF90=$AF90/($total-$numG);
			$AF50=$AF50/($total-$numG);
			$AF25=$AF25/($total-$numG);
			$AF10=$AF10/($total-$numG);
		}
		if ($numEpi>0)
		{
			$epiG=$epiG/$numEpi;
		}
		print OUT "$lin\t$numlin\t$numTRS\t$numCLV\t$AF90\t$AF50\t$AF25\t$AF10\t$GLN\t$total\t$S\t$N\t$D\t$F\t$numG\t$epiG\t$numEpi";
		foreach my $g (@genes)
		{
			my @vals=@{$annot{$g}};
			for (my $j=1;$j<=2;$j++)
			{
				$vals[$j]=($vals[$j])/($vals[$#vals]) if $vals[$#vals]!=0;
			}
			$vals[0]=$vals[0] / ($vals[4]+$vals[5]+$vals[6]) if ($vals[4]+$vals[5]+$vals[6])>0; 
			my $string=join("\t",@vals);
			print OUT "\t$string";
		}	 
		print OUT "\n";
	}
	close(OUT);
}

sub download_annot
{
	if (-e "globalAnnot")
	{
		system("rm globalAnnot")==0||die("could not remove old annotation files\n");
	}
	if (-e "globalAnnot.gz")
	{
		system("rm globalAnnot.gz")==0||die("could not remove old annotation files\n");
	}
        print "Will now dowload CorGAT annotation of SARS-CoV-2 variants, from Github\n";
        print "Please download this file manually, if this fails\n";
        check_exists_command('wget') or die "$0 requires wget to download the genome\nHit <<which wget>> on the terminal to check if you have wget\n";
        check_exists_command('gunzip') or die "$0 requires gunzip to unzip the genome\n";
        system("wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/globalAnnot.gz")==0||die("Could not retrieve the reference annotation used by HaploCov\n");
        system("gunzip globalAnnot.gz")==0 ||die("Could not unzip globalAnnot");

}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
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


sub check_input_arg_valid
{
        if ($arguments{"--infile"} eq "na" ||  (! -e ($arguments{"--infile"})))
        {
                print_help();
                my $f=$arguments{"--infile"};
                die("Invalid variants file provided. $f does not exist!");
        }
        if ($arguments{"--outfile"} eq "na")
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Invalid outfile name provided. $f please provide a valide name using --outfile");
        }
        if ( !(-e $arguments{"--corgat"}."annotate.pl") && !(-e $arguments{"--annotfile"})  )
        {
                print_help();
                my $m=$arguments{"--corgat"};
		my $k==$arguments{"--annotfile"};
                die("Can not find annotate.pl in your CorGAT installation at $corgat and your --annotfile $k does not exist\nThis means that variant annotation can not be performed\nPlease read the manual\n");
        }
}

sub print_help
{
        print " This utility is used to derive genomic annotations and high level\n";
       	print " features from sub-groups/sub lineages of SARS-COV-2;\n";
	print " Users need to provide:\n\n";
        print " 1) --infile an input file, in simple text format with the list of\n";  
	print " nucleotide variants characteristic of each lineage/sublineage.\n"; 
	print " Such file can be obtained by running augmentClusters.pl \n"; 
	print " 2) a file with precomputed CorGAT annotations of SARS-CoV-2 variants\n"; 
	print " (--annotfile). Such file is provided in the main github repo of HaploCoV\n";
       	print " (see globalAnnoT). This file is updated on a weekly basis\n";
	print " OR, ALTERNATIVELY, --corgat 3) a path to a local installation of CorGAT.\n"; 
	print " Please be aware that if --annotfile is not provided, annotations will\n";
	print " will be derived by running CorGAT on every lineage. Execution\n";
	print " times will be increased by a 10 fold at least!!!\n"; 
	print " IMPORTANT: If your installation of CorGAT is not valid and --annotfile\n";
	print " does not exist, the tool will halt and raise an error message\n";
        print " 4) a valid output file name --outfile\n\n";
        print " The script will compute functional annotation of the all the genetic\n"; 
	print " variants characteristic of every lineage and return a table with genomic\n";
	print " features. A complete description of the features can be found in the\n"; 
	print " \"features.csv\" file included in this github repo\n\n";
        print " The final output consist in a simple text file, in tsv format.\n"; 
	print " This file can be provided to report.pl to identify \"high scoring\" variants\n";
	print " that are likely to be interesting from an epidemiological perspective\n";
        print " Please see Chiara et al 2022 (under review) for more details\n\n";
        print "##INPUT PARAMETERS\n\n";
        print "--infile <<filename>>\t file with lineages/groups defining allele variants\n";
        print "--outfile <<filenane>>\t name of the output file\n";
        print "--corgat <<directory>>\t path to corgat. defaults to \"./corgat\"\n";
	print "--annotfile <<filename>>\t file with precomputed annotations. See globalAnnot\n";
        print "\nTo run the program you MUST provide --infile, --outilfe and at least one of either --corgat or --annotfile\n";
        print "all file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is lvar.txt output is score.csv:\nperl LinToFeats.pl --infile lvar.txt --annotfile globalAnnot --outfile scores.csv \n\n";
}

