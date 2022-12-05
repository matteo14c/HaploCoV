For impatient people
====================

To run the full workflow you will need to execute at least 2 commands: 

**To import data**

**GISAID data**

::

 1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

**Nexstrain data**

::

 1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

**and then**

::

 2. `perl HaploCov.pl --file linearDataSorted.txt --locales italy.loc `
 
 
 See below for more details

