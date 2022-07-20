.. HaploCoV documentation master file, created by
   sphinx-quickstart on Wed Jul 20 11:58:46 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to HaploCoV's documentation!
====================================

**HaploCoV**: provides a collection of simple Perl scripts that can be used to:

1. **align** complete assemblies of SARS-CoV-2 genomes with the reference genomic sequence and **identify allelic variants**, 
2. identify **regional alleles** reaching a **"high frequency"** locally or globally, 
3. **extend an existing classification** based on high frequency regional alleles and/or any list of alleles provided by the user , 
4. derive **potentially epidemiologically relevant variants and/or novel lineages/sub-lineages of the virus** 
5. and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice.

This software package is composed of **6(*+3*)** very simple scripts. 

Input files
===========

Three main input files are required:
* **the reference assembly** of the SARS-CoV-2 genome in fasta format
* a **multifasta** file with SARS-CoV-2 genomes to be compared with the reference
* a **.tsv** file with metadata associated to the SARS-CoV-2 genome sequences included in the multifasta

Reference genome
================
The reference genome of SARS-CoV-2 can be obtained from:
https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz
on a unix system you can download this file, by

::

wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/009/858/895/GCF_009858895.2_ASM985889v3/GCF_009858895.2_ASM985889v3_genomic.fna.gz

followed by

::

gunzip GCF_009858895.2_ASM985889v3_genomic.fna.gz


Please notice that however the *addToTable.pl* utility in HaploCoV is going to download the file for you, if a copy of the reference genome is not found in the current folder. However, since the "wget" command is required this is supposed to work only unix and unix alike systems.

Metadata and sequences
======================
SARS-CoV-2 genomic sequences and associated metadata can be obtained from the `GISAID <https://www.gisaid.org/>_` database. The following columns are required/expected to be found in the metadata file:
* *Virus name* : identifiers of viral isolates. These names **MUST** match the names included in the multifasta file
* *Location* : geographic place where the sample was collected. The expected format is continent/country/region
* *Collection date* : date of collection of the sample. Format: YYYY-MM-DD
* *Submission date* : date of submsision of the sample to the the database.  Format: YYYY-MM-DD
* *Pango lineage* : Pango lineage (or group according to a nomenclature of choice) assigned to viral isolates

If any of the columns indicated above (names must be exactly matched) is not found in your metadata table, execution of HaploCoV will halt and an error message will be raised. Please be aware that this does not mean that you necessarily need to provide data from the GISAID database as the main input (see below), but just that the metadata that you provide must have columns names consistent with those reported above.
If you do not have access to GISAID, you can obtain publicly available SARS-CoV-2 data processed according to their "ncov" workflow from `Nextstrain <https://nextstrain.org/sars-cov-2/>_`. 

.. warning::
since metadata from Nextstrain have slightly different format than that used by HaploCov, you will need to convert them in "HaploCov" format by using *NextStrainToHaploCoV.pl*.

Please see the following sections for point to point instructions and tips for the execution of HaploCov.

Should you find any issue, please contact me at matteo.chiara@unimi.it , or open an issue here on github

Should you find any of this software useful for your work, please cite:
*Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.*

If you find any issue with the software, please contact `me <mailto:matteo.chiara@unimi.it>`_, or report it  on `github <https://github.com/matteo14c/HaploCoV/issues>`_.

.. toctree::
   :maxdepth: 2
   :caption: Prerequisites

   data.rst
   configuration.rst
   perlMummer.rst

.. toctree::
   :maxdepth: 2
   :caption: Running
   
   metadata.rst
   hfalleles.rst
   novel.rst
   features.rst
   prior.rst
   assign.rst
   impatient.rst

.. toctree::
   :maxdepth: 2
   :caption: Executing custom analyses

   subsetting.rst
   customalleles.rst


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`qq
