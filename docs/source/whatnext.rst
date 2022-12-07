What to do next
===============

If you identified a novel variant of SARS-CoV-2 with "interesting" genomic features, you should probably report the variant to Health authorithies in your country and to the scientific community.

Normally `virological <https://virological.org>`_ or `Pango <https://github.com/cov-lineages/pango-designation/issues/>`_ would be the right place to start to report your novel findings to the community.

If the novel candidate variant was identified by HaploCoV, HaploCoV.pl (see --varfile option) or augmentClusters.pl (see HaploCoV: tools) should/could have provided a file with the complete list of genomic variants that define your novel lineage/lineages of interest.
It might be worthwile to add this/these definitions to your favourite "Genomics variant file" (see `here <https://haplocov.readthedocs.io/en/latest/genomic.html>`_) and use assign.pl or p_assign.pl to re-assign genomic sequences using the augmented nomenclature.

Whence the novel nomenclature is assigned, you can extract the data (and metadata) of the novel candidate lineage/variant from a HaplocoV formatted metadata table (like for example the output of assign.pl) by using the *subset.pl* utility included in github repo.  This section of the manual illustrates some possible applications of the tool, and explains how to use it to extract data of interest. 
See next.

Finally the increase.pl utility can be used to calculate the "prevalence" of your novel/candidate variant/variants in space and time and derive global patters (if any and if your novel designations were not already derived from the analysis of all the available genome sequences) and/or identify countries or places where it is prevalent. 

