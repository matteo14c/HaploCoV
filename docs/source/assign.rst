6 Assign genomes to new groups
===============================

*assign.pl* is an efficient and quick method that can assign SARS-CoV-2 genomes to any nomenclature of choice; including, but not limited to, the "expanded" nomenclature derived by *augmentClusters.pl*. 
The utility applies a simple algorithm based on phenetic distances (described in `Chiara et al 2021 <https://academic.oup.com/mbe/article/38/6/2547/6144924>`_). Users need to provide a *designations file*, see `here <https://haplocov.readthedocs.io/en/latest/genomic.html#designations-files-in-haplocov>`_.
For every isolate in the input file, distances to all the groups/lineages/variants in the nomenclature are computed, and finally the genome is assigned to the group with the highest similarity. In case of multiple groups/classes/lineages with identical similarity levels, the most ancestral lineage/group/class is selected. 

*assign.pl* takes 2 main input files: 

1. a *designations file*. See linDefMut in the github repository for an example of a file with lineage defining variants (or alternatively `Designations files <https://haplocov.readthedocs.io/en/latest/genomic.html#designations-files-in-haplocov>`_ in the manual). ; 
2. a metadata table, in *HaploCoV format*. 

The output is in HaploCoV format.

**Assigning Pango Lineages** 
The file *linDefMut* in the github repository provides a complete list of defining genomic variants for all the lineages included in the Pango nomenclature. Feel free to use that file if you need to assign genomes/isolates according to Pango. The file is updated on a bi-weekly basis.

**Assigning Haplogroups as defined in Chiara et al 2021**
*HaploDefMut* in the github repository provides a complete list of defining allele variants for all haplogroups identified by the method described in `Chiara et al 2021 <https://academic.oup.com/mbe/article/38/6/2547/6144924>`_. Feel free to use that file if you need to assign genomes according to that system. The file is updated on a bi-weekly basis.

**Options**
*assign.pl* takes the following options:

* *---dfile*: *designations file*;
* *--metafile*: a metadata file in *HaploCov format*;
* *--out*: the name of the output file (defaults to **ASSIGNED_out.tsv**).

**Execution**
To assign genomes to a lineages/group/classes you need to run:

::

 assign.pl  --dfile linDefMut  --metafile  linearDataSorted.txt --out  linearDataSorted.txt_reAssigned
 
The output consists of a table in *HaploCoV format*, similarly to the input. The group/class/lineage assigned to each genome (9th column) will be updated with the newly assigned groups/class/lineages. Moreover an additional column will be added to indicate/report alternative assignments with equal levels of similarity. An example is outlined below. *no* indicates no alternative assignments were identified, and hence that the genome was unambiguously assigned to a single group/lineage. When multiple assignments are identified, a comma separated list is provided.

.. list-table:: Locales File
   :widths: 30 30 30 30 30 30 30 30 30 30 30 30
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
     - Heading alternative lineage
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
     - BA.2.9.1
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
     - no
   
**Execution times, and multithreading** 

Using a single core/thread *assign.pl* can assign the complete collection of more than 15M of genomes included in GISAID to Pango lineages in about 4 hours. The companion utility *p_assign.pl* included in this repository can be used to parallelize the execution of *assign.pl* if required (see below). Execution times are reduced linearly. For example, if 24 cores are used, less than twenty minutes are required to assign 15M genomes.

**p_assign.pl**

Multi-threading, the *p_assign.pl* utility included in this repo provides means to execute assign.pl on multiple threads/cores/processors.
The following input parameters are accepted:

* *---dfile*: *designations file*;
* *--metafile*: a metadata file in *HaploCov format*;
* *--out*: the name of the output file (defaults to **ASSIGNED_out.tsv**);
* *--nproc*: number of processors/cores;
* *--update*: if/when --dfile is set to linDefMut, update to the most recent version? T=true. F=False. Default T.


To execute it you can use:

::

 p_assign.pl  --dfile linDefMut50  --metafile  linearDataSorted.txt --nproc 8 --out  linearDataSorted.txt_reAssigned

Input files are the same as those provided to *assign.pl*. Output format is in the same format described above.

.. warning::
Since *p_assign.pl* does directly make use of *assign.pl* when it is executed, both scripts need to be in the same folder when invoking *p_assign.pl*. Execution will halt and raise an error if *assign.pl* is not found/is not in the same folder as *p_assign.pl*. 

All input files **MUST** be in the **same folder** from which the program is executed. If/when linDefMut, the *designations file* of Pango lineages as derived by HaploCoV is specified, by default the most recent version is downloaded from github. Please set *--update F* to disable this behaviour.
