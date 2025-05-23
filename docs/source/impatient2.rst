For impatient people
====================

To apply the full workflow implemented by HaploCoV.pl you will need to execute 7 different tools. Detailed instructions for how to execute/use each of them are provided in the following sections. Here you will find a brief outline.

**Importing GISAID data:**

::

 1. `perl addToTable.pl --metadata metadata.tsv --seq sequences.fasta --nproc 16 --outfile linearDataSorted.txt `

**Importing Nexstrain data:**

::

 1. perl NextStrainToHaploCoV.pl --metadata metadata.tsv --outfile linearDataSorted.txt

**then compute AF from the data:**

::

 2. perl computeAF.pl --file linearDataSorted.txt

**OR download a genomics variant file:**

::

 2. wget https://raw.githubusercontent.com/matteo14c/HaploCoV/updates/area_list.txt

**Identify novel designations (3):**

::

 3. perl augmentClusters.pl --outfile lvar.txt --metafile linearDataSorted.txt --posFile areas_list.txt

**Compute features/voc-ness score(4+5):** 

::

 4. perl LinToFeats.pl --infile lvar.txt --outfile lvar_feats.tsv

::

 5. perl report.pl --file lvar_feats.tsv --outfile lvar_prioritization.txt

**Assign the novel designations(6):** 

::

 6. perl assign.pl --dfile lvar.txt --metafile linearDataSorted.txt --outfile --out HaploCoVAssignedVariants.txt

**OR alternatively (parallel version, faster):** 

::

 6. perl p_assign.pl --dfile  lvar.txt --metafile linearDataSorted.txt --nproc 12 --out HaploCoVAssignedVariants.txt


**Compute the prevalence (7):**

::

 7. perl increase.pl --file HaploCoVAssignedVariants.txt
 
