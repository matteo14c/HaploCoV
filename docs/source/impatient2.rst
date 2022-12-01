For impatient people
====================

To do all of the above: 

**GISAID data**

::

 1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

**Nexstrain data**

::

 1. ` perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt `

**then**

::

 2. `perl computeAF.pl --file linearDataSorted.txt `

**OR**


` wget https://raw.githubusercontent.com/matteo14c/HaploCoV/master/area_list.txt`


**and Finally**

::

 3. `perl augmentClusters.pl --outfile lvar.txt --metafile linearDataSorted.txt --posFile areas_list.txt `

::

 4. `perl LinToFeats.pl --infile lvar.txt --outfile lvar_feats.tsv `

::

 5. `perl report.pl --infile lvar_feats.tsv --outfile lvar_prioritization.txt `

::

 6. `perl assign.pl --dfile lvar.txt --metafile linearDataSorted.txt --outfile --out HaploCoVAssignedVariants.txt `

**OR** 

::

 6. `perl p_assign.pl --dfile  lvar.txt --metafile linearDataSorted.txt --nproc 12 --out HaploCoVAssignedVariants.txt `

