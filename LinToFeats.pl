use strict;

############################################################
# Arguments
#
my %arguments=
(
"--infile"=>"na",         # name of the input file
"--corgat"=>"./corgat",
"--outfile"=>"na",          # max time
);

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

my @genes=qw(orf1ab spike geneE geneM geneN metaORF);
my @quals=qw(numEpi numIncr numDecr numS numNS numDam  numINF numPos numNeg numDom numTotal);

open(IN,$linfile);
print OUT "lineage\tnum\tTRS\tCLV\tAF90\tAF50\tAF25\tAF10\tGLN\ttotal\tnumS\tnumNS\tnumD\tnumIF\tnumGlobal\tEpiGlobal\tnumEpiG";

foreach my $g (@genes)
{
	foreach my $q (@quals)
	{
		print OUT "\t$g:$q";
	}
}
print OUT "\n";


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
	$total=@muts;
	my $numlin=$#muts+1;
	#($lin,$numlin)=(split(/\:/,$lin))[0,1];
	my $randTempName=sprintf "%08X", rand(0xffffffff);
	open(OUT,">$randTempName.txt");
	foreach my $mut (@muts)
	{
		print OUT "$mut\n";
	}
	system("perl $corgat\annotate.pl --in $randTempName.txt --out $randTempName.CorGAT_out.tsv")==0||die("no annotation");
	my $annotFile="$corgat$randTempName.CorGAT_out.tsv";
	open(ON,$annotFile);
	my $header=<ON>;
	while(<ON>)
	{
		my $addEpi=0;
		$numCLV++ if $_=~/clv/;
		$numTRS++ if $_=~/TRS/;	
		$GLN++ if $_=~/Glycosylation/;
		my $affectedGene="NA";
		my $predictedeffect="NA";

		my ($pos,$ref,$alt,$annot,$af,$epi,$hyphy,$mfei,$increase,$decrease,$prevalence,$uniprot)=(split(/\t/));
		
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
	system("rm $corgat$randTempName*")==0||die("no rm\n");
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
        unless (-e $arguments{"--corgat"}."annotate.pl" )
        {
                print_help();
                my $m=$arguments{"--corgat"};
                die("can not find annotate.pl in your CorGAT installation\nPlease check your installation of CorGAT\n")
        }
}

sub print_help
{
        print " This utility is used to derive genomic annotations and high level features from sub-groups/sub lineages of SARS-COV-2\n";
        print " Users need to provide 1) --corgat a directory where corgat is installed (please see https://github.com/matteo14c/corgat)\n ";
	print " for detailed instructions of how to install corgat. 2) --infile an input file, in simple text format with the list of\n";
	print " nucleotide variants characteristic of each lineage/sublineage. Such file can be obtained by running augmentClusters.pl\n";
	print " or deriveAlleles.pl. Please read the manual for how to run/use these tools\n 3) a valid output file name\n";
        print " groups/lineages in the nomenclature and 4) --posFile a list of high frequency alleles (see computeAF.pl)\n";
        print " For every group/lineage the script computes the functional annotation of the variants and a table with genomic features\n";
        print " A complete description of the features can be found in the features.csv file attached to this github repo\n";
        print " The final output consist in a simple text file, in tsv format. This file can be provided as the input of\n";
        print " score.pl to identify \"high scoring\" variants that are likely to be interesting from an epidemiological perspective\n";
        print " Please see Chiara et al 2022 (under review) for more details\n";
        print "##INPUT PARAMETERS\n\n";
        print "--infile <<filename>>\t file with lineages/groups characteristic allele variants. 1 lineage per line\n";
        print "--outfile <<filenane>>\t name of the output file\n";
        print "--corgat <<directory>>\t path to corgat. defaults to \"./corgat\"\n";
        print "\nTo run the program you MUST provide at least --infile and --outilfe\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# input is lvar.txt output is score.csv:\nperl compute.pl --infile lvar.txt --outfile scores.csv \n\n";
}

