use strict;

############################################################
# Arguments
#
my %arguments=
(
"--metafile"=>"na",          # max time
"--posFile"=>"na",
"--alndir"=>"./snps",          # min time
"--dist"=>2,
"--suffix"=>"N",
"--size"=>100,
"--tmpdir"=>"novelGsVNVs",
"--outfile"=>"lvar.txt"
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
my $alndir=$arguments{"--alndir"};
my $dist=$arguments{"--dist"};
my $prefix=$arguments{"--suffix"};
my $size=$arguments{"--size"};
my $outdir=$arguments{"--tmpdir"};
my $outfile=$arguments{"--outfile"};



check_exists_command('mkdir') or die "$0 requires mkdir to create a temporary directory\n";

unless (-e $outdir)
{
        system ("mkdir $outdir")==0||die();
}


my ($data,$have)=metadataToLists($metafile,$alndir);
my ($Hpos,$LPos)=build_L_pos($posFile);
compress_groups($data,$Hpos,$have,$outdir);
allocate_groups($data,$have,$dist,$size,$outdir,$prefix,$outfile);


######################################################################
# Subs
#

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

sub metadataToLists
{
        my $metadataFile=$_[0];
	my $alndir=$_[1];
        open(IN,$metadataFile);
        my $header=<IN>;
        my @vl=(split(/\t/,$header));
        my %keep=();
        my %lock=%{metadataToPos()};
        my %data=();
        for (my $i=0;$i<=$#vl;$i++)
        {
                my $v=$vl[$i];
                $lock{$v}=$i if ($lock{$v});
        }
        my $Iv=$lock{"Virus name"};
        my $Ir=$lock{"Location"};       
        my $Id=$lock{"Collection date"};
        my $Ip=$lock{"Pango lineage"};
        
        while (<IN>)
        {
                chomp();
                my @data=(split(/\t/));
                my $id=$data[$Iv];
                my $d=$data[$Id];
                my $p=$data[$Ip];
                my $location=$data[$Ir];
                $id=fix_strain($id);
                my $genome="./$alndir/$id\_form.txt";
                push(@{$data{$p}},$genome);
        }
	my %have=();
	foreach my $group (sort {$a<=>$b} keys %data)
	{
        
        	my @genomes=@{$data{$group}};
        	my $M=@genomes;
        	my %variants=%{genomes_To_variants(\@genomes)};
        	foreach my $pos (keys %variants)
        	{
                	my $value=$variants{$pos}/$M*100;
                	$have{$group}{$pos}=1 if $value>50;
        	}
	}	

        return(\%data,\%have);
}

sub genomes_To_variants
{
        my @Lg=@{$_[0]};
        my %dat_final=();
        foreach my $g (@Lg)
        {
                
                open(GG,$g);
                while(<IN>)
                {
                        chomp();
                        $dat_final{$_}++;
                }
        }
        return \%dat_final;
}

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
                if ($Ldist<2)
                {
                        my $string=join(" ", keys %HG);
                }
        }
        return $dist;
}

