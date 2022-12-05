# HaploCoV: a set of utilities and methods to identify novel variants of SARS-CoV-2

## Important
Please be aware that this readme covers only the standard set-up and execution of HaploCoV. An extended manual, with a more complete overview of the tool and parameters is available at [readthedocs](https://haplocov.readthedocs.io/en/latest/).

## What this tool can do for you

HaploCoV is a collection Perl scripts that can be used to:
1. **align** complete assemblies of SARS-CoV-2 genomes with the reference genomic sequence and **identify genomic variants**, 
2. pinpoint **regional variation** and flag genomic variant with **"increased frequency"** locally or globally,  
3. **identify epidemiologically relevant variants and/or novel lineages/sub-lineages of the virus** (using a custom scoring system), 
4. **extend an existing classification system** to include novel designations/variants,
5. and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice. 

## HaploCoV

This software package is composed of **9(*+3*)** utilities. Instructions concerning required input files, their format and how to configure HaploCoV are reported below (and in the extended [manual](https://haplocov.readthedocs.io/en/latest/) ). 
In brief, input files need to be formatted according to the format used by HaploCoV by applying either **addToTable.pl** or **NexstainToHaploCoV.pl** (depending on the input, see below). 
Then the complete HaploCoV workflow can be executed by running **HaploCoV.pl** (reccommended) or, if you prefer, by running each individual tool in the HaploCoV workflow in the right order yourself (please see the extended manual for a complete reference).
Figure 1 provides a conceptual representation of the HaploCoV workflow and the tools used to execute each task.

### Aim and rationale

The main aim of the tool is to facilitate the identification of novel variants/lineages of SARS-CoV-2 showing:
1. An increase in their prevalence (regional, national or global)
2. Features associated with VOCs/VOIs (variants of concern or variants of interest)
3. Both

HaploCoV incorporates a standalone "scoring system" for the identification and flagging of VOC and VOI-like variants based on the functional annotation of the genome. Interesting/relevant candidate variants are identified as those showing a significant increase (above a minimum threshold) in their score compared with their parental lineage/variant. The minimum threshold for significance was derived empirically (see the HaploCoV paper for more details). 

Increase/decrease in prevalence is inferred by analyses of the (available) metadata. By default novel candidate variants with a prevalence above 1% in a region/country, and showing an increase by at least 2 fold over 4 weeks are reported. 
These parameters can be configured/set by the user at runtime.

The main output consists in a report file that summarizes the prevalence and features (as defined by the criteria outlined above) of novel candidate variants of SARS-CoV-2.  

<hr>

# How to run HaploCoV in brief
 
### GISAID data
1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

### Nexstrain data
1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

### then

2. ` perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `

### Finally
Read the report (.rep) file.
Track any interesting/additional novel variant that you identified
(Optional, read the full manual for more detailed analyses).
See the following sections for complete details.

<hr>


## Input files

HaploCoV requires 3 (main) input files:
* **the reference assembly** of the SARS-CoV-2 genome in fasta format;
* a **multifasta** file with SARS-CoV-2 genomes to be compared with the reference;
* a **.tsv** file with matched (to the sequences in the fasta file) metadata;
See the "Where do I get the data?" section in the [manual](https://haplocov.readthedocs.io/en/latest/data.html) for more details on how to obtain these files.

If you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.**

Should you find any issue, please contact me at matteo.chiara@unimi.it, or open an issue here on github.
<hr>


## Running HaploCoV

## #1 Compile a metadata table in HaploCoV format

All the tools and utilities in HaploCov operate on a large table in tsv format (*HaploCoV* format from here onward). 
If you obtained your data from **GISAID** you can format your data in *Haplocov* format by using the *addToTable.pl* utility. If data were obtained from Nexstrain, you can use *NextStrainToHaploCov.pl* instead (see below).

## HaploCoV format for metadata
An example of the data format used by HaploCoV (HaploCoV format) is reported in the table below:

column 1 |column 2 |column 3 |column 4 |column 5 |column 6 |column 7 |column 8 |column 9 |column 10 |column 11 |
---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|
genome ID|collection date|offset days from collection|deposition date| offset days from deposition|continent|macro-geographic region|country|region|lineage|list of genomic variants|

The file is delineated by tabulations. Genomic variants are reported in the form of a comma separated list. 
The format is as follows: <br> 
\<genomicposition\>_\<ref\>|\<alt\>  <br>
i.e. 1_A|T indicates a A to T substitution in position 1 of the reference genome.<br>

A valid example of an HaploCoV-formatted file, including all the sequences available in INSDC databases up to 2022-07-20 is available at the following link: [HaploCoVFormatted.txt](http://159.149.160.88/HaploCoVFormatted.txt.gz) in the form of a with `gzip` compressed file. When de-compressed the file should be around 2.9G in size.  

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

If you downloaded your metadata files from Nexstrain ( [link](https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz) ), you need to use the utility *NextStrainToHaploCoV.pl* to convert them in HaploCoV format.
Unlike addToTable.pl, NextStrainToHaploCoV.pl does not support incremental addition of data to a pre-existing file:  the full NextStrain dataset can be converted in *HaploCoV* format in 3 to 5 minutes. 

### Options
NextStrainToHaploCoV.pl accepts the following options
--metadata: name of the input file
--outfile: name of the output file

## Execution

An example of a valid command line for NextStrainToHaploCoV.pl is as follows:

` NextStrainToHaploCoV.pl --infile metadata.tsv --outfile linearDataSorted.txt `

The output file *linearDataSorted.txt* will be in *HaploCoV* format.

## #2 Use HaploCoV.pl to apply the full pipeline

### HaploCoV.pl

Once data have been converted in HaploCoV format, the complete workflow can be executed by applying **HaploCoV.pl**.<br> 
HaploCoV.pl is the workhorse of HaploCoV and is the recommended way to execute our software.<br> 
Users can specify a list of geographic regions/areas or countries and intervals of time to be considered in their analyses by providing a configuration file in text format (--locales).<br> 
HaploCoV.pl will process the configuration file and apply the complete workflow to each entity therein included. For every distinct country, area or region results will be provided in the form of an individual report (.rep) file.<br>  
This .rep file will contain a list of candidate SARS-CoV-2 variants/lineages showing a significant increase of their "VOCness score" and/or "prevalence", and which are probably worth to be  monitored. More details on the interpretation of this report are provided in the section [How to interpret HaploCoV's results](https://haplocov.readthedocs.io/en/latest/haplocov.html#how-to-interpret-haplocov-s-results).<br>

<hr>

### Options

HaploCoV.pl accepts the following options
* --file: name of the input file (metadata file in HaploCoV format)
* --locales: configuration file with the list of regions and countries to analyse
* --param: configuration file with the set of parameters to be applied by HaploCoV in your analysis
* --path: path to your HaploCoV installation
* --varfile: additional file with defining genomic variants

### Execution

An example of a valid command line is reported below:

` perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `

Since in this case the type of analysis was set to "custom" and the target geographic region to Italy (in italy.loc, see "Locales file" below). The final output will be reported in a file called \"Italy\_custom.rep\".

<hr>

### Configuration (Locales file)

Locale(s) configuration files are used by HaploCoV.pl to set the main parameters for the execution of your analyses. These files need to have a tabular format and contain 5 colums separated by tabulations. An example of a valid locales file is illustrated below:

column 1|column 2 |column 3  |column 4  |column 5        |
--------|---------|----------|----------|----------------|
location|qualifier|start-date|end-date  |genomic-variants|
Italy   |country  |2022-01-01|2022-11-11|areas_list.txt  |
Thailand|country  |2022-01-01|2022-11-11|custom          |
world   |area     |2022-01-01|2022-11-11|custom          |

* location: a country, a region or a macrogeographic area (see "Geography and places" in the manual) for more details
* qualifier: qualifier of the geographic entity, accepted values are: region, country or area. Again, refer to "geography in HaploCoV" for more details. 
* start-date: lower limit of the interval of time on which to execute the analysis (see "Dates and time in HaploCoV")
* end-date: upper limit of the interval of time
* genomic-variants: a list of files with high frequency genomic variants. Comma separated. Each file is used to derive novel candidate lineages/variants compared to a reference nomenclature.  A distinct report file (.rep) will be generated for every file in this list. The name of the variant file is always appended to the name of the report, i.e if the name of your genomic variants file is \"myVar\" the name of the report will be \"_myVar.rep" (see below).

The file locales.txt included in this repository provides a valid example of a locales configuration file. 

### Output (and intermediate files folder)

The name of the main output by HaploCoV.pl is set automatically by the program by combining the value provided in the "location" (1rst) column, with value/values reported in the "genomic-variants" (5th) column of your locales configuration file. In the example above 3 different output files will be obtained:

* Italy_areas_list.txt.rep
* Thailand_custom.rep
* world_custom.rep

Each execution of HaploCoV usually generates several temporary/indermediate files. Normally you will not need to read/process/use these files, however for your convenience, all the intermediate files will be in be saved in a distinct folder. The same conventions applied for naming the main output files is used also to give names to the  intermediate folders. 
In the example outlined above, indermediate files will be saved in 3 different folders, called:

* Italy_areas_list.txt_results
* Thailand_custom_results
* world_custom_results

The section [Indermediate files and what to make of them](https://haplocov.readthedocs.io/en/latest/haplocov.html#intermediate-files-and-what-to-make-of-them) in the manual provides a more complete descrition of all the intermediate output files that you will find in this folder.

<hr>

### Genomic variants files (Configuration II)

HaploCoV uses collections of genomic variants with high frequency in a specific country/region/locale to define and identify novel candidate variants/lineages of SARS-CoV-2.<br> 
For your convenience, a collection of "pre-computed" files is available in this github repository. If you want to use one of these files, you simply have to enter the file/files name in the fifth column of your "locales" configuration file. HaploCoV will detect the file and run all the analyses. 

Precomputed sets of genomic variants/files can broadly be categorized into 4 main classes:

1. *Highly variable genomes.* These are allelic variants found in at least 25 "highly divergent" genomic sequences (w.r.t the reference strain to which they are assigned). These files are stored under the folder: HighVar.
2. *Country specific genomic variants.* Genomic variants reaching a frequency of 1% or higher, for at least 15 days in a country at any time point from Mon 2019-12-30. These files are stored under the folder: country. 
3. *Increased prevalence genomic variants.* Genomic variants showing an increase in their prevalence of a 1.5 fold or greater in at least one country, at different months, and starting from January 2020. These files are stored under the folder: HighFreq. 
4.*globally frequent genomic variants.* These are provided in the main github repository of HaploCoV, and include: *global_list.txt*: frequent worldwide, *areas_list.txt*: frequent at at least one macro-geographic area and *country_list.txt*: frequent at at least one county

Please se the section [Genomic variants file](https://haplocov.readthedocs.io/en/latest/genomic.html) for additional information. 

Alternatively, if the pre-computed files do not suit their use case,  users do also have the option of derive "custom" sets of genomic variants by analysing the selected locale and time-frame only. In this case the keyword "custom" needs to be indicated in the 5th column (see below), and high frequency genomic variants will be computed on the current selection.   

### Important: special/reserved keywords

When the reserved word **world**  is used in the 1rst column of your locales all the sequences in the metadata file will be analysed irrespective of the geographic origin.

In the 5th (genomic-variants) you can use the reserved world "custom" if you need to re-compute high frequency genomic variants based on your selection of genomic sequences, instead of using a pre-computed allele-variant file provided by HaploCoV. This option allows more flexibility. When custom is specified high frequency genomic variants are determined dynimically based on the user selection. Please see the [Genomic variants file](https://haplocov.readthedocs.io/en/latest/genomic.html) in the manual for additional explanations.

### Advanced configuration

This readme covers only the standard/basic requirements for the execution of HaploCoV. We kindly invite users to read the  [manual](https://haplocov.readthedocs.io/en/latest) for a more thorough explanation of additional options (and configuration) of the workflow, and tips/instructions for how to make the best of each single tool in the package

<hr>

# How to interpret HaploCoV's results

The main output of HaploCoV consists in a file in .rep format. This is a simple text file that provides relevant information about novel (candidate) SARS-CoV-2 variants that demonstrated:

1. an increase in their "VOC-ness" score 
2. an increase in their prevalence (regionally or globally)
3. both

The report contains 3 main sections, which are briefly discussed below. Please refer to the manual if you need additional explanations.
The file "India_custom.rep" in the current repo, provides an example of .rep file. The file containts an analysis of "novel" variants in India, between 2021-01-01 and 2021-04-30, that is when the Delta and Kappa variant of SARS-CoV-2  emerged and started to spread in the country.

## Header and sections

Headers and sections of the file are specified/set by \"#\" symbols. The first 4 lines summarize the results by reporting the number of novel candidate variants that:

1. passed both the prevalence and score threshold
2. passed only the score threshold
3. passed only the prevalence thresholds

After the header, 3 distinct sections follow in the same order indicated by the above numbered least.  Each section is introduced by a # symbol, and concluded by the sentence: "A detailed report follows".
In the report each candidate lineage/variant is introduced by a # followed by a progressive number and its name. Names are according to the convention explained in the section "novel variants and names" of the manual: name of the parental, dot, one letter suffix(N by default), progressive number. I.e B.1.N1 descends from B.1 and so on.

Two distinct and complementary reports are provided for every variant

### Scores and novel genomic variants

This section reports the following information:

1. The parental lineage of a candidate variant (*Parent:*). The parental is the lineage/variant from which the lineage/variant defined by HaploCoV descends
As an example:

`Parent: B.1 ` indicates that the parental lineage is B.1

2. The VOC-ness score of the parental, and candidate new lineage/variant (*Score parent:* and *Score subV:* , respectively). The larger the difference between the 2 scores is, the more likely it is that the new lineage/variant should have "increased" VOC-like features. A difference of 10 or above in particular should be considered a strong indication, since in our experience score-differences of 10 or higher have been recorded only when comparing (known) VOC variants as defined by the WHO with their parental lineage.

An example of a output line is reported below:
`Score parent: 3.28 - Score subV: 15.10 `


3. A detailed comparison of the genomic variants gained or lost by the novel candidate lineage/designation w.r.t its parent. Which includes the following data:
<br>3.1. *defined by*: reports the complete list of defining genomic variants of the novel lineage/designation
<br>3.2. *gained (wrt parent)*: genomic variants that are new compared with the parent lineage
<br>3.3. *lost (wrt parent)*: genomic variants associated with the parent lineage/designation, but not with the novel candidate lineage/designation

Genomic variants are provided in as a list separated by " " and in the same format indicated above:
<br> 
\<genomicposition\>_\<ref\>\|\<alt\>  <br>
i.e. 1_A\|T indicates a A to T substitution in position 1 of the reference genome.<br>

An example ot the outout is reported below: 

`Genomic variants:`
        <br><br>`defined by: 210_G\|T 241_C\|T 3037_C\|T 4181_G\|T 21618_C\|G 22995_C|A 19220_C\|T `
        <br><br>`gained (wrt parent): 21618_C\|G 22995_C\|A 19220_C\|T `
        <br><br>`lost (wrt parent): `
        
In this case the novel candidate lineage/variant is defined by 3 additional genomic variants compared to its parental


### Prevalence

This part of the report summarizes the observed prevalence of novel candidate variants/lineages over a time span defined by the user(4 weeks by default) at different locales. The aim is to identify/flag variants that had a high prevalence (default 1% or more) and which demonstrated a significant increase in their spread (2 fold or more).
Please refere to the manual, and specifically to "Prevalence report" for detailed instructions on how the prevalence of a variant is computed and reported by HaploCoV, and more importantly for how to set parameters according to your needs.
The prevalence report comprises 3 sections.

### Prevalence above the threshold (1% by default)

Here we report the number of distinct intervals and the complete list of locales where/when a prevalence above the minimum prevalence threshold was observed.

For example:
<br>`AsiaSO::India::Delhi:5 AsiaSO::India::WestBengal:1`

Indicates that the novel candidate lineage/variant had a prevalence above the minimum cut-off value at 5 distinct intervals in Delhi and at only a single interval in 
West Bengal


### Increase (2 fold by default)

For every interval/span of time (default 4 weeks) where the novel candidate lineage/variant was had a prevalence above the user defined threshold, and an increase of X folds (X=2 by default) or higher the prevalence this section reports:

The place were the increase was observed, the prevalence at the initial time point of the interval, and the prevalence at the last time point of the interval

For example:
<br>`Interval: 2021-04-01 to 2021-04-28, increase at 1 locale(s) `<br>
 <br>`List of locale(s): AsiaSO::India::Delhi:0.03-(76),0.08-(117)`<br>

Indicates that in the interval of time comprised between April 1rst and April 28th, at Dehli the candidate lineage/variant increased its prevalence from 0.03 (3%) to 0.08 (8%). The numbers in brackets, 76 and 117 respectively, indicate the total number of genomic sequences used to estimate the prevalence

The sentence ` The candidate variant/lineage did not show an increase in prevalece greater than the threshold at any interval or locale
` is used when no data are available and/or the novel variant did not show an increase in its prevalence.

### Prevalence in time

This section reports the latest prevalence of the candidate variant/lineage as estimated by HaploCoV. For example:
<br>`Latest prevalence:`<br>
        <br>`AsiaSO 2021-04-30 0.0294-(136)`<br>
        <br>`AsiaSO::India 2021-04-30 0.0294-(136)`<br>

indicates that the latest prevalence of the candidate lineage/variant at April 30th 2021, was 0.029 (~3%) in South Asia and India. 

<hr>

# What to do next

If you identified a novel variant of SARS-CoV-2 with "interesting" genomic features, you should probably report the variant to Health authorithies in your country and to the scientific community.<br>
Normally https://virological.org/ or https://github.com/cov-lineages/pango-designation/issues/ would be the right place to start.
If the novel candidate variant was identified by HaploCoV, HaploCoV.pl (see --varfile option) or augmentClusters.pl (see HaploCoV: tools) should/could have provided a file with the complete list of genomic variants that define your novel lineage/lineages of interest.
It might be worthwile to add this/these definitions to your favourite "Genomics variant file" (see [here](https://haplocov.readthedocs.io/en/latest/genomic.html) and use assign.pl or p_assign.pl to re-assign genomic sequences using the augmented nomenclature.<br> 

If you need to extract the data (and metadata) of the novel candidate lineage/variant from a HaplocoV formatted metadata table (like for example the output of assign.pl), you can take advantage of the *subset.pl* utility in this repo.  The section *HaploCoV: advanced* of the manual illustrates some possible applications of this tool, and explains how to use it to extract data od interest. 
See [here](https://haplocov.readthedocs.io/en/latest/subsetting.html)<br>
Finally the increase.pl utility can be used to calculate the "prevalence" of your novel/candidate variant/variants, in space and time and derive global patters (if any and if your novel designations was not already derived from the analysis of all the available genome sequences). 
All these topics are covered in the manual of HaploCoV. Please take a look to the manual in order to see how to make the best of the tools and utilities.

<hr>

### If you are reading this, you have made your way through the manual! 
### Congratulations and regards! The HaploCoV "development team"
