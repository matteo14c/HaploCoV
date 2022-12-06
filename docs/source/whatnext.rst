What to do next
===============

If you identified a novel variant of SARS-CoV-2 with "interesting" genomic features, you should probably report the variant to Health authorithies in your country and to the scientific community.<br>
Normally https://virological.org/ or https://github.com/cov-lineages/pango-designation/issues/ would be the right place to start.
If the novel candidate variant was identified by HaploCoV, HaploCoV.pl (see --varfile option) or augmentClusters.pl (see HaploCoV: tools) should/could have provided a file with the complete list of genomic variants that define your novel lineage/lineages of interest.
It might be worthwile to add this/these definitions to your favourite "Genomics variant file" (see [here](https://haplocov.readthedocs.io/en/latest/genomic.html) and use assign.pl or p_assign.pl to re-assign genomic sequences using the augmented nomenclature.<br> 

Whence the novel nomenclature is assigned, you can extract the data (and metadata) of the novel candidate lineage/variant from a HaplocoV formatted metadata table (like for example the output of assign.pl) by using the *subset.pl* utility included in this repo.  The section *HaploCoV: advanced* of the manual illustrates some possible applications of this tool, and explains how to use it to extract data of interest. 
See [here](https://haplocov.readthedocs.io/en/latest/subsetting.html)<br>
Finally the increase.pl utility can be used to calculate the "prevalence" of your novel/candidate variant/variants in space and time and derive global patters (if any and if your novel designations was not already derived from the analysis of all the available genome sequences). 
All these topics are covered in the manual of HaploCoV. Please take a look to the manual in order to see how to make the best of the tools and utilities.