sub compress_groups
{
	my %data=%{$_[0]};
	my %HFpos=%{$_[1]};
	my %have=%{$_[2]};
	my $outdir=$_[3];
	foreach my $group (sort {$a<=>$b} keys %data)
	{
		my %sizes=();
        	my @files=@{$data{$group}};
        	my $n=@files;
        	my %sizes=();
        	my %dat_final=();
        	my @HFgroup=();
        	foreach my $pos (keys %HFpos)
        	{
                	next if $have{$group}{$pos};
                	push(@HFgroup,$pos);
        	}
        	foreach my $f (@files)
        	{
                	open(IN,$f);
                	my $genome_string="";
                	my $size=0;
                	while(<IN>)
                	{
                        	chomp();
                        	next unless $HFpos{$_};
                        	next if $have{$group}{$_};
                        	$genome_string.="$_ ";
                        	$size++;
                	}
                	chop ($genome_string);
                	$genome_string="none" if $genome_string eq "";
                	$size=1 if $size==0;
                	$sizes{$size}{$genome_string}++;
        	}
        	open(OUT,">./$outdir/$group\_compressed.csv");
        	my $count=0;
        	print OUT " @HFgroup\n";
        	foreach my $size (sort{$a<=>$b} keys %sizes)
        	{

                	foreach my $gs (keys %{$sizes{$size}})
                	{
                        	my $num=$sizes{$size}{$gs};
                        	next unless $num>15 || $num/$n*100>1;
                        	$count++;
                        	my @mutsG=(split(/\s+/,$gs));
                        	my %haveM=();
                        	foreach my $m (@mutsG)
                        	{
                                	$haveM{$m}=1;
                        	}
                        	print OUT "ID$count";
                        	foreach my $h (@HFgroup)
                        	{
                                	my $val=$haveM{$h} ? $haveM{$h} : 0;
                                	print OUT " $val";
                        	}
                        	print OUT  " $num\n";
                	}
    		}
		close(OUT);
	}
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
	open(OUT,">$outdir/$varFile.log");
	open(MAIN,">$varFile");
	my @Gs=keys %data;
	foreach my $G (@Gs)
	{
        	my $start=1;
        	my %printedHG=();
        	my $infile="./$outdir/$G\_compressed.csv";
        	next unless -e $infile;
        	my $totG=@{$data{$G}};
        	print OUT "$infile\n";
        	open(IN,$infile);
        	my $header=<IN>;
        	my @VARS=split(/\s+/,$header);
        	shift(@VARS);
        	print OUT "$G\t$#VARS\n";
        	while(<IN>)
        	{
                	my @HGpos=keys %{$have{$G}};
                	my %HGdata=();
                	foreach my $v (@HGpos)
                	{
                        	my ($pos,$allele)=(split(/\_/,$v))[0,1];
                        	$HGdata{$pos}=$v;
                        	$printedHG{$G}{$v}=1;
                	}
                	my ($id,@list)=(split());
                	my $tot=pop(@list);
			next unless $tot>=$size || ($tot/$totG>=0.05 && $tot>$size/2);
                	my $count=0;
                	for ( my $i=0;$i<=$#list;$i++)
                	{
                        	if ($list[$i]==1)
                        	{
                                	$count++;
                                	my $var=$VARS[$i];
                                	warn("$G $i $#VARS $#list something is wrong\n") unless $VARS[$i];
                                	my ($pos,$allele)=(split(/\_/,$var))[0,1];
                                	$HGdata{$pos}=$var;
                        	}
                	}
                	my %Haplo=();
                	foreach my $pos (sort{$a<=>$b} keys %HGdata)
                	{
                        	$Haplo{$HGdata{$pos}}=1;
                	}
                	my $dist=compute_dist(\%Haplo,\%printedHG);

                	if ($count>=2 && $dist>=2)
                	{
                        	print OUT "$id $count $dist $tot > $start\n";
                        	print OUT "$G.$prefix$start";
                        	print MAIN "$G.$prefix$start";
                        	foreach my $pos (sort{$a<=>$b} keys %HGdata)
                        	{
                                	print OUT " $HGdata{$pos}";
                                	print MAIN " $HGdata{$pos}";
                                	$printedHG{$start}{$HGdata{$pos}}=1;
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
                die("Invalid metadata file provided. $f does not exist!");
        }
	if ($arguments{"--posfile"} eq "na" ||  (! -e ($arguments{"--posfile"})))
        {
                print_help();
                my $f=$arguments{"--posfile"};
                die("Invalid list of positions file provided. $f does not exist!");
        }
	unless (-e $arguments{"--alndir"})
        {
                print_help();
                my $m=$arguments{"--alndir"};
                die("$m does not exist\nPlease provide a valid input directory\n")
        }

        if ($arguments{"--dist"}<0)
        {
                print_help();
                my $m=$arguments{"--dist"};
                die("Distance between groups can not be <0. $m provided\n");
        }
	
	if ($arguments{"--size"}<0)
        {
                print_help();
                my $m=$arguments{"--size"};
                die("Groups size can not be <0. $m provided\n");
        }
	if ($arguments{"--outfile"} eq "na")
        {
                print_help();
                my $f=$arguments{"--outfile"};
                die("Invalid outfile name provided. $f please provide a valide name using --outfile");
        }

}

sub check_exists_command {
    my $check = `sh -c 'command -v $_[0]'`;
    return $check;
}


sub print_help
{
        print " This utility is used to derive novel sub-groups/sub lineages within an existing classification\n"; 
	print " Users need to provide 1) --alndir a folder were allele data files are stored (see align.pl); 2) --metafile a\n ";
	print " table with the classification assigned to every genome (i.e if you are familiar with gistaid this\n";
	print " is the metadata.tsv file. 3) --varFile a simple text file with the list of allele variants that are characteristic of\n";
	print " groups/lineages in the nomenclature and 4) --posFile a list of high frequency alleles (see computeAF.pl)\n";
	print " For every group/lineage the script identifies all possible sub-groups/lineages.\n";
	print " Only subgroups with a minimun edit distance of --dist and a minimum size of --size are reported in the final\n";
	print " output. Default values are 2 for --dist and 100 for --size.\n";
	print " The final output consist in a simple text file, in the same format as --varFile. Newly created groups will\n";
	print " have in their name a prefix, which is specified by the option --prefixi. \n";
	print " Intermediate files with phenetic matrices between subgroups and log files are stored in a separate folder\n";
	print " specified by the --tmpdir parameter\n";
        print "##INPUT PARAMETERS\n\n";
	print "--metafile <<filenane>>\t metadata file\n";
        print "--posFile <<filename>>\t allele variant file: list of high frequency variants (by computeAF.pl)\n";
        print "--alndir <<dirname>>\t defaults to \"./snps\", directory where single allele variant files are stored\n";
	print "--dist <<integer>>\t defaults to 2 minimum edit distance to create a subgroup within a lineage\n";
        print "--suffix <<character>>\t suffix for new lineages,defaults to N\n";
        print "--size <<integer>>\t minimum size for a new subgroup within a lineage, defaults to 100\n";
        print "--tmpdir <<dirname>>\t defaults to \"./metadata\", output directory\n";
        print "--outfile <<filenane>>\t name of the output file\n";
	print "\nTo run the program you MUST provide at least --metafile and --posFile\n";
        print "the file needs to be in the current folder.\n\n";
        print "\n##EXAMPLE:\n\n";
        print "1# perl augmentClusters.pl --outfile lvar.txt --metafile metadata.tsv --posFile areas_list.txt \n\n";
}

