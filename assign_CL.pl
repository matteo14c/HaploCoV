%pos=
(
	"17858_A|G"=>[3],
	"28144_T|C"=>[2,3,4],
	"14805_C|T"=>[4,9],
	"14408_C|T"=>[5,6,7,8],
	"23403_A|G"=>[5,6,7,8],
	"26144_G|T"=>[9,10],
	"25563_G|T"=>[7,8],
	"1397_G|A"=>[11],
	"1059_C|T"=>[7,8],
	"28863_C|T"=>[4],
	"11916_C|T"=>[8],
	"3037_C|T"=>[5,6,7,8],
	"28881_G|A"=>[5,6],
#	"28882_G|A"=>[5,6],
#	"28883_G|C"=>[5,6],
	"23731_C|T"=>[6],
	"8782_C|T"=>[2,3,4],
	"18060_C|T"=>[3],
	"13730_C|T"=>[12],
	"2558_C|T"=>[10],
	"29540_G|A"=>[8],
	"18998_C|T"=>[8],
	"17747_C|T"=>[3],
	"29742_G|T"=>[11],
	"28657_C|T"=>[4],
	"9477_T|A"=>[4],
	"25979_G|T"=>[4],
	"6312_C|A"=>[12],
	"28311_C|T"=>[12],
	"28688_T|C"=>[11],
	"10097_G|A"=>[6],
	"23929_C|T"=>[12],
	"11083_G|T"=>[9,10,11,12],
	"2480_A|G"=>[10],
	"17247_T|C"=>[9]
);
print "name c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 C\n";
@files=<*_ref_qry.snps>;
@genomes=();
foreach $f (@files)
{
	$name=$f;
	$name=~s/_ref_qry.snps//;
	$name=~s/\.\d+//;
        my @scores=(-1,-1,0,0,0,0,0,0,0,0,0,0,0);
	%Ihave=();	

	#next if $name=~/EPI_ISL_402131/ || $name=~/EPI_ISL_410721/;
	open(IN,$f);
	%ldata=();
	while(<IN>)
	{
		next unless $_=~/NC_045512.2/;
                ($pos,$b1,$b2)=(split(/\s+/,$_))[1,2,3];
		$label="$pos\_$b1|$b2";
		next if $pos<=250 || $pos>29700;
		$Ihave{$label}=1;
	}
	foreach $pos (sort {$a<=>$b} keys %pos)
	{
		@clusters=@{$pos{$pos}};
		if ($Ihave{$pos})
		{
			foreach $cl (@clusters)
			{
				$scores[$cl]+=3;
			}
		}else{
			foreach $cl (@clusters)
                        {
                                $scores[$cl]-=1;
                        }
		
		}		
	}
	my $max=-100;
	my $i=0;
	my $imax=0;
	foreach $s (@scores)
	{
		$imax=$i if $s>$max;
		$max=$s if $s>$max;
		$i++;
	}
	shift(@scores);
	$imax=1 if $imax==0;
	print "$name @scores $imax\n";
}
