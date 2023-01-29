5 Prioritization of novel groups/lineages
=========================================

The *report.pl* utility can compare newly defined variants/lineages with their parental lineages in the reference nomenclature and prioritize those showing a high increase in score (see Chiara et al 2022). 
The main input is the output of *LinToFeats.pl*. 
Users are also required to specify the suffix used to indicate novel lineages/sublineages. 
This suffix must match the equivalent suffix provided to *augmentClusters.pl*. The default value is **N**.
The configuration file indicated by *--scaling* provides the list of the features to be used in the computation of the final score. The default is to use *scalingFactors.csv* which is included in the main repository of HaploCoV. A complete description of the features used by *LinToFeats.pl* to compute scores can be found in the *features.csv* file attached to HaploCoV's github repo. The default is the list of features described in *Chiara et al 2022*, the file should not be edited, unless for a very good reason. 
The final output consist in a simple text file in tsv format where *VOC-ness scores* of novel candidate lineages/variants are reported along with the score the parental lineage.

**Options**

*report.pl* accepts the following input parameters:

* *--infile* name of the input file. This is the output file of LinToFeats.pl;
* *--suffix* suffix used to identify novel lineages/subvariants by augmentClusters.pl (see --prefix);
* *--scaling* defaults to "scalingFactors.csv", this configuration file in included in the github repo;
* *--outfile* a valid name for the output file.

**Execution**
 
A typical run of report.pl should look something like:

::

 perl report.pl --infile lvar_feats.tsv --outfile lvar_prioritization.txt

The main output file *lvar_prioritization.txt* will list all the new designations identified by HaploCoV in your reference nomenclature, their score and the increase in score w.r.t the parental lineage/variant. 
The output file is a table with 6 columns:

.. list-table:: Locales File
   :widths: 35 35 50 50 70
   :header-rows: 1

   * - Heading newLab
     - Heading Parent
     - Heading scoreNew
     - Heading scorePar
     - Heading scoreDiff
     - Heading PASS
   * - B.1.N.1
     - B.1
     - 15
     - 1.5
     - 13.5

The table reports the following information:

1. the name of the novel designation according to HaploCoV;
2. the name of the parent lineage in the nomenclature;
3. the VOC-ness score of the novel lineage;
4. the VOC-ness score of the parent;
5. the difference in score;
6. whether the difference is above the threshold (PASS) or not (NO).
