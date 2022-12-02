For impatient people
====================

To do all of the above: 

**GISAID data**

::

 1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

**Nexstrain data**

::

 1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

**finally**

::

 2. `perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `

