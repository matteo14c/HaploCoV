# HaploCoV: a set of utilities and methods to identify novel variants of SARS-CoV-2

## Important
Please be aware that this readme will cover only the basic set-up and execution of HaploCoV. The extended manual is available at [readthedocs](https://haplocov.readthedocs.io/en/latest/) (interactive verions) or MISSINGLINK (pdf).

## What this tool can do for you

HaploCoV is a collection Perl scripts that can be used to:
* **align** complete assemblies of SARS-CoV-2 genomes with the reference genomic sequence and **identify genomic variants**, 
* pinpoint **regional variation** and flag genomic variant with **"high frequency"** locally or globally, 
* **extend an existing classification system** and  , 
* **identify epidemiologically relevant variants and/or novel lineages/sub-lineages of the virus** 
* and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice. 

## HaploCoV

This software package is composed of **8(*+2*)** utilities. Prerequisites for making HaploCoV run properly are stated below (see Prerequisites).
In brief, input files need to be formatted to the format used by HaploCoV by applying either **addToTable.pl** or **NexstainToHaploCoV.pl** (depending on the input, see below). 
Then the complete HaploCoV workflow can be executed by running **HaploCoV.pl** (reccommended) or, if you prefer, by running each single tool in the HaploCoV workflow, in the right order, yourself (please see the extended manual for a complete reference).
Figure 1 provides a conceptual representation of the HaploCoV workflow and the tools used to execute each task.

## Input files

HaploCoV requires 3 input files:
* **the reference assembly** of the SARS-CoV-2 genome in fasta format
* a **multifasta** file with SARS-CoV-2 genomes to be compared with the reference
* a **.tsv** file with metadata associated to the SARS-CoV-2 genome sequences included in the multifasta
See the "How do I get the input files?" section for more details on how to obtain these files.

Should you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.**

Should you find any issue, please contact me at matteo.chiara@unimi.it , or open an issue here on github.
<hr>


## Running HaploCoV

## #1 Compile a metadata table in HaploCoV format

All the tools and utilities in HaploCov operate on a large metadata table in tsv format (*HaploCoV* format from here onward). 
If you obtained your data from **GISAID** you can format your data in *Haplocov* format by using the *addToTable.pl* utility. If data were downloaded from Nexstrain, you can use *NextStrainToHaploCov.pl* instead (see below).

## HaploCoV format for metadata
An example of the data format used by HaploCoV (HaploCoV format) is reported in the table below:

column 1 |column 2 |column 3 |column 4 |column 5 |column 6 |column 7 |column 8 |column 9 |column 10 |column 11 |
---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|
genome ID|collection date|offset days from collection|deposition date| offset days from deposition|continent|macro-geographic region|country|region|lineage|list of allele variants|

The file is delineated by tabulations. Allele variants are reported as a comma separated list. 
The format is as follows<br>: 
*genomicposition_ref|alt* i.e. *1_A|T* for example indicates a A to T substitution in position 1 of the reference genome<br>

A valid example of an HaploCoV-formatted file, including all the sequences available in INSDC databases up to 2022-07-20 is available at the following link: [HaploCoVFormatted.txt](http://159.149.160.88/HaploCoVFormatted.txt.gz) in the form o a  with `gzip` compressed file. When de-compressed the file should be around 2.9G in size.  

## #1.1 GISAID data: addToTable.pl

addToTable.pl reads multifasta (*sequences.fasta*) and metadata files(*metadata.tsv*) and extracts all the information required for subsequent analyses. 

### Options
addToTable.pl accepts the following options:

* **--metadata**: input metadata file (tipically metadata.tsv from GISAID)
* **--seq**: fasta file
* **--nproc**: number of threads. Defaults to 8.
* **--dayFrom**: include only genomes collected after this day
* **--outfile**: name of the output file

### Execution:
An example command looks like:
<br>`perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `<br><br> 
The final output will consist in a metadata table in HaploCoV format.  This table is required for all the subsequent analyses.

### Important: Incremental addition of data
addToTable.pl can add novel data/metadata incrementally to a pre-existing table in "HaploCoV" format. This feature is extremely useful, since it allows users to add data incrementally to their HaploCoV installation, without the need to re-execute analyses from scratch. When users the output file provided by the user is not empty, addToTable.pl will process only those genomes which are not already included in your medatata table. Matching is by sequence identifier (column Virus name).

### Execution times 
On a single processor HaploCoV can process about 20k SARS-CoV-2 genomes per hour. Computation scales linearly: 160k genomes on 8 cores, or 320k on 16 cores. This means that processing the complete collection of the more than 13M genomes included in the GISAID database on November 11th 2022 from scratch will take about 20 days if only one processor is used;  3 days would be needed if 8 processes are used; and 1.5 days if 16 are used. Importantly this operation needs to be performed only once, since the tool supports the incremental addition of data (see above). 

## NextStrain data: NextStrainToHaploCoV.pl

If you have downloaded your metadata files from Nexstrain ( [link](https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz) ), you need to use the utility *NextStrainToHaploCoV.pl* to convert them in HaploCoV format.
Unlike addToTable.pl, NextStrainToHaploCoV.pl does not support incremental addition of data to a pre-existing file: this was not implemented since the full data by NextStrain can be converted in *HaploCoV* format in 3 to 5 minutes. 

### Options
NextStrainToHaploCoV.pl accepts the following options
--metadata: name of the input file
--outfile: name of the output file

## Execution

A typical command line for NextStrainToHaploCoV.pl is something like:

` NextStrainToHaploCoV.pl --infile metadata.tsv --outfile linearDataSorted.txt `

The output file will be in *HaploCoV* format and can be used by computeAF.pl to compute allele frequencies 


## #2 Use HaploCoV.pl to apply the full pipeline

Once data have been converted in HaploCoV format, the complete workflow can be executed by applying **HaploCoV.pl**. 
HaploCoV.pl is the workhorse of HaploCoV and is the recommended way to execute our software. 
Users can specify a list of geographic regions/areas or countries and intervals of time to be considered in their analyses by providing a configuration file in text format (--locales). HaploCoV.pl will process the configuration file and apply the complete HaploCoV workflow to each entity therein included. For every distinct country, area or region results will be provided in the form of an individual report (.rep) file.<br>  This .rep file will contain a list of candidate SARS-CoV-2 variants/lineages showing a significant increase of their "VOCness score" and/or "prevalence", and which are probably worth to be  monitored. More details on the interpretation of this report are provided in the section "how to interpret HaploCoV's results/what to do next".
HaploCoV.pl accepts also an additional configuration file called "parameters file" (--param) which is used to set the parameters/options of each tool in the pipeline. A "default" configuration file (called parameters) is included in this Github repository, which should suit most use case.  Users who need to modify the defaults and apply custom settings are encouraged to read the section "Advanced analyses/fine tuning of HaploCoV" for a more comprehensive discussion.


### Options
HaploCoV.pl accepts the following options
--file: name of the input file (metadata file in HaploCoV format)
--locales: configuration file with the list of regions and countries to analyse
--param: configuration file with the set of parameters to be applied by HaploCoV in your analysis
--path: path to your HaploCoV installation

### locales file

Locale(s) configuration files need to have a tabular format and contain 5 colums separated by tabulations. An example of a valid file is illustrated below:
column 1|column 2 |column 3  |column 4  |column 5        |
--------|---------|----------|----------|----------------|
location|qualifier|start-date|end-date  |genomic-variants|
Italy   |country  |2022-01-01|2022-11-11|areas_list.txt  |
Thailand|country  |2022-01-01|2022-11-11|custom          |
workd   |area     |2022-01-01|2022-11-11|custom          |

* location: a country, a region or a macrogeographic area (see "geography in HaploCoV") for more details
qualifier: qualifier of the geographic entity, accepted values are: region, country or area. Again, refer to "geography in HaploCoV" for more details.
* start-date: lower limit of the interval of time on which to execute the analysis (see "dates in HaploCoV")
* end-date: upper limit of the interval of time
* genomic-variants: a list of files with high frequency genomic variants. Comma separated. Each file is used to derive novel candidate lineages compared to a reference nomenclature.  A distinct report file (.rep) will be generated for every file in this list, and the name of the variant file is always appended to the name of the report. Pre-computed genomic variants files are provided in the main HaploCoV installation. Please se the section "genomic variation and high frequency variant" for additional explanations on how "genomic-variants" files are used. Users have also the option of executing "custom" analysis and derive a list of "interesting" genomic variants on the go, based on their selection. In this case custom needs to be indicated in the 5th column. See below   
The file locales.txt included in this repository provides a valid example of a locales configuration file. 

## Important: special/reserved keywords
When the reserved word **world**  is used in the 1rst column of your locales all the sequences in the metadata file will be analysed irrespective of the geography.

In the 5th (genomic-variants) you can use the reserved world "custom" if you prefer to re-compute high frequency genomic variants based on your selection of genomic sequences, instead of using a pre-computed allele-variant file provided by HaploCoV. This option allows more flexibility, as in this case high frequency genomic variants are determined dynimically based on a user selection. Please read the section "genomic variation and high frequency variant" for a more in-depth explanation.


### parameters file

This file sets the parameters to be used by the various tools in HaploCoV. A default file with a standard configuration (parameters) is included in this repository. This file should suit most use case/scenario. Please see the section "Advanced analyses and customisation" for instructions on how to modify the default settings.

## Execution

An example of a valid command line:

` perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `

Since in italy.loc locales configuration file

<hr>

# How to run HaploCoV in brief

To do all of the above: 
### GISAID data
1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

### Nexstrain data
1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

### then

2. ` perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `

### Finally
Read the report (.rep) file

<hr>

# How to interpret HaploCoV's results/what to do next.

<hr>
## Regards, from the HaploCoV development "team"
 
 




