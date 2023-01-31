# HaploCoV: a set of utilities and methods to identify novel variants of SARS-CoV-2

## Important
Please be aware that this readme covers only the standard set-up and execution of HaploCoV. An extended manual, with a more complete overview of the tool and parameters is available at [readthedocs](https://haplocov.readthedocs.io/en/latest/).

## What this tool can do for you

HaploCoV is a collection of Perl scripts that can be used to:
1. **align** complete assemblies of SARS-CoV-2 genomes with the reference genomic sequence and **identify genomic variants**; 
2. pinpoint **regional variation** and flag genomic variant with **"increased frequency"** locally or globally;  
3. **identify epidemiologically relevant variants and/or novel lineages/sub-lineages of the virus** (using a custom scoring system); 
4. **extend an existing classification system** to include novel designations/variants;
5. and to **classify** one or more genomes according to the method described in [Chiara et al 2021](https://doi.org/10.1093/molbev/msab049) and/or any other classification system of your choice. 

## HaploCoV

This software package is composed of **9 (*+3*)** utilities. Instructions concerning required input files, their format and how to configure HaploCoV are reported below (and in the extended [manual](https://haplocov.readthedocs.io/en/latest/) at readthedocs).
<br>
In brief, input files need to be formatted according to the format used by HaploCoV by applying either *addToTable.pl* or *NexStrainToHaploCoV.pl* (depending on the input, see below). 
Then the complete HaploCoV workflow can be executed by running *HaploCoV.pl* (recommended) or, if you prefer, by running each tool yourself (please see [HaploCoV:Tools](https://haplocov.readthedocs.io/en/latest/impatient2.html)).
The figure below provides a conceptual representation of the workflow and the tools used to execute each task in HaploCoV.
![image](https://github.com/matteo14c/HaploCoV/blob/a1d84694e38ce87341ce523d4ec28a56c4be7ef7/images/wf.png).


### Aim and rationale

The main aim of HaploCoV is to facilitate the identification of novel variants/lineages of SARS-CoV-2 showing:
1. An increase in their prevalence (regional, national or global);
2. Features associated with VOCs/VOIs (variants of concern or variants of interest);
3. Both of the above.

HaploCoV incorporates a standalone "scoring system" (*VOC-ness score* from here onward) for the identification and flagging of VOC and VOI-like variants based on the functional annotation of the genome. Interesting/relevant candidate variants are identified as those showing a significant increase (above a minimum threshold) in their score compared with their parental lineage/variant. The suggested minimum treshold is 2.5 or 10% of the total score of the parental lineage (whichever is higher, see the paper for more details). 

Increase/decrease in prevalence is inferred by analyses of the (available) metadata. By default novel candidate variants with a prevalence above 1% in a region/country, and showing an increase by at least 2 fold over 4 weeks are reported. 
These parameters can be configured by the user at runtime.

The main output consists of a report file that summarizes the prevalence and features (as defined by the criteria outlined above) of novel candidate variants of SARS-CoV-2.  

<hr>

# How to run HaploCoV in brief
 
### GISAID data
1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `.

### Nexstrain data
1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `.

### then

2. ` perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `.

### Finally
Read the report (.rep) file, the name will *be Italy_custom.rep* in this case.
Check out any interesting/additional novel variant that was identified and
(optional) read the full manual for more details on intermediate files and output formats.
See the following sections for a brief explanation.

<hr>

## Input files

HaploCoV requires 3 (main) input files:
* **the reference assembly** of the SARS-CoV-2 genome in fasta format;
* a **multifasta** file with SARS-CoV-2 genomes to be compared with the reference;
* a **.tsv** file with matched (to the sequences in the fasta file) metadata;
See the [Where do I get the data?](https://haplocov.readthedocs.io/en/latest/data.html) in the extended manual instructions on how to obtain these files.

If you find any of this software useful for your work, please cite:
>**Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.**

Should you find any issue, please contact me at matteo.chiara@unimi.it, or open an issue here on github.
<hr>


## Running HaploCoV

## #1 Compile a metadata table in HaploCoV format

All the tools and utilities in HaploCov operate on a large table in tsv format (*HaploCoV format* from here onward). 
If you obtained your data from **GISAID** you can format your data in *Haplocov format* by using the *addToTable.pl* utility. If data were obtained from NextStrain, you can use *NextStrainToHaploCov.pl* instead (see below).

## *HaploCoV format* for metadata
An example of the data format used by HaploCoV (*HaploCoV format*) is reported in the table below:

column 1 |column 2 |column 3 |column 4 |column 5 |column 6 |column 7 |column 8 |column 9 |column 10 |column 11 |
---------|---------|---------|---------|---------|---------|---------|---------|---------|----------|----------|
genome ID|collection date|offset days from collection|deposition date| offset days from deposition|continent|macro-geographic region|country|region|lineage|list of genomic variants|

The file is delineated by tabulations. Genomic variants are reported in the form of a comma separated list. 
The format is as follows: <br> 
\<genomicposition\>_\<ref\>|\<alt\>  <br>
i.e. 1_A|T indicates a A to T substitution in position 1 of the reference genome.<br>

A valid example of an HaploCoV-formatted file, including all the sequences available in INSDC databases up to 2022-07-20 is available at the following link: [HaploCoVFormatted.txt](http://159.149.160.88/HaploCoVFormatted.txt.gz) in the form of a `gzip` compressed file. When de-compressed the file should be around 2.9G in size, or alternatively see the Use cases sections, below. 

## #1.1 GISAID data: addToTable.pl

*addToTable.pl* reads multifasta (*sequences.fasta*) and metadata files (*metadata.tsv*) and extracts all the information required for subsequent analyses. Currently the tool supports both complete dumps of the GISAID database (see [here](https://haplocov.readthedocs.io/en/latest/data.html#gisaid)), and data packages in Augur format (see [here](https://haplocov.readthedocs.io/en/latest/data.html#gisaid-augur)).

### Options
*addToTable.pl* accepts the following options:

* **--metadata**: input metadata file (typically metadata.tsv from GISAID);
* **--seq**: fasta file;
* **--nproc**: number of threads. Defaults to 8;
* **--dayFrom**: include only genomes collected after this day;
* **--outfile**: name of the output file.

### Execution:
An example command looks like:
<br>`perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `.<br>
The final output will consist of a metadata table in *HaploCoV format*.  This table is required in all the subsequent analyses.

### Important: Incremental addition of data
*addToTable.pl* can add novel data/metadata incrementally to a pre-existing table in *HaploCoV format*. This feature is extremely useful, since it allows users to add data incrementally, without the need to re-execute analyses from scratch. When the output file provided by the user is not empty, addToTable.pl will process only those genomes which are not already included in your metadata table. Matching is by sequence identifier (column Virus name).

### Execution times 
On a single processor HaploCoV can process about 20k SARS-CoV-2 genomes per hour. Computation scales linearly: 160k genomes on 8 cores, or 320k on 16 cores. This means that processing the complete collection of the more than 13M genomes included in the GISAID database on November 11th 2022 from scratch would take about 20 days if only one processor is used;  3 days would be needed if 8 processes are used; and 1.5 days if 16 are used. Importantly this operation needs to be performed only once, since the tool features incremental addition of data (see above). 

## NextStrain data: NextStrainToHaploCoV.pl

If you downloaded your metadata files from Nexstrain ([link](https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz)), you need to use the utility *NextStrainToHaploCoV.pl* to convert them in HaploCoV format.
Unlike *addToTable.pl*, *NextStrainToHaploCoV.pl* does not support incremental addition of data to a pre-existing file: this metadata file can be converted in *HaploCoV format* less than 10 minutes. 

### Options
*NextStrainToHaploCoV.pl* accepts the following options:
* --metadata: name of the input file;
* --outfile: name of the output file.

## Execution

An example of a valid command line for *NextStrainToHaploCoV.pl* is as follows:

` NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

The output file *linearDataSorted.txt* will be in *HaploCoV format*.

## #2 Use *HaploCoV.pl* to apply the full pipeline

### *HaploCoV.pl*

Once data has been converted in HaploCoV format, the complete workflow can be executed by applying *HaploCoV.pl*.<br> 
*HaploCoV.pl* is the workhorse of HaploCoV and is the recommended way to execute our software.<br> 
Users can specify a list of geographic regions/areas or countries and intervals of time to be considered in their analyses by providing a configuration file in text format (--locales).<br> 
*HaploCoV.pl* will process the configuration file and apply the complete workflow to each entity therein included. For every distinct country, area or region results will be provided in the form of an individual report (.rep) file. 
This .rep file will contain a list of candidate SARS-CoV-2 variants/lineages showing a significant increase of their *VOC-ness score* and/or prevalence, and which are probably worth to be monitored. More details on the interpretation of this report are provided in the section [How to interpret HaploCoV's results](https://haplocov.readthedocs.io/en/latest/haplocov.html#how-to-interpret-haplocov-s-results) of the manual.<br>

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

### Configuration (I) (Locales files)

Locale(s) configuration files are used by *HaploCoV.pl* to set the main parameters for the execution of your analyses. These files need to have a tabular format and contain 5 colums separated by tabulations. An example of a valid locales file is illustrated below:

location|qualifier|start-date|end-date  |genomic-variants|
--------|---------|----------|----------|----------------|
Italy   |country  |2022-01-01|2022-11-11|areas_list.txt  |
Thailand|country  |2022-01-01|2022-11-11|custom          |
world   |area     |2022-01-01|2022-11-11|custom          |

* location: a country, a region or a macrogeographic area (see [Geography and places](https://haplocov.readthedocs.io/en/latest/metadata.html#geography-and-places) in the manual) for more details;
* qualifier: qualifier of the geographic entity, accepted values are: region, country or area. Again, refer to [Geography and places](https://haplocov.readthedocs.io/en/latest/metadata.html#geography-and-places) for more details;
* start-date: lower limit of the interval of time on which to execute the analysis (see [Dates and time in HaploCoV](https://haplocov.readthedocs.io/en/latest/metadata.html#dates-and-time-in-haplocov));
* end-date: upper limit of the interval of time;
* genomic-variants: a comma separated list of files with high frequency genomic variants (see  [Genomic variants file](https://haplocov.readthedocs.io/en/latest/haplocov.html#genomic-variants-files-configuration-ii)). Each file is used to derive novel candidate lineages/variants compared to a reference nomenclature. If you do not wish to use a precomputed file, you can use the special word *custom*. High frequency genomic variants will be computed by HaploCoV based on your selection.  A distinct report file (.rep) will be generated for every file in this list. The name of the genomic variant file is always appended to the name of the report, i.e. if the name of your genomic variants file is \"myVar\" the name of the report will be "\_myVar.rep" if instead *custom* was used, the name will be "\_custom.rep" (see below).

The file locales.txt included in this repository provides a valid example of a locales configuration file. 

### Output (and intermediate files folder)

The name of the main output by *HaploCoV.pl* is set automatically by the program by combining the value provided in the "location" (1rst) column, with value/values reported in the "genomic-variants" (5th) column of your locales configuration file. In the example above 3 different output files will be obtained:

* Italy_areas_list.txt.rep
* Thailand_custom.rep
* world_custom.rep

Each execution of HaploCoV usually generates several temporary/intermediate files. Normally you will not need to read/process/use these files, however for your convenience, all the intermediate files will be in be saved in a distinct folder. The same conventions applied for naming the main output files is used also to give names to the  intermediate folders. 
In the example outlined above, indermediate files will be saved in 3 different folders, called:

* Italy_areas_list.txt_results
* Thailand_custom_results
* world_custom_results

The section [Intermediate files and what to make of them](https://haplocov.readthedocs.io/en/latest/haplocov.html#intermediate-files-and-what-to-make-of-them) in the manual provides a more complete description of all the intermediate output files that you will find in this folder.

<hr>

### Configuration II (genomic variants files)

HaploCoV uses collections of genomic variants with high frequency in a specific country/region/locale to define and identify novel candidate variants/lineages of SARS-CoV-2.<br> 
For your convenience, a collection of pre-computed files is available in this github repository. If you want to use one of these files, you simply have to enter the file/files name in the fifth column of your *locales* configuration file. HaploCoV will detect the file and run all the analyses. 

Precomputed sets of genomic variants/files can broadly be categorized into 4 main classes:

1. *Highly variable genomes.* These are genomic variants found in at least 25 "highly divergent" genomic sequences (w.r.t the reference Pango lineage to which they are assigned). These files are stored under the folder: HighVar.
2. *Country specific genomic variants.* Genomic variants reaching a frequency of 1% or higher, for at least 15 days in a country at any time point from Mon 2019-12-30. These files are stored under the folder: country. 
3. *Increased prevalence genomic variants.* Genomic variants showing an increase in their prevalence of a 1.5 fold or greater in at least one country, at different months, and starting from January 2020. These files are stored under the folder: HighFreq. 
4. *globally frequent genomic variants*. These are provided in the main github repository of HaploCoV, and include: 
*global_list.txt*: frequent worldwide, *areas_list.txt*: frequent at at least one macro-geographic area and *country_list.txt*: frequent at at least one county.

Please see the section [Genomic variants file](https://haplocov.readthedocs.io/en/latest/genomic.html) for additional information. 

Alternatively, if the pre-computed files do not suit their use case, users do also have the option to derive "custom" sets of genomic variants by analysing the selected locale and time-frame only. In this case the keyword *custom* needs to be indicated in the 5th column, and high frequency genomic variants will be computed on the current selection.   

### Note: special/reserved keywords

When the reserved word *world*  is used in the 1rst column of your locales all the sequences in the metadata file will be analysed irrespective of the geographic origin.

In the 5th column (genomic-variants) you can use the reserved word *custom* if you need to re-compute high frequency genomic variants based on your selection of genomic sequences, instead of using a pre-computed genomic-variant file provided by HaploCoV. This option allows more flexibility. When *custom* is specified, high frequency genomic variants are determined dynamically based on the user selection. Please see the [Genomic variants file](https://haplocov.readthedocs.io/en/latest/genomic.html) in the manual for additional explanations.

### Configuration III (parameters file)

*HaploCoV.pl* executes all the tools and utilities in the HaploCoV workflow to derive novel candidate additional designations of SARS-CoV-2 variants. As you can see from the manual at [readthedocs](https://haplocov.readthedocs.io/en/latest/impatient2.html) this workflow is relatively complex, and every tool has several parameters.
The value of each parameter can be set by providing to HaploCoV a parameters file, with the *--param* option. Parameters files are used by HaploCoV to set the configuration of all the tools.
The default is to use the file *parameters* that you can find in the main repository. This file provides default parameters for the execution of HaploCoV. The file can be modified with a simple text editor. The file *parametersDetailed* in this repository, provides the full list of parameters that can be set.

The format is quite straightforward, each tool is indicated in a line, and the parameters to be set in the following lines. Values are separate by tabulations. Comments need to be prepended with an "#" symbol.
When no parameters are specified the default values are used. In example:

<br> `#use the defaults for computeAF.pl `
<br> `computeAF.pl ` 
<br> `#provide some parameters for augmentClusters.pl `
<br> `augmentClusters.pl ` 
<br> `--size  10 ` 
<br> `--dist  4 `

will set *computeAF.pl* to use its default parameters; 
while for *augmentClusters.pl* --dist will be set to 4 and --size to 10.

Please refer to this section of the extended manual for additional explanations on parameters [files](https://haplocov.readthedocs.io/en/latest/haplocov.html#parameters-file-configuration-iii).

### Advanced configuration

This readme covers only the standard/basic requirements for the execution of HaploCoV. We kindly invite users to read the [manual](https://haplocov.readthedocs.io/en/latest) for a more thorough explanation of additional options (and configuration) of the workflow, and tips/instructions for how to make the best of each single tool.

<hr>

# How to interpret HaploCoV's results

The main output of HaploCoV consists of a file in .rep format. This is a simple text file that provides relevant information about novel (candidate) SARS-CoV-2 variants that demonstrated:

1. an increase in their *VOC-ness* score; 
2. an increase in their prevalence (regionally or globally);
3. both of the above.

The report contains 3 main sections, which are briefly discussed below. Please refer to the manual if you need additional explanations.
The files "India_custom.rep", "EuUK_custom.rep", and "SouthAfrica_custom.rep" in the useCases folder, provide some example of a .rep file. Please see the Use Cases section below and in the manual for more info. 
The files are in simple text format, and cand be inspected with any text editor of your choice.

## Header and sections

Headers and sections of a .rep file are specified/separated by \"#\" symbols. The first 4 lines summarize the results by reporting the number of novel candidate variants that:

1. passed both the prevalence and score threshold;
2. passed only the score threshold;
3. passed only the prevalence thresholds.

After the header, 3 distinct sections follow in the same order indicated by the above numbered list.  Each section is introduced by a "#" symbol, and concluded by the sentence: "A detailed report follows".
In the report each candidate lineage/variant is introduced by a # followed by a progressive number and its name. Names are according to the convention explained in the section [Novel designations](https://haplocov.readthedocs.io/en/latest/genomic.html#novel-designations) of the manual, and are formed by juxtaposing:

* the `name of the parental lineage`;
* a `.`; 
* a `one letter suffix(N by default)`;
* `progressive number`. 

I.e B.1.N1 descends from B.1 for example.

The report includes two distinct and complementary sections. The first section reports information about the *VOC-ness* score and on the defining genomic variants that prompted the identification of the novel candidate viral varianr/lineage, the second section summarizes its prevalence at the geographic locales specified by the user. Only places where a minimum prevalence threshold (1% by default) is reached are included.

### Scores and novel genomic variants

This section reports the following information:

1. The parental lineage of a candidate variant (*Parent:*). The parental is the lineage/variant from which the lineage/variant defined by HaploCoV descends.
As an example:

`Parent: B.1 ` indicates that the parental lineage is B.1

2. The *VOC-ness score* of the parental, and candidate new lineage/variant (*Score parent:* and *Score subV:*, respectively). The larger the difference between the 2 scores is, the more likely it is that the new lineage/variant should have "increased" VOC-like features. A difference of 10 or above in particular should be considered a strong indication, since in our experience score-differences of 10 or higher have been recorded only when comparing (known) VOC variants as defined by the WHO with their parental lineage.

This in an example of an output line:
`Score parent: 3.28 - Score subV: 15.10 `


3. A detailed comparison of the genomic variants gained or lost by the novel candidate lineage/designation w.r.t its parent. Which includes the following data:
<br>3.1. *defined by*: reports the complete list of defining genomic variants of the novel lineage/designation;
<br>3.2. *gained (wrt parent)*: genomic variants that are new compared with the parent lineage;
<br>3.3. *lost (wrt parent)*: genomic variants associated with the parent lineage/designation, but not observed in the novel candidate lineage/designation;

Genomic variants are provided as a list separated by " " and in the same format indicated above:
<br> 
\<genomicposition\>_\<ref\>\|\<alt\>  <br>
i.e. 1_A\|T indicates a A to T substitution in position 1 of the reference genome.<br>

An example of the output is reported below: 

`Genomic variants:`
        <br>`defined by: 210_G\|T 241_C\|T 3037_C\|T 4181_G\|T 21618_C\|G 22995_C|A 19220_C\|T `
        <br>`gained (wrt parent): 21618_C\|G 22995_C\|A 19220_C\|T `
        <br>`lost (wrt parent): `
        
In this case the novel candidate lineage/variant is defined by 3 additional genomic variants compared to its parental.


### Prevalence

This part of the report summarizes the observed prevalence of novel candidate variants/lineages over a time span defined by the user(4 weeks by default) at different locales. The aim is to identify/flag variants that had a high prevalence (default 1% or more) and which demonstrated a significant increase in their spread (2 fold or more).
Please refer to the manual, and specifically to [Prevalence report](https://haplocov.readthedocs.io/en/latest/increase.html) for detailed instructions on how the prevalence of a variant is computed and reported by HaploCoV, and more importantly for how to set parameters according to your needs.
The prevalence report comprises 3 sections.

### Prevalence above the threshold (1% by default)

Here we report the number of distinct intervals and the complete list of locales where/when a prevalence above the minimum prevalence threshold was observed.

For example:
<br>`AsiaSO::India::Delhi:5 AsiaSO::India::WestBengal:1`

Indicates that the novel candidate lineage/variant had a prevalence above the minimum cut-off value at 5 distinct intervals in Delhi and at only a single interval in 
West Bengal.

### Increase (2 fold by default)

For every interval/span of time (default 4 weeks) where the novel candidate lineage/variant had a prevalence above the user defined threshold and an increase of X folds (X=2 by default) or higher in prevalence, this section reports:

The place were the increase was observed, the prevalence at the initial time point of the interval, and the prevalence at the last time point of the interval

For example:
<br>`Interval: 2021-04-01 to 2021-04-28, increase at 1 locale(s) `
 <br>`List of locale(s): AsiaSO::India::Delhi:0.03-(76),0.08-(117)`<br>

Indicates that in the interval of time comprised between April 1rst and April 28th, at Dehli the candidate lineage/variant increased its prevalence from 0.03 (3%) to 0.08 (8%). The numbers in brackets, 76 and 117 respectively, indicate the total number of genomic sequences used to estimate the prevalence.

The sentence ` The candidate variant/lineage did not show an increase in prevalece greater than the threshold at any interval or locale
` is used when no data are available and/or the novel variant did not show an increase in its prevalence.

### Prevalence in time

This section reports the latest prevalence of the candidate variant/lineage as estimated by HaploCoV. For example:
<br>`Latest prevalence:`
        <br>`AsiaSO 2021-04-30 0.0294-(136)`
        <br>`AsiaSO::India 2021-04-30 0.0294-(136)`<br>

indicates that the latest prevalence of the candidate lineage/variant at April 30th 2021, was 0.029 (~3%) in South Asia and India. 

<hr>

# Use Cases

The folder *useCases* in the main repository provides a collection of files and examples that can be used to test HaploCoV for the identification of novel variants of SARS-CoV-2. Three use cases are provided, all associated with emergence of a VOC:

1. Alpha in the UK;
2. Delta in India;
3. Omicron in South Africa.

For every use case only genomic sequences collected within an interval compatible with the emergence of each VOC, and from the country where each VOC was first reported, were extracted from the complete dataset of publicly available SARS-CoV-2 genome sequence (Nexstrain data). Subsequently, all the genomes assigned to VOC-related lineages were manually re-assigned to the B.1.1 lineage. Finally, HaploCoV was applied to verify if VOC lineages could be re-intified from scratch.
Users are kindly invited to re-run/re-proccess these data to test the main functionalities of HaploCoV.

Please notice that since publicy avaliable data include only about 36% of the complete collection of genomic sequences available in GISAID, default parameters were adjusted to cope with the reduced number of sequences. In particular the number of supporting genomic sequences required to form a designation was lowered to 25 (parameters file paramVOC).

## Use case 1. Alpha

The file *alphaNX* contains a complete collection of the genomic sequences of SARS-CoV-2 specimens isolated in the United Kindgom between 2020-09-01 and 2020-11-15. The total number is 36820.
The following HaploCoV command was be used to process the file and derive novel variants:

` perl HaploCov.pl --file alphaNX --locales alpha.loc --param paramVOC `.

The locales file *alpha.loc* restricts the scope of the analysis to the United Kingdom (area=EuUK) and to sequences collected inbetween 2020-09-01 and 2020-11-15.
The final output of HaploCoV is written to the report file *EuUK_custom.rep*. Intermediate files will are stored in the folder: *EuUK_custom_results*. 
<br>

Please take a look to these sections in the manual at readthedocs (and above) for a more comprehensive explanation of these files and what they do: 

* [locales file](https://haplocov.readthedocs.io/en/latest/haplocov.html#configuration-locales-file); 
* [parameters file](https://haplocov.readthedocs.io/en/latest/haplocov.html#parameters-file-configuration-iii);
* [intermediate files](https://haplocov.readthedocs.io/en/latest/haplocov.html#id5);
* [report file](https://haplocov.readthedocs.io/en/latest/haplocov.html#id6)

As you can see from the figure below, according to the report.: \"5 novel candidate sublineage(s)/subvariant(s) \" were found by HaploCoV, but only 1 did pass both the score and prevalence threshold. This novel candidate lineage, designated as B.1.1.N1 is defined by 28 additional genomic variants compared to the parental lineage B.1.1, and is associated with an astounding increase in *VOC-ness* score of ~11 points. According to report, B.1.1.N1 shows an increase in prevalence from 1% (0.01) to 10% (0.1) in between 2020-10-21 and 2020-11-12, in the United Kingdom and in England.
Based on these observations is easy to infer that B.1.1.N1 corresponds with B.1.1.7, the first lineage of the Alpha VOC.

![image](https://github.com/matteo14c/HaploCoV/blob/b5558f609b95328b0af471d80e548e3bb0ae0f91/images/FigAlpha.jpeg)

A complete list of the genomic sequences assigned to the novel designation can be retrieved by applying the *subset.pl* tool (see [here](https://haplocov.readthedocs.io/en/latest/subsetting.html#select-a-specific-lineage-hg)) to *EuUK_assigned.txt* in the intermediate file folder *EuUK_custom_results* created by HaploCoV while processing the data.
The following command can be issued to select entries assigned to the novel lineage:

` perl subset.pl --infile EuUK_custom_results/EuUK_assigned.txt --lineage B.1.1.N1 --outfile novelLin `.
The output file should include 814 entries.

## Use case 2. Delta

*deltaNX* contains a total of 673 genomic sequences of SARS-CoV-2 isolated in the India between 2020-11-01 and 2021-05-01. 
By running: 

` perl HaploCov.pl --file deltaNX --locales delta.loc --param paramVOC `.

HaploCoV is applied to this dataset to derive novel variants; *delta.loc* specifies the country to be analysed (India) and the interval of time (2020-11-01 to 2021-05-01). Results will be written in the report file *India_custom.rep*, intermediate files to *India_custom_results*.
<br>
According to the output file (screenshot below), only one "interesting" variant was identified by HaploCoV in these settings: B.1.1.N1. The novel designation has 34 additional defining genomic variants compared with its parental. The VOC-ness score is increased from 4.42 to 18.58. 
Although the novel designation has a prevalence of almost 80% by 2021-04-28, a 2 fold increase in prevalence is not detected at any time point. 
<br>
The intermediate file *India_assigned.txt.prev* in the *India_custom_results* folder provides a more detailed picture of the spread of the novel designation (again, see screenshot).
According to this "extended" prevalence report, B.1.1.N1 is first observed at 2021-03-30, and shows a prevalence of ~ 45% by then (see screenshot). Although the prevalence of the variant grows rapidly, the increase is lower that 2 fold at the intervals of time included in the analysis.

![image](https://github.com/matteo14c/HaploCoV/blob/b5558f609b95328b0af471d80e548e3bb0ae0f91/images/FigDelta.jpeg).

This is probably due to the patchy pattern of available data. Indeed we observe that no prevalence is reported for several interval of time in *India_assigned.txt.prev*; this indicates that for several intervals less than 10 genomic sequences were available, 10 being the minimum number of sequences required by HaploCoV to do this computation (see [prevalence report](https://haplocov.readthedocs.io/en/latest/increase.html) in the manual for a more comprehensive explanation). 

## Use case 3. Omicron

*omicronNX* includes 1009 genomic sequences of SARS-CoV-2 isolated in the South Africa between 2021-07-01 and 2021-12-31. 
By running: 

` perl HaploCov.pl --file omicronNX --locales omicron.loc --param paramVOC `.

HaploCoV can be applied to analyse these data. According to the specfications provided by *omicron.loc* only isolates from South Africa, and in between 2021-07-01 and 2021-12-31 will be analysed.
Main results are saved to *SouthAfrica_custom.rep*. Intermediate files to *SouthAfrica_custom_results*.
Similar to use case 2, only one novel "insteresting" designation is identified by HaploCoV: B.1.1.N1. This novel designation is characterized by 58 genomic variants that are not shared with the parental. The VOC-ness score is increased from 3.50 to 21.82. 
According to the prevalence report, B.1.1.N1 has a prevalece above 95% (0.95) in South Africa by 2021-12-26. However B.1.1.N1 is not flagged as an "increased prevalence" variant, since it does not show an increase in prevalence of 2 fold or higher at any interval of time (see screenshot below).

![image](https://github.com/matteo14c/HaploCoV/blob/b5558f609b95328b0af471d80e548e3bb0ae0f91/images/FigOmic.jpeg).

The intermediate file *SouthAfrica_assigned.txt.prev* in the *SouthAfrica_custom_results* folder can be used to obtain more information about the prevalence of the newly defined designation.
From the report it is possible to observe that B.1.1.N1 is first identified by HaploCoV at 2021-11-22, and shows a prevalence greater than 86%. Similar to use case 2, also in this case the data are patchy and several intervals of tim have missing data. In this scenario the novel variant is not identified as a variant "showing and increase in prevalence" since it is already dominant/widespread by the time it is first identified.

<hr>

# What to do next

If you identified a novel variant of SARS-CoV-2 with "interesting" genomic features, you should probably report the variant to Health authorities in your country and to the scientific community.<br>

Normally [virological.org](https://virological.org/) or [Pango](https://github.com/cov-lineages/pango-designation/issues/) would be the right place to start.
If the novel candidate variant was identified by HaploCoV, *HaploCoV.pl* (see [--varfile](https://haplocov.readthedocs.io/en/latest/haplocov.html#designations-file)) or *augmentClusters.pl* (see [here](https://haplocov.readthedocs.io/en/latest/novel.html)) should/could have provided a file with the complete list of genomic variants that define your novel lineage/lineages of interest.
It might be worthwhile to add this/these definitions to your favourite *Genomics variant file* (see [here](https://haplocov.readthedocs.io/en/latest/genomic.html)) and use *assign.pl* or *p_assign.pl* to re-assign genomic sequences using the augmented nomenclature. *HaploCoV.pl* might already have done that for you, anyway (see [intermediate files](https://haplocov.readthedocs.io/en/latest/haplocov.html#id4)).<br> 

Whence the novel nomenclature is assigned, you can extract the data (and metadata) of the novel candidate lineage/variant from a HaploCoV formatted metadata table (like for example the output of *assign.pl*) by using the *subset.pl* utility included in this repo.  The section [Subsetting data](https://haplocov.readthedocs.io/en/latest/subsetting.html) of the manual illustrates some possible applications of this tool, and explains how to use it to extract data of interest (see also use case 1 above). <br>
Finally the *increase.pl* utility can be used to calculate the prevalence of your novel/candidate variant/lineages in space and time and derive global patterns (if any and if your novel designations was not already derived from the analysis of all the available genome sequences).<br>
All these topics are covered in the [manual](https://haplocov.readthedocs.io/en/latest/index.html) of HaploCoV. Please take a look at the manual in order to see how to make the best of the tools and utilities.

<hr>

### If you are reading this, you have made your way through the readme! 
### Congratulations and regards! The HaploCoV "development team"
