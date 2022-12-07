HaploCoV format and input
=========================

HaploCov operates on a large metadata table in tsv format (*HaploCoV* format from here onward). This table contains the required metadata (extracted from "metadata.tsv" or equivalent files) and the collection of genomic variants for every SARS-CoV-2 genome included in the analyses.  
If you obtained your data from **GISAID** you can get a metadata table in *HaploCoV* format by using the *addToTable.pl* utility. If data were downloaded from Nexstrain, you can use *NextStrainToHaploCoV.pl* instead (see below).

HaploCoV format for metadata
============================

An example of the data format used by HaploCoV (HaploCoV format) is illustrated in the table below:

.. list-table:: HaploCoV Format
   :widths: 30 30 30 30 30 30 30 30 30 30 30
   :header-rows: 1

   * - Heading genome ID
     - Heading collection date
     - Heading offset days (collection)
     - Heading deposition date
     - Heading offset days (deposition)
     - Heading continent
     - Heading macro-area
     - Heading country
     - Heading region
     - Heading lineage
     - Heading genomic variants
   * - genome1
     - 2022-06-01
     - 788
     - 2022-06-11
     - 798
     - Europe
     - EuSo
     - Italy
     - Lombardy
     - BA.2.9
     - v1,v2,vn 
   * - genome2
     - 2022-05-01
     - 758
     - 2022-05-11
     - 768
     - Europe
     - EuSo
     - Italy
     - Lombardy
     - BA.2
     - v1,v2,vn 
    
The file is delineated by tabulations. Genomic variants are reported as a comma separated list. 
The format is as follows: 
| *genomicposition_ref|alt* i.e. *1_A|T* for example indicates a A to T substitution in position 1 of the reference genome.

A valid example of an HaploCoV-formatted file, including all the sequences available in INSDC databases up to 2022-07-20 is available at the following link: `HaploCoVFormatted.txt <http://159.149.160.88/HaploCoVFormatted.txt.gz>`_ . The file is `gzip` compressed. When de-compressed it should be around 2.9G in size. 

Dates and time in HaploCoV
==========================

HaploCoV can only read dates in **YYYY-MM-DD format**. Time periods and intervals of time are computed as offsets in days with respect to Monday Dec 30th 2019, which in HaploCoV represents day 0. This date represents the beginning of the first week following the first reported isolation of SARS-CoV-2 (December 26th 2019).
For example Tue 31th Dec 2019 is day 1 according to HaploCoV notation and Sun 29th Dec 2019, represents day -1. 

In the HaploCoV metadata format, the 3rd column reports the offset in days between the isolation of a specific isolate and Dec 30th 2019; similarly the 5th column reports the offset from Dec 30th 2019 to the "deposition" of the genome sequence in a public database.

Metadata tables in HaploCov format are sorted in descending order by the 3rd column (offset of the collection date). This means that the "most ancient" genome will always be at the top of the file, while those isolated more recently  at the bottom.

If you need to know the date of isolation (and offset with respect to day 0) of the most recent genome included in the dataset you can simply use this command in a unix-like shell environment:

::

 tail -n 1 linearDataSorted.txt | cut -f 2,3

For your convenience, the file HaploCoV-dates.csv in the main Github repository reports the conversion of dates from 2019-12-30 to 2025-12-30 to the offset format used by HaploCoV. Please feel free to refer to that file for converting dates to offsets and offsets to dates.

Geography and places
====================

Geography and geography related information are stored in columns 6 to 9 in HaploCoV formatted files. Each column correspond (ideally) to a different level of geographic granularity:

* column 6: continent;
* column 7: macro-geographic area;
* column 8: country;
* column 9: region.

Geographic data are inferred directly from your metadata table, by processing the Location column (see above). Geographic metadata in the Location column of your metadata file must be indicated in the following format:

* Continent/Country/Region.

If "locations" are indicated in a different format, HaploCoV will not be able to process the information and will append NA values in columns 6 to 9.
Importantly we must stress that HaploCoV does not perform any correction on the spelling/consistency of geographic data. Hence it is down to the user to provide input data that are as accurate and correct as possible.

The file **areaFile** in the main repository of HaploCoV is used to assign countries to macro-geographic areas. 
**areaFile** is a text file with 2 columns separated by tabulations. The first columns reports the name of a country, and the second column indicates the macro-geographic region to which the country is assigned.

The following areas are defined

