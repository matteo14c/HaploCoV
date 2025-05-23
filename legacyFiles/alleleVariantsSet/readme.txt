######################################
#       Content and Rationale        #
######################################
The current folder holds collections of "allelic variants" that can be used, in conjuction with "augmentClusters.pl" 
tool in HaploCoV to search for novel potential groups of genomic sequences/lineages in a classification system such 
as Pango and/or HaploCoV itself.

These collections can be broadly categorized into 3 main categories

1. Highly variable genomes -> allelic variants found in at least 25 "highly divergent" genomic sequences, at different 
intervals of time.  Highly divergent/variable genome are defined as those carrying at least 6 or more allele variants 
that are not characteristic to the lineage to which they belong. Intervals of time were defined as non-overlapping
windows of 60 days, starting from Mon 12-30-2019 and are expressed in "HaploCoV format", i.e offsets from the start date. 
These files are stored under the folder: HighVar

2. Country specific allele variants -> allele variants reaching a high frequeny of 1% or higher, for at least 15 days 
in any country. Each country corresponds to a file. These files are stored under the folder: country. Each file is named 
after the country from which it was derived. These files are updated every 15 days.

3 Increased frequency alleles: allelic variants showing an increase in their prevalence in at least one country population 
of a 2.5 fold or more in the last 30 days. These files are stored under the folder: HighFreq
