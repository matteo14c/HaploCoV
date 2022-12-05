HaploCoV.pl
===========

Once data have been converted in HaploCoV format, the complete workflow can be executed by applying **HaploCoV.pl**.
HaploCoV.pl is the workhorse of HaploCoV and is the recommended way to execute our software.

Users can specify a list of geographic **regions/areas or countries** and **intervals of time** to be considered in their analyses by providing a configuration file in text format (--locales, see next). 
HaploCoV.pl will process the configuration file and apply the complete workflow to each entity therein included. For every distinct country, area or region results will be provided in the form of a report (.rep) file.

This .rep file will contain a list of candidate SARS-CoV-2 variants/lineages showing a significant increase of their "VOCness score" and/or "prevalence", and which are probably worth to be monitored. More details on the interpretation of this report are provided in the sections "How to interpret HaploCoV's results/what to do next"

**Options**

HaploCoV.pl accepts the following options:

* *--file:* name of the input file (metadata file in HaploCoV format)
* *--locales:* configuration file with the list of regions and countries to analyse
* *--param:* configuration file with the set of parameters to be applied by HaploCoV in your analysis
* *--path:* path to your HaploCoV installation
* *--varfile:* additional file with defining genomic variants

**Execution**

An example of a valid command line is reported below:

::

 perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc

Since in this case the type of analysis was set to "custom" and the target geographic region to Italy (in italy.loc, see "Locales file" below). The final output will be reported in a file called \"Italy\_custom.rep\".

Configuration (Locales file)
============================

Locale(s) configuration files are used by HaploCoV.pl to set the main parameters for the execution of your analyses.
These files are used to configure the place/places and intervals of time that HaploCoV will include in the analyses. There is no limit to the maximum number of geographic locations, and time-frames that can be analysed. As outlined in the example below, however each need to be indicated by in a separate line in your configuration file.

Locales files need to have a tabular format and contain 5 colums separated by tabulations. The file locales.txt included in the Github repository provides a valid example of a locales configuration file. 

| An example of a valid locales file is illustrated below:
 
 .. list-table:: Locales File
   :widths: 35 35 50 50 70
   :header-rows: 1

   * - Heading location
     - Heading qualifier
     - Heading start-date
     - Heading end-date
     - Heading genomic-variants
   * - Italy
     - country
     - 2022-01-01
     - 2022-11-11
     - genomic-variants
   * - Thailand
     - country
     - 2022-01-01
     - 2022-11-11
     - custom
   * - world
     - area
     - 2022-01-01
     - 2022-01-01
     - custom

The file includes the following columns, in this set order:

1. **location**: a country, a region or a macrogeographic area (see "geography in HaploCoV")
2. **qualifier**: qualifier of the geographic entity, accepted values are: region, country or area. 
3. **start-date:** lower limit of the interval of time on which the analysis are executed (see "dates in HaploCoV")
4. **end-date:** upper limit of the interval of time
5. **genomic-variants:** a list of files with high frequency genomic variants. Comma separated. Each file is used to derive novel candidate lineages/variants compared to a reference nomenclature.  A distinct report file (.rep) is be generated for every file in this list. The name of the variant file is always appended to the name of the report, i.e if the name of your genomic variants file is *"myVar"* the name of the report will be *"_myVar.rep"* (see below).


Output (and intermediate files folder)
======================================

The name of the main output by HaploCoV.pl is set automatically by the program by combining the value provided in the *"location"* (1rst) column, with value/values reported in the *"genomic-variants"* (5th) column of your locales configuration file. In the example above 3 different output files will be obtained:

1. Italy_areas_list.txt.rep
2. Thailand_custom.rep
3. world_custom.rep

Each execution of HaploCoV usually generates several temporary/indermediate files. Normally you will not need to read/process/use these files, however for your convenience, all the intermediate files will be in be saved in a distinct folder. 

The same conventions applied for naming the main output files is used also to give names to the  intermediate folders. 
In the example outlined above, indermediate files will be saved in 3 different folders, called:

1. Italy_areas_list.txt_results
2. Thailand_custom_results
3. world_custom_results

Additional explanations concerning the intermediate files produced by HaploCoV and what to make of them are provided in the section: "Intermediate files and what to make of them."

Genomic variants files (Configuration II)
=========================================

HaploCoV uses collections of genomic variants with high frequency in a specific country/region/locale to define and identify novel candidate variants/lineages of SARS-CoV-2.

For your convenience, a collection of *"pre-computed"* files is available in the main repository. If you want to use one of these files, you simply have to enter the file/files name in the fifth column of your *"locales"* configuration file. HaploCoV will detect the file and run all the analyses for you. 

Precomputed sets of genomic variants/files can broadly be categorized into 3 main classes:

1. **Highly variable genomes.** These are allelic variants found in at least 25 *highly divergent* genomic sequences (w.r.t the reference strain to which they are assigned). These files are stored under the folder: **HighVar**.
2. **Country specific genomic variants.** Genomic variants reaching a frequency of 1% or higher, for at least 15 days in a country at any time point from Mon 2019-12-30. These files are stored under the folder: **country**. 
3. **Increased prevalence genomic variants.** Genomic variants showing an increase in their prevalence of a 1.5 fold or greater in at least one country, at different months, and starting from January 2020. These files are stored under the folder: **HighFreq.** 