1.  AfrCent: central Africa;
2.  AfrEast: eastern Africa;
3.  AfrNorth: northern Africa;
4.  AfrSouth: southern Africa;
5.  Afrw: western Africa;
6.  Asc: central Asia;
7.  AsiaEast: eastern Asia,
8.  AsiaME: Middle East;
9.  AsiaSE: South East Asia;
10. AsiaSO: southern Asia;
11. EuEa: eastern Europe;
12. EuNO: northern Europe;
13. EuSO: southern Europe;
14. EuUK: United Kingdom;
15. Euc: central Europe;
16. NAcent: central America;
17. NAnorth northern America;
18. Oc: Oceania;
19. SAM: South America.

However custom/user defined "areas" can be specified simply by editing **areaFile** or by providing a new file with the same format.

Formatting the input 
====================

GISAID data: addToTable.pl
==========================

addToTable.pl reads a multifasta (*sequences.fasta*) and a metadata file (*metadata.tsv*) and combines the two files in a large table in HaploCoV format.

**Aligning SARS-CoV-2 genomes to the reference**
 
The helper script *aling.pl* is used to derive genomic variants by *addToTable.pl*; although you do not need to execute it directly, please make sure that you have a copy of align.pl in the same folder from where you run *addToTable.pl*. Identification of genomic variants is performed by means of the Mummer program. Execution will halt if Mummer is not installed. Please see `Perl and Mummer <https://haplocov.readthedocs.io/en/latest/perlMummer.html>`_ for how to install Mummer.

**Important** input files *MUST* be in the *same folder* from where addToTable.pl is executed. 

**Incremental addition of data**

addToTable.pl can add novel data/metadata incrementally to a pre-existing table in *HaploCoV* format. This feature is extremely useful, since it allows users to add data to their HaploCoV installation, without the need to re-execute all the analyses from scratch. To add data to an existing file, users just need to specify that file as the main output of addToTable.pl. **IF** the output file is not empty, addToTable.pl will process the file and add only those genomes which are not already listed/present in your metadata table. Matching is by sequence identifier (column Virus name).  **Alternatively** the --dayFrom parameter can be used to specify a minimum "start day", and only genomes isolated after that day will be processed and included in the output file. Please refer to the section `Dates and time in HaploCov <https://haplocov.readthedocs.io/en/latest/metadata.html#dates-and-time-in-haplocov>`_ to check how dates are handled by HaploCoV.

**Options**
addToTable.pl accepts the following options:

* *--metadata**: input metadata file (typically metadata.tsv from GISAID);
* *--seq*: fasta file;
* *--nproc*: number of threads. Defaults to 8;
* *--dayFrom*: include only genomes collected after this day;
* *--outfile*: name of the output file;

**A typical run of addToTable.pl should look something like:**

::

 perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt 

The final output will consist in a metadata table in HaploCoV format. This table is required for all subsequent analyses.

**Execution times** 
Please be aware that typically a single thread/process can align genomes and derive genomic variants of about 20k SARS-CoV-2 genomes per hour (160k genomes on 8 cores, or 320k on 16 cores). This would mean that processing the complete collection of the more than 15M genomes included in the GISAID database on November 21th 2022 from scratch will take about 20 days if only one core/process is used. Computation scales linearly, hence 3 days would be needed if 8 processes are used, and 1.5 days if 16 are used. Since data are added incrementally, this operation needs to be performed only once. 

NextStrain data: NextStrainToHaploCoV.pl
========================================

If you obtained your metadata files from NexStrain you will use addToTable.pl and align.pl. Metadata tables from NexStrain have already been processed by their ncov pipeline, and do already include a list of allele variants for every genome. The pre-processed file can be downloaded from `here <https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz>`_. 
Please be aware that NexStrain can re-distribute only publicly available data, which at the moment account for about 40% of the data in GISAID.
Data from NexStrain still need to be converted in *HaploCoV* format. For this purpose you can use *NextStrainToHaploCoV.pl*.
Contrary to addToTable.pl, NextStrainToHaploCoV.pl does not feature incremental addition of data: the full NexStrain table can be converted in *HaploCoV* format in 3 to 5 minutes. 

**Options**
NextStrainToHaploCoV.pl accepts the following options:

* --*metadata*: name of the input file;
* --*outfile*: name of the output file;

**Execution**

A typical command line for NextStrainToHaploCoV.pl is something like:

::

 NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt

The output file will be in *HaploCoV* format and can be used by computeAF.pl to compute allele frequencies. 
