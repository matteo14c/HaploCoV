2 Compute high frequency genomic variants
=========================================

Once your data have been formatted in HaploCoV format ( see `here <https://haplocov.readthedocs.io/en/latest/metadata.html#formatting-the-input>`_ ), you can derive high frequency genomic variants by *computeAF.pl*.

The tool partitions genomes according to geographic metadata, and computes allele frequencies over a user defined time interval, in overlapping time windows of a user defined size. The main ouput consist of lists of "high frequency" genomic variants at different level of geographic granularity: global (all genomes), macro(macro geographic areas) and countries(country). Macro areas are according to the "areafile" in the github repository, see  `here <https://haplocov.readthedocs.io/en/latest/metadata.html#geography-and-places>`_. 

All the final outputs as well as all intermediate files produced by the tool are saved in a folder, that can be specified with the option --outdir (see below). User also have the option to select the minimum frequency (as in allele frequency) and "persistency" (number of weeks above the frequency threshold) thresholds for the identification of high frequency genomic variants.

**Options**

The script accepts the following parameters:

* *--file* name of the metadata file (please see above); 
* *--maxT* upper bound in days for the time interval to consider in the analysis (days are counted starting from 12-30-2019). A value of 1 corresponds to 12-31-2019. A value of 365 to 12-30-2020. And so on; 
* *--minT* lower bound for the time interval. days are counted using the same logic described form maxT;
* *--interval*  size in days of overlapping time windows, defaults to 10;
* *--minCoF* minimum fequency for high frequency genomic variants, defaults to 0.01; 
* *--minP* minimum persistence (number of overlapping time windows) for high freq genomic variants: only genomic variants that have a high frequency (>=minCoF) in at least this number of distinct time windows will be included in subsequent analyses,defaults to 3;
* *--outdir*  output directory. This directory will hold the output files, including lists of high frequency alleles. Defaults to "./metadataAF".

**Execution**

Please see below for a valid example:

::

 perl computeAF.pl --file linearDataSorted.txt #(where linearDataSorted.txt is is the file with metadata in HaploCoV format)


The output will be stored in the directory specified by --outdir (defaults to ./metadata), and will include:

* frequency matrices for all the countries and macro-geographic areas (suffix \_AFOT.txt);
* three files containing the lists of high frequency genomic variants, showing a frequency above the user defined threshold for more that the timespan set by the user, at global (global_list.txt), macro-areas(area_list.txt) and country (country_list.txt) level.


**High frequency alleles files from the github repo**

Any of global_list.txt, area_list.txt or country_list.txt can be used to provide the list of genomic variants used to "expand" lineages/sub-lineages of SARS-CoV-2 by augmentClusters.pl.  Please see Chiara et al 2022 for a detailed discussion of the implications. 
A copy of each of these files can also be found in the HaploCoV github repository, and each is updated/regenerated to incorporate new data on a bi-weekly basis (every Wednesday). If you do not want to compute high frequency genomic variants yourself, you can download the files directly from *github*. On a unix system this can be done by using the `` wget command``.
For example:

1. global_list.txt 

::

 wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/global_list.txt


2. area_list.txt 

::

 wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/country_list.txt

3. countries_list.txt 

::

 wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/global_list.txt
