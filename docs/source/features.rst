4 Compute genomic features of SARS-CoV-2 lineages and sublineages
=================================================================

The *LinToFeats.pl* utility computes high level genomic features of SARS-CoV-2 lineages.
A complete list of such high level features along with a brief description is provided in the *features.csv* file in the main Github repo of HaploCoV.
The tool uses pre-computed annotations of SARS-CoV-2 variants obtained by CorGAT to derive its scores. Such annotations are available from the *globalAnnot* file,and are updated on a bi-weekly basis. At every execution the most recent version of the annotations is downloaded automatically. Users are kindly encouraged to not modify this behaviour, unless for a very good reason.

LinToFeats.pl takes the output of augmentClusters.pl as its main input, the output file is a simple tab delineated table where for every lineage/group in input, genomic features are computed.

**Options**
The program requires only 3 parameters:

* *--infile* file with lineages/groups and their characteristic genomic variants. 1 lineage per line (main output of augmentClusters.pl);
* *--annotfile* file with CorGAT annotations of SARS-CoV-2 variants. Defaults to globalAnnot;
* *--update*  update globalAnnot to the most recent version? T=true. F=false. Default=T.;
* *--outfile* name of the output file.

**Execution**

An example of a valid command line for the execution of LinToFeats.pl is:

::

 perl LinToFeats.pl --infile lvar.txt --outfile lvar_feats.tsv `

The main output file: *lvar_feats.tsv* will contain genomic features in tabular format for all SARS-CoV-2 groups/lineages newly formed groups/sub-lineages. The output consists in a simple table, where for every variant, the numeric value associated with each feature is reported
