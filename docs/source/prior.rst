5 Prioritization of novel groups/lineages
=========================================

The *report.pl* utility can be used to compare newly created groups/sublineages with their parental lineages in the reference nomenclature and prioritize lineages/sub lineages of SARS-CoV-2 showing a high increase in score with respect to a parental lineage (see *Chiara et al 2022*). 
The main input corresponds with the output of LinToFeats.pl. 
Users are also required to specify the suffix used to indicate "novel" lineages/sublineages. 
This suffix must match the equivalent suffix provided to augmentClusters.pl. The default value is **N**.
The configuration file indicated by --scaling: provides the list of the features to be used in the computation of the final score. A complete description of the features used by *LinToFeats.pl* to compute scores can be found in the *features.csv* file attached to HaploCoV's github repo. The default is the list of features described in *Chiara et al 2022*, the file should not be edited, if not for a very good reason. 
The final output consist in a simple text file, in tsv format where high scoring variants/sub-variants are reported along with their score and the score of the parental lineage.

**Options**

*report.pl* accepts the following input parameters:

* *--infile* name of the input file. This is the output file of LinToFeats.pl
* *--suffix* suffix used to identify novel lineages/subvariants by augmentClusters.pl (see --prefix)
* *--scaling* defaults to "scalingFactors.csv", this configuration file in included in the github repo
* *--outfile* a valid name for the output file

**Execution**
 
A typical run of report.pl should look something like:

::

 perl report.pl --infile lvar_feats.tsv --outfile lvar_prioritization.txt

The main output file *lvar_prioritization.txt will* a list of the SARS-CoV-2 variants that show a significant increase in their genomic score with respect to a parent variant. These variants are more likely to pose an increased risk from an epidemiological perspective.