Please se the section "Genomic variation and high frequency (genomic) variants" above for additional information. 

If the pre-computed files do not suit their use case, users do also have the option of derive **custom** sets of genomic variants by analysing the selected locale and time-frame only. In this case the keyword **custom** needs to be indicated in the 5th column of the *locales* file (see below). High frequency genomic variants will be computed based on the current selection.   

Locales: special/reserved keywords
==================================

When the reserved word **world** is used in the 1rst column of your locales all the sequences in the metadata file will be analysed irrespective of the geographic origin.

In the 5th (genomic-variants) you can use the reserved world **custom** if you need to re-compute high frequency genomic variants based on your selection of genomic sequences, instead of using a pre-computed allele-variant file provided by HaploCoV. This option allows more flexibility. When **custom** is specified high frequency genomic variants are determined dynimically based on the user selection.

Advanced configuration
=======================

HaploCoV.pl executes all the tools and utilities in HaploCoV for you and in the right order. However, the workflow is relatively complex, and every tool uses a series of parameters that need to be set, or are set by default.
The **parameters** file is a special configuration file that can be used to set and configure all the parameters used by each and every single tool in the workflow.
A default file with a standard configuration (called **parameters**) is included in the main repository. This file should suit most use case/scenario. However users are free to edit it according to their needs.

The format is quite straightforward, each tool is indicated by in a line, and the parameters to be set in the following lines. When no parameters are specified, the defaults are used In example:

| ``computeAF.pl`` 
| ``augmentClusters.pl`` 
| ``--size  10`` 
| ``--dist  4``
|

will set *computeAF.pl* to use its default parameters; 
while for *augmentClusters.pl* --dist will be set to 4 and --size to 10.

For a complete list of all the parameters accepted by every tool, please refer to the corresponding section in the manual.


Defining genomic variants file
==============================

The --varfile option can be set instuct HaploCoV to report an additional file with the list of novel candidate SARS-CoV-2 variants identified by the tool, and the set of their defining genomic variant.

--varfile can be set to one of 3 possible values:

* "n" the additional/ancillary file is not produced (default);
* "b" the additional file is produced, only variants that passed both the thresholds (score and prevalence) are reported 
* "a" the additional file is produces, variants that passed any of the thresholds (score or prevalence) are reported 

For a more extendend explanation of the meaning, format and possible usage/application of this output file, users are kindly invited to read the section: "Genomic variants file".


Intermediate files and what to make of them
===========================================

For every run of HaploCoV and a folder with 6 indermediate files will be created (see above). Although, normally you are not required to use these files, a brief explanation concerning their meaning and content is reported in the following section.
All these files are produced by different tools in the HaploCoV workflow. More detailed explanations can also be found in the corresponding (to each tool) section in the manual. 

Indermediate files produced by HaploCoV.pl (prefix of the name might change according to the input file, suffix are reported):

