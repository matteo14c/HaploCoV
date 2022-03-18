# HaploCoV: a set of utilities and methods to identify novel variants of SARS-CoV-2

## Prerequisites and usage

This repository contains a collection of simple Perl scripts that can be used to:
* **align** complete assemblies of SARS-CoV-2 genomes wih the reference genomic sequence, 
* identify **regional** "high frequency" allele variants of the virus, 
* **extend an existing classification** by including such regional alleles, 
* derive **potentially epidemiologically relevant variants** 
* and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049. 

This software package is composed of 6 very simple scripts. The only prerequisite is that you have an up to date and working installation of the CorGAT in your system. 
Please follow this link https://corgat.readthedocs.io/en/latest/ for detailed instruction on how to obtain and run CorGAT. **We strongly suggest to install CorGAT in the same folder where you have HaploCoV utilities i.e under HaploCoV/CorGAT** . 

## Inputs

Three main inputs are required:
* **the reference assembly** of the SARS-CoV-2 genome in fasta format
* a **multifasta** file with SARS-CoV-2 genomes to be compared with the refence
* a **.tsv** file with metadata associated to the SARS-CoV-2 genome sequences included in the multifasta

The reference genome of SARS-CoV-2 can be obtained from:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz
on a unix system you can download this file, by

`wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz`

followed by

`gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz`

Please notice that however the *align.pl* utility is going to download the file for you, if a copy of the reference genome is not found in the current folder. However, since the "wget" command is required this is supposed to work only unix and unix alike systems.

