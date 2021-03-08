# assign_CL_SARS-CoV-2

## Prerequisites and usage

This repository contains a collection of simple Perl scripts that can be used to align complete assemblies of SARS-CoV-2 genomes wih the reference genomic sequence, to obtain a list of polymorphic positions and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049. 

This software package is composed of 2 very simple scripts. The only prerequisite is that you have an up to date and working installation of the Mummer package in your system and a copy of the reference genomic sequence, in fasta format, in the current folder.

Please follow this link https://sourceforge.net/projects/mummer/files/ for detailed instruction on how to obtain and run Mummer.

The reference genome of SARS-CoV-2 can be obtained from:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz
on a unix system you can download this file, by

`wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz`

followed by

`gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz`

Please notice that however the *align.pl* utility is going to download the file for you, if a copy of the reference genome is not found in the current folder. However, since the "wget" command is required this is supposed to work only unix and unix alike systems.

Should you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.**

Should you find any issue, please contact me at matteo.chiara@unimi.it , or here on github

## Align to the reference genome

The helper script *align.pl* can be used to align a collection of genomic sequences to the reference assembly of SARS-CoV-2 and obtain a list of polymorphic positions. The script automates all the required steps. align.pl currently allows 3 different distinct methods to provide input files/sequences:
* Through a multifasta file: **option --multi**;
* Through a file containing a list of file names: **option --filelists**;
* By specifying a "suffix" that is common to all the names of the files that should be analyses: **option --suffix**;

All input files **MUST** be in the **same folder** from which the program is executed. 

The name of the output file can be specified by using the **--out option**. This defaults to **ALIGN_out.tsv**. 
All the "intermediate files" containing the result of the alignment of every genome to the reference sequence will be stored in a separate folder. The name  can be specified using the **--outdir option**. But defaults to **align**. These files should be used as the input to *assign_HGs_2021.pl* . So please do no delete them.

Please see above for how to obtain the reference genome sequence file. This file also needs to be in the same folder from which the program is executed (and yes **the same** where you have all the files). If the reference genome file is missing, *aling.pl* will try to download it from Genbank. Although this is supposed to work only for unix and unix alike systems (the *wget* command is required)

Once you have everything in place, you can simply run:
>* `perl align.pl --multi <multifasta>` to align all the genomes contained in a multifasta file or
>* `perl align.pl --suffix <fasta>` to align all the .fasta files contained in the current folder or
>* `perl align.pl --filelist <list>` to align all the files specified in a list of file names.One file per line. Again, all files need to be in the current folder

For every genome fasta file you will obtain a file with the extension .snps which will contain all the polymorphic positions identified by nucmer. These files will be stored in the directory specified by the --outdir option (default align). Additionally the .tsv output consists in a simple tabular file (default name **ALIGN_out.tsv**) that lists genetic variants on the rows, and reports their presence (1) or absence (0) in the different genomes included in your analysis in the columns. 


## Assign to a Haplogroup

To assign genomes to haplogrouos, you need to run the *assign_HGs_2021.pl* script. This script uses high frequency polymorphic sites, as specified by **listVariants.txt** to assign a SARS-CoV-2 genome to haplogroups as defined in Chiara et al 2021 (see above). Please make sure that a copy of this file is always in the same folder from which the script is executed. Incosistent/incorrect results will be obtained otherwise.

Although in the paper we initially identified 50 high frequency polymorphic SARS-CoV-2 genomic sequences considered in our analyses, more recent analyses based on a larger number of genomes (last update 26th Feb 2021), suggest that currently this number raised to 243.  As of this update 85 distinct **HGs** of SARS-CoV-2 are currently identified.  Please see https://figshare.com/articles/dataset/Data_and_images_from_Chiara_et_2020_/13333877 for a more detailed description

Similar to *align.pl* , *assign_HGs_2021.pl* will automatically detect its input files. These are the files with the *.snps* extension that you obtained from running nucmer, and are saved in the output folder of align.pl (see --outdir). The script currently accept two main parametes:
>* **--dir**: the name of the input directory 
>* **--out**: the name of the ouput file (defaults to **ASSIGNED_out.tsv**)

To assign genomes to a haplogroup you need to run
`perl assign_HGs_2021.pl --dir align --out ASSIGNED_out `


The output consists in a simple table, with 2 columns formatted as follows:
Name of the file | HG assigned|
---------------- |------------|
input 1| 5|
input 2|26|

The table indicates the name of each input file (column 1), and the haplogroup assigned to that sequence.

So in the example input 1 is assigned to HG5

While input 2 is assigned to HG26

## For impatient people

To do all of the above: 
1. run `perl align.pl --multi YOURMULTIFASTA`
4. run `perl assign_HGs_2021.pl`
5. open the **ASSIGNED_out.tsv** file, for every sequence the second column will indicate the haplogroup to which the sequence is assigned

## Graphical interface version

Please notice that a more user friendly, graphical interface based version of this software is also available from: http://corgat.cloud.ba.infn.it/galaxy . Please refer to https://corgat.readthedocs.io/en/latest/ for a more detailed manual.

In case of problems or doubts, please feel free to contact me at matteo.chiara@unimi.it