| 1. *areas_list.txt* : this file is produced by computeAF.pl. It reports the complete list of genomic variants of high frequency (above 1% for more than 30 days by default) that were identified by analising the interval of time and geographic locales included in your "locales" file. This file is produced only if the type of analysis (5th column of your locales file is set to custom.
| 2. *\_results.txt* : the file with this suffix, is the result of augmentClusers.pl, and includes all the designations (already included in the nomenclature of novel) that were identified by that tool. Names of candidate novel lineages/variants are according to the conventions defined in *Novel variants and names*
| 3. *\_assigned.txt* : this file is produced by assign.pl. Following the identification of novel candidates lineages/variants, HaploCoV re-assigns all the genomes included in your analyses using the additional designation. Results are saved in this file. The file is in *HaploCoV* format, the lineage/designation assigned to each genome is updated.
| 4. *\_features.csv* : this file reports *high level* genomic features associated with each lineage/candidate lineage included in the \_results.txt file. Features are computed
| 5. *\_PASS.csv* : reports the VOC-ness score computed by report.pl for every lineage/new candidate lineage included in \_results.txt
| 6. *\_txt.prev*: provided the prevalence report computed by *increase.pl* Prevalence data are computed only for the lineage/candidate lineages included in *\_results.txt* and only at the locales and time-intervals included in the analysis


How to interpret HaploCoV's results
===================================

The main output of HaploCoV consists in a file in .rep format. This is a simple text file that provides relevant information about novel (candidate) SARS-CoV-2 variants that demonstrated:

1. an increase in their "VOC-ness" score 
2. an increase in their prevalence (regionally or globally)
3. both

The report contains 3 main sections, which are discussed below. 
The file "India_custom.rep" in main HaploCoV repository, provides an example of .rep file. The file containts an analysis of "novel" variants in India, between 2021-01-01 and 2021-04-30, that is when the Delta and Kappa variant of SARS-CoV-2 emerged and started to spread in the country.

Header and sections
===================

Headers and sections of a .rep file are specified/set by *"#"* symbols. The 4 first lines summarize the results by reporting the number of novel candidate variants that:

1. passed both the prevalence and score threshold
2. passed only the score threshold
3. passed only the prevalence thresholds

After the header, 3 distinct sections follow in the same order indicated by the above numbered list.  

Each section is introduced by a *"#"* symbol, and concluded by the sentence: **"A detailed report follows"**.
In the report each candidate lineage/variant is introduced by a # followed by a progressive number and its name. 
Names are according to the convention explained in the section "Novel variants and names", briefly: 

``name of the parental`` , ``dot`` , ``one letter suffix(N by default)`` , ``progressive number`` . 

| I.e **B.1.N1** descends from **B.1** and so on.

Main features of the newly identified lineages/variants are reported in two conceptually distinct sections: **Scores** and **Prevalence** 

Scores and novel genomic variants
=================================

Reports the following information:

1. The parental lineage of a candidate variant (**Parent:**). The parental is the lineage/variant from which the lineage/variant defined by HaploCoV descends
As an example:

``Parent: B.1`` indicates that the parental lineage is B.1

2. The VOCness score of the parental, and candidate new lineage/variant (**Score parent:** and **Score subV:** , respectively). The larger the difference between the 2 scores is, the more likely it is that the new lineage/variant should have "increased" VOC-like features. A difference of 10 or above in particular should be considered a strong indication, since in our experience score-differences of 10 or higher have been recorded only when comparing (known) VOC variants as defined by the WHO with their parental lineage.

An example of a output line is reported below:

| ``Score parent: 3.28 - Score subV: 15.10`` 

3. A detailed comparison of the genomic variants gained or lost by the novel candidate lineage/designation w.r.t its parent. Which includes the following data:
| 3.1. **defined by**: reports the complete list of defining genomic variants of the novel lineage/designation 
| 3.2. **gained (wrt parent)**: genomic variants that are new compared with the parent lineage
| 3.3. **lost (wrt parent)**: genomic variants associated with the parent lineage/designation, but not with the novel candidate lineage/designation

Genomic variants are provided in as a list separated by " " and in the same format indicated above:

\<genomicposition\>_\<ref\>\|\<alt\> 

| i.e. 1_A\|T indicates a A to T substitution in position 1 of the reference genome.

An example ot the outout is reported below: 

| ``Genomic variants:`` 
| 
|  ``defined by: 210_G\|T 241_C\|T 3037_C\|T 4181_G\|T 21618_C\|G 22995_C|A 19220_C\|T`` 
| 
|  ``gained (wrt parent): 21618_C\|G 22995_C\|A 19220_C\|T`` 
| 
|  ``lost (wrt parent):`` 
        
In this case the novel candidate lineage/variant is defined by 3 additional genomic variants compared to its parental


Prevalence
==========

This part of the report summarizes the observed prevalence of novel candidate variants/lineages over a time span defined by the user(4 weeks by default) at different locales. The aim is to identify/flag variants that had a high prevalence (default 1% or more) and which demonstrated a significant increase in their spread (2 fold or more).
Please refere "increase.pl" for more detailed instructions on how the prevalence of a variant is computed and reported by HaploCoV, and more importantly for how to configure and set parameters.
The prevalence report comprises 3 sections.

**Prevalence above the threshold (1% by default)**

Here we report the number of distinct intervals and the complete list of locales where/when a prevalence above the minimum prevalence threshold was observed.

For example:

| ``AsiaSO::India::Delhi:5 AsiaSO::India::WestBengal:1`` 

Indicates that the novel candidate lineage/variant had a prevalence above the minimum cut-off value at 5 distinct intervals in Delhi and at only a single interval in West Bengal


**Increase (2 fold by default)**

For every interval/span of time (default 4 weeks) where the novel candidate lineage/variant had a prevalence above the user defined threshold, and an increase of X folds (X=2 by default) or higher, this section reports:
* the place were the increase was observed; 
* the prevalence at the initial time point of the interval; 
* and the prevalence at the last time point of the interval;

For example:

| ``Interval: 2021-04-01 to 2021-04-28, increase at 1 locale(s)`` 
| ``List of locale(s): AsiaSO::India::Delhi:0.03-(76),0.08-(117)`` 

Indicates that in the interval of time comprised between April 1rst and April 28th, at Dehli the candidate lineage/variant increased its prevalence from 0.03 (3%) to 0.08 (8%). The numbers in brackets, 76 and 117 respectively, indicate the total number of genomic sequences used to estimate the prevalence.

The sentence ` The candidate variant/lineage did not show an increase in prevalece greater than the threshold at any interval or locale ` is used when no data are available and/or the novel variant did not show an increase in its prevalence.

**Prevalence in time**

This section reports the latest prevalence of the candidate variant/lineage as estimated by HaploCoV. For example:

|  ``Latest prevalence:``
|      ``AsiaSO 2021-04-30 0.0294-(136)`` 
|      ``AsiaSO::India 2021-04-30 0.0294-(136)`` 

indicates that the latest prevalence of the candidate lineage/variant at April 30th 2021, was 0.029 (~3%) in South Asia and India. 
