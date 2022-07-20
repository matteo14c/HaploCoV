Input data
==========

To run HaploCoV you **must have access** to SARS-CoV-2 genome sequences and associated metadata


Right now the `GISAID database <https://www.gisaid.org/>_` represents the most complete and up to date point of access to obtain SARS-CoV-2 data. 
Authorized users can download the complete collection of SARS-CoV-2 genome assemblies and associated metadata by following the procedure illustrated in the figure below.<br>

.. figure:: _static/img/fig1.png
   :scale: 80%
   :align: center

After de-compresson, 2 files should be obtained: 
1. *metadata.tsv* a metadata table in .tsv format and; 
2. *sequences.fasta* a multi-fasta file with SARS-CoV-2 genome sequences.
These files provide the main input to *addToTable.pl*; the utility in HaploCoV that extracts/obtains all the data used for subsequent analyses.

Required metadata
=================
Please be aware that some metadata are **mandatory** to execute HaploCoV and that columns names in your metadata file **MUST** abide to the structure/names described below. Mandatory metadata:
* a valid unique identifier for every isolate, column name: *"Virus name"*;
* a collection date, column name *"Collection date"*;
* a submission date, column *"Submission date"*;
* location: the geographic place from where the isolated was collected; Column name: *"Location"*;
* a valid lineage/group/class associated with the genome. Column name: *"Pango lineage"* 

Dates must be provided in YYYY-MM-DD format. Locations in the following format: Continent/Country/Region.<br> Missing information must be indicated by NA (not available).<br>An example of a valid metadata table is reported below

Virus name | Collection date | Submission date | Location | Pango Lineage |
-----------|-----------------|-----------------|----------|---------------|
hcov/somename_1| 2022-05-26| 2022-06-01 | Europe/Italy/Lombardy | BA.2.9
hcov/somename_2| NA | 2022-06-01 | Europe/Italy/Apulia | BA.2.9.1|

Important: providing "external" data  
====================================

While HaploCoV was designed to work with data from GISAID, the tool can in principle work also with data from other sources, however  metadata must always comply with the prerequisites indicated above and valid metadata tables must include 5 columns with the following names:
* "Virus name";
* "Collection date";
* "Submission date";
* "Location";
* "Pango Lineage";

Important: using data from Nextstrain
=====================================

Users that do not have access to GISAID can obtain the complete collection of publicly available SARS-CoV-2 sequences and metadata from Nexstrain, please refer to `here: <https://nextstrain.org/sars-cov-2/>_` for more information.
Metadata in "Nexstrain format" can be obtained from `here: <https://data.nextstrain.org/files/ncov/open/metadata.tsv.gz>_`). Since these data have already been processed by Nexstrain using their *ncov workflow*, allele variants are already included in the metadata file and hence **you will not need to execute *addToTable.pl* on this file**. The file however needs to be converted in "HaploCoV" format.  This can be done by using the *NextStrainToHaploCoV.pl* script included in this repository (see below).
