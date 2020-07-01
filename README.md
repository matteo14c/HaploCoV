# assign_CL_SARS-CoV-2

## Prerequisites and usage

This repository contains a collection of simple Perl scripts that can be used to align complete assemblies of SARS-CoV-2 genomes wih the reference genomic sequence, to obtain a list of polymorphic positions and to **classify** one or more genomes according to the method described in *Chiara et al 2020* https://doi.org/10.1101/2020.06.26.172924. 
The preprint of the manuscript is currently available through bioRxiv, the manuscript is currently submitted and undergoing peer review.

This software package is composed of 2 very simple scripts. The only prerequisite is that you have an up to date and working installation of the Mummer package in your system and a copy of the reference genomic sequence, in fasta format, in the current folder.

Please follow this link https://sourceforge.net/projects/mummer/files/ for detailed instruction on how to obtain and run Mummer.

The reference genome of SARS-CoV-2 can be obtained from:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz
on a unix system you can download this file, by

`wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz`

followed by

`gunzip GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz`

Should you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics provides an operational classification system and reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2 bioRxiv 2020.06.26.172924; doi: https://doi.org/10.1101/2020.06.26.172924**

Should you find any issue, please contact me at matteo.chiara@unimi.it , or here on github

## Align to the reference genome

The helper script *align.pl* can be used to align a collection of genomic sequences to the reference assembly of SARS-CoV-2 and obtain a list of polymorphic positions. The script automates all the required steps. 

The only prerequisite is that all the genomic sequences that should be aligned to the reference **MUST** be in the **same folder** from which the program is executed. The program is very simple, and can detect only files with a **.fasta** extensions. Please name your files accordingly. 

Please see above for how to obtain the reference genome sequence file. This file also needs to be in the same folder from which the program is executed (and yes **the same** where you have all the files). If the reference genome file is missing, *aling.pl* will try to download it from Genbank. Although this is supposed to work only for unix and unix alike systems (the *wget* command is required)

Once you have everything in place, you can simply run:
`perl align.pl`

For every genome fasta file you will obtain a file with the extension .snps which will contain all the polymorphic positions identified by nucmer

## Assign to a Cluster

To assign genomes to clusters, you need to used the *assign_CL.pl* script. This script uses 46 high frequency polymorphic sites to assign a SARS-CoV-2 genome to clusters as defined in Chiara et al 2020 (see above). 

Although in the paper we identify 50 high frequency polymorphic sites in currently avaialbe genomes of SARS-CoV-2,  *3* 3' and 1 *5'* proximal sites have been excluded here based on the consideration that the majority of the currently available assemblies of SARS-CoV-2 are truncated at one or both ends. 

As shown in supplementary figure 1 of the paper, the exclusion of these sites does alter significantly our classification system.

Similar to *align.pl* , *assign_CL.pl* will automatically detect its input files. These are the files with the *.snps* extesion that you obtained from nucmer. So ideally you should place both scripts in the same folder where you have the genome sequences.

At this point to assign genomes to a cluster you need to run
`perl assign_CL.pl > OUTPUT_FILE`

*assign.pl* will print its output to the stdout by default, so  ">" is required to redirect the output to a file.

The output consists in a simple table, formatted as follows:
Name of the file | C1 score | C2 score | C3 score | C4 score | C5 score | C6 score | C7 score | C8 score | C9 score | C10 score | C11 score | C12 score | C |
---------------- |----------|----------|----------|----------|----------|----------|----------|----------|----------|-----------|-----------|-----------|---|
input 1|-1|-2|-5|-7|-4|-6|-5|-8|-4|-4|-4|-5|1
input 2|-2|-2|-5|-7|-4|-6|-5|-8|-4|-4|-4|3|12

The table indicates the name of each input file (column 1), the score for the membership of the sequence in each cluster (1-12, columns 2 to 13) and in the last column (14) the cluster with the highest score for that sequence, that is the cluster to which the sequence is assigned.

So in the example input 1 is assigned to C1

While input 2 is assigned to C12

## For impatient people

To do all of the above: 
1. put fasta files of genome sequence in one folder. 1 sequence per file. all the files must have the *.fasta* extension
2. download this repo
3. run `perl align.pl`
4. run `perl assign_CL.pl > OUTPUT_FILE`
5 open the output file, for every sequence the last column will indicate the cluster to which the sequence is assigned





