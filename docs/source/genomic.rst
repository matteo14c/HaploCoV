Genomic variants file
=====================


HaploCoV uses a collection of genomic variants with high frequency (at a specific time or place) to augment a "target nomenclature" and identify **candidate** novel variants or lineages.
By genomic variant, here we mean a variant in the genome, or better w.r.t the reference genome assembly of SARS-CoV-2. Although the specification of the adjective "genomic" might sound verbose, we prefer to use it throughout the manual to avoid confusion between "viral variants" or variants of the virus.

The utility *computeAF.pl* included in HaploCoV can be used to analyse a file in HaploCoV format and identify high frequency genomic variants. By default *computeAF.pl* will flag all the genomic variants that displayed a frequency of 1%, for more than 30 non consecutive days during the pandemic (i.e. or derived from the input data).

The output of *computeAF.pl* are *genomic variants files*.These files have a very streamlined format which is briefly illustrated below. Each genomic variant is reported  according to the following format:

| \<position\>\_\<ref\>|\<alt\>
| *5000\_A|G*

where **position**\= genomic coordinate on the reference genome, **ref**\= reference sequence on the genome and **alt**\= alternative sequence on the genome.

A *genomic variants file* consists of 2 columns separated by tabulations. The first column reports a genomic variant, the second the list of places (country, macro-areas, etc) where the genomic variant shows a prevalence above the threshold. Genomic variants are reported in no specific order.
An example of a genomic variants file looks like:

| 22204\_.\|A	AfrCent
| 26445_T|C	AsiaSE

Several lists/collections of pre-computed *genomic variants files* are already available from the main github repository of HaploCoV. These files enable users to execute their analyses with sets of genomic variants, defined according to different criteria and which are suitable for different use cases.

Pre computed *genomic variants files*
====================================

The files *global_list.txt*, *area_list.txt* or *country_list.txt* form the main repository can be used to provide lists of genomic variants that showed a high frequency:

1. at global level: *global_list.txt*;
2. in at least a macro geographic area: area_list.txt (see `here <https://haplocov.readthedocs.io/en/latest/metadata.html#geography-and-places>`_);
3. in at least a country: country_list.txt.

Each is updated/regenerated to incorporate new data on a bi-weekly basis (every Wednesday). If you do not want to compute high frequency alleles yourself, you can download the files directly from *github*. On a unix system this can be done by using the  ``wget command``.
For example:

::

 1. global_list.txt ` wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/global_list.txt`
 2. area_list.txt ` wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/country_list.txt`
 3. countries_list.txt ` wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/global_list.txt`
 
HaploCoV does also feature additional sets of *genomic variants files*, which might be suitable for different use cases. 
These files are found under the folder "alleleVariantSet" and include:

| 1. **Highly variable genomes.** These are genomic variants found in at least 25 *highly divergent* genomic sequences that have 6 or more additional genomic variants w.r.t the reference strain to which they are assigned. Highly divergent genomic variants are computed by considering non overlapping intervals of 60 days. For example 960\_1020\_list.txt from the list of genomic variants from genome sequences isolated from 960 to 1020 days after Mon 2019-12-30 (day 0 according to HaploCoV, see `here<https://haplocov.readthedocs.io/en/latest/metadata.html#dates-and-time-in-haplocov>`_). These files are stored under the folder: **HighVar**. These files are usefult/can be used to identify novel candidate lineage/variants which show an increased number of genomic variants compared with theri parental lineage.
|
| 2. **Country specific genomic variants.** Genomic variants reaching a frequency of 1% or higher, for at least 30 days in a specific country at any time point from Mon 2019-12-30. In this case each file represents a country, unlike country_list.txt which reports genomic variants that were frequent at any country. These files are stored under the folder: **country**. Country specific files can be used, for example for identyfing/defining novel candidate lineages or variants that are specific to a country.
|
| 3. **Genomic variants with increased prevalence.** Genomic variants showing an increase in their prevalence of a 1.5 fold or greater in at least one country, at different months, and starting from January 2020. These files are stored under the folder: **HighFreq.**  These files are meant to facilitate the identification and flagging of novel variants of SARS-CoV-2 that are increasing in prevalence.
|

*Designations files* in HaploCoV
=============================================

In HaploCoV viral lineages/variants are defined by considering the complete collection of genomic variants that are observed in at least 50%+1 of the genomes assigned by a designation.
The main repository in github includes *linDefMut* a file that provides the complete list of genomic variants that define lineages of SARS-CoV-2 according to the Pango nomenclature. In HaploCoV we refer to this type of file as: *designations files*.
In a *designation file* each lineage is reported in a single line, followed by the complete list of defining genomic variants.
Genomic variants are indicated according to the convention described above.
To provide and example:

| A 8782_C|T 28144_T|C

indicates that lineage A is defined by 2 genomic variants: ``8782_C|T`` and ``28144_T|C`` respectively.
Novel/custom definitions of lineages and/or groups can be specified simply by adding a definition line in the *linDefMut* file, or equivalent.

For example, if HaploCoV identifies a novel variant/lineage for you, and you want to track/assign/analyse that variant/lineage, all you have to do is add its "definition" line to *linDefMut*. 

*HaploCoV.pl* (see --varfile option) can report/write *designation files*, which can be easily concatenated with linDefMut.
For example if you have your additional interesting designations in a file called "novel.txt" you can add them by using the **cat** command in a unix environment:

::

 `cat novel.txt >> linDefMut `

Novel designations
==================

Novel designations of lineages/variants are be indicated by a suffix, that is happended to the name of the parental lineage, in HaploCoV. By default the suffix is composed by the letter ``N`` followed by a, ``dot`` and a ``progressive number``.
For example if HaploCoV identifies 2 novel candidate lineages within the Pango lineage B.1, the names will be:

| B.1.N1
| B.1.N2
 
The default string/letter to be used as a suffix is set by the --suffix option in *augmentClusters.pl*. Please see below for how to modify this default behaviour.