### IMPORTANT
SARS-CoV-2 genomic sequences and associated metadata can be obtained from the GISAID (https://www.gisaid.org/) database. The following columns are required/expected to be found in the metadata file:
* **Virus name** : identifiers of viral isolates. These names **MUST** match the names included in the multifasta file
* **Location** : geographic place where the sample was collected. The expected format is continent/country/region
* **Collection date** : date of collection of the sample
* **Pango lineage** : Pango lineage (or group according to a nomenclature of choice) assigned to viral isolates

Should you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.**

Should you find any issue, please contact me at matteo.chiara@unimi.it , or open an issue here on github

## Align to the reference genome

The helper script *align.pl* can be used to align a collection of genomic sequences to the reference assembly of SARS-CoV-2 and obtain a list of polymorphic positions. align.pl currently takes a simple multifasta file as its input. Alignments with the reference genome are saved in the form of simple text files (.txt). All these files are stored in a user defined (see --snps) directory. align.pl allows the following options 
* **--file**: input fasta file
* **--genomes**: directory where temporary files are stored
* **--snps**: directory where final alignment files are stored

All alignments are performed by means of the mummer program, which is a prerequisite to CorGAT and should be already installed to your system.
All input files **MUST** be in the **same folder** from which the program is executed. 
The program does not support multithreading at the moment. However, since the program support incremental analysis/addition of novel files if you have a large number of genome sequences in your fasta file and you want to speed up the computation, you can split the input fasta into several distinct files, and analyse those file independently.  
For every genome  will obtain a file with .txt the extension which will contain all the polymorphic positions identified by nucmer. These files will be stored in the directory specified by the **--snps** option. These alignments provide the input to many of the other program in the suite. **So please do no delete this folder!**.

### A typical run of align.pl should look something like:
`perl align.pl --file apollo.fa ` (where apollo.fa is the multifasta file with genome sequences)
The output will consist in a collection of alignment files, in .txt format stored in the directory specified by --snps (default ./snps)


## Compute local high frequency alleles

High frequency alleles are computed by *computeAF.pl* this program requires a set of alignments in txt format (which are the output of *align.pl*) and a file in .tsv format with metadata associated with every genome as the main inputs.
The tool partitions genomes according to geographic metadata, and computes allele frequencies over a user defined time interval, in overlapping time windows of a user defined size. The main ouputs consist in lists of "high frequency" variants. Different level of geographic granularity: global (all genomes), macro(macro geographic areas) and regional(country) are considerd. Macro areas are specified by the "areaFile" file included in the current repo.
All the final outputs as well as all intermediate files, are saved in a output folder that can be specified by the user. User do also have the option to select the minimum frequency (as in allele frequency) and "persistency" (number of weeks above the AF threshold) thresholds for the identification of high frequency variants.

The script accepts the following parameters:
* *--file* name of the metadata file (please see above the section above concerning the format/mandatory information) 
* *--maxT* upper bound in days for the time interval to consider in the analysis (days are counted starting from 12-30-2019). A value of 1 corresponds to 12-31-2019. A value of 365 to 12-30-2020. And so on
* *--minT* lower bound for the time interval. days are counted using the same logic described form maxT
* *--interval*  size in days of overlapping time windows, defaults to 10
* *--minCoF* defaults to 0.01, minimum AF for high frequency alleles 
* *--minP* defaults to 3, minimum persistence (number of overlapping time windows) for high freq alleles: only alleles that have a high frequency (>=minCoF) in at least this number of distinct time windows will be included in subsequent analyses
* *--alndir*  defaults to "./snps", directory where allele variant files are stored. Corresponds with the output of align.pl
* *--outdir*  defaults to "./metadata", output directory. This directory will hold the main output files, with a complete list of high frequency alleles. 

### A typical run of align.pl should look something like:
`perl computeAF.pl --file metadata.tsv ` (where metadata.tsvis is the .tsv file with complete metadata)
The output will be stored in the directory specified by --outdir, and will include:
* allele frequency matrices for all the countries and macro-geographic areas, for the time interval specified by the user
* three files: with the *\_list.txt"* suffix containing lists of high frequency allele at global (global_list.txt), macro-areas(macro_list.txt) and country (country_list.txt) level

## Derive novel groups

Novel groups/sublineages of SARS-CoV-2 within a nomenclature are identified by augmentClusters.pl. This utility is used to derive novel sub-groups/sub lineages within an existing classification of SARS-CoV-2 lineages/variants. The aim is to extend a "targeted" classification by the incoporation of local/regional high frequency alleles, which are used to infer/derive local variants of the virus. Users can specify the minimum size (miminum number of isolates included in the group) required for a novel group to be formed (--size) and the minimum distance (in terms of number of characteristic high frequency alleles, --dist) between a newly formed groups.
The main input consist in a collection of alignment files (see output of *align.pl*), a metadata file in .tsv format which specifies the group/lineage assigned to every genome and a list of high frequency alleles (as derived by computeAF.pl).
The main output will consist of a simple text file including a list of SARS-CoV-2 variants/lineages (one per line) and the list of their characteristic (present in >50% of the genomes) allele variants,and equivalent information for the novel variants/sub-group formed by the tool. All novel variant/groups will be indicate by a suffix (--suffix) that can be specified by the user.

The script accepts the following parameters:
* --metafile name of the metadata file (please see above the section above concerning the format/mandatory information)
* --posFile list of high frequency alleles (this is one of the main outputs of align.pl, tipically areas_list.txt)
* --alndir defaults to "./snps", directory where allele variant files are stored. Corresponds with the output of align.pl
* --dist minimum edit distance (number of characteristic high frequency alleles) required for forming a novel group. Defaults to 2
* --suffix suffix used to delineate novel lineages,defaults to N
* --size minimum size for a new subgroup within a lineage/group, defaults to 100
* --tmpdir directory used to store temporary files
* --oufile name of the output file
The main output will be saved in the current folder. --tmpdir will hold all temporary files, along with a log file.

### A typical run of align.pl should look something like:
`perl augmentClusters.pl --outfile lvar.txt --metafile metadata.tsv --posFile areas_list.txt `
The main output file: lvar.txt will contain all current groups/lineages and newly formed groups/sub-lineages, and a complete list of their characteristic mutations, in txt format one per line 

## Compute genomic features of SARS-CoV-2 lineages and sublineages

The LinToFeats.pl utility exploits CorGAT (see above) to compute "high level" genomic features of SARS-CoV-2 lineages/sub-lineages derived by augmentClusters.pl.
A complete list of such high level features along with a brief description is provide in the features.csv file attached to this repo.
LinToFeats.pl takes the output of augmentClusters.pl as its main input, the output file is a simple tab delineated table where for every lineage/group in the input genomic features are computed.

The program requires only 3 parameters:
* *--infile* file with lineages/groups and their characteristic allele variants. 1 lineage per line. (main output of augmentClusters.pl)
* *--outfile* name of the output file
* *--corgat*	 path to corgat installation. Defaults to "./corgat"

### A typical run of LinToFeats.pl should look something like:
`perl LinToFeats.pl --infile lvar.txt --outfile lvar_feats.tsv `
The main output file: lvar_feats.tsv will contain genomic features in tabular format for all SARS-CoV-2 groups/lineages newly formed groups/sub-lineages.


## Prioritize newly created lineages

The report.pl utility can be used compare newly created groups/sublineages with their parental lineages in the reference nomenclature and priotitize lineages/sub lineages of SARS-CoV-2 showing a high increase in score with respect to a parental lineage. 
The main input corresponds with the output of LinToFeats.pl. Users are also required to specify the prefix used to indicate "novel" lineages/sublineages. This suffix must match the equivalent suffix provided to augmentClusters.pl. The default value is N. The configuration file indicated by --scaling: provides the least of features to be used in the computation of the final score.
A complete description of the features can be found in the features.csv file attached to this github repo
The final output consist in a simple text file, in tsv format where high scoring varants/sub-variants are reported
These represent  variants that are likely to be interesting from an epidemiological perspective

report.pl accepts the following input parameters:
* *--infile* name of the input file. This is the output file of LinToFeats.pl
* *--suffix* suffix used to identify novel lineages/subvariants by augmentClusters.pl (see --prefix)
* *--scaling* defaults to "scalingFactors.csv", this configuration file in included in the github repo
* *--outfile* a valid name for the output file

### A typical run of LinToFeats.pl should look something like:
`perl report.pl --infile lvar_feats.tsv --outfile lvar_prioritization.txt `
The main output file lvar_prioritization.txt will a list of the SARS-CoV-2 variants that show a significant increase in their genomic score with respect to a parent variant. These variants are more likely to pose an increased risk from an epidemiological perspective.

## Assign genomes to new groups

To assign genomes according to the "expanded" nomenclature you need to run the *assign_HGs_2021.pl* script. This script characteristic allele varianst of SARS-CoV-2 lineages/sub-groups as derived by *augmentClusters.pl* to assign a SARS-CoV-2 genomes to lineages/groups/sublineages. 

Similar to *align.pl*, *assign_HGs_2021.pl* will automatically detect its input files. These are the files with the *.txt* extension stored in the --outdir that you specified to align.pl. The script currently accept two main parametes:
* *--infile*: input file list of SARS-CoV-2 lineages/sub lineages along with characteristic mutations
* *--dir*: the directory where alignments files are stored
* *--out*: the name of the ouput file (defaults to **ASSIGNED_out.tsv**)

To assign genomes to a haplogroup you need to run
`perl assign_HGs_2021.pl --infile  lvar.txt`

The output consists in a simple table, with 2 columns formatted as follows:
Name of the file | group assigned|
---------------- |---------------|
input 1| 5|
input 2|26|

The table indicates the name of each input file (column 1), and the designation assigned to that sequence.


## For impatient people

To do all of the above: 
1. `perl align.pl --file apollo.fa `
2. `perl computeAF.pl --file metadata.tsv `
3. `perl augmentClusters.pl --outfile lvar.txt --metafile metadata.tsv --posFile areas_list.txt `
4. `perl LinToFeats.pl --infile lvar.txt --outfile lvar_feats.tsv `
5. `perl report.pl --infile lvar_feats.tsv --outfile lvar_prioritization.txt `
6. `perl assign_HGs_2021.pl --infile  lvar.txt `


