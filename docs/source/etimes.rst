Computational resources
===========================

The HaploCoV workflow can be executed in a "reasonable" time on a modern laptop. However, be aware that some of the input files might be extremely large in size. 
For example, the complete fasta file with all SARS-CoV-2 genome sequences avaiable from the GISAID database has a size in the excess of *300 Gb*. While complete metadata files from GISAID are over 8 Gb in size.
Moreover, some tasks/processes can potentially take up to a few days (see for example #6 Assign genomes to new groups) on a single processor. In the light of the above considerations we would kindly invite users to make sure that *they have access* to the required computational resources before executing the HaploCoV workflow. The table below briefly summarizes the requirements in terms of time, RAM memory and disk-space required by eacht tool in HaploCoV, and for the complete workflow 

.. list-table:: Computational Resources
   :widths: 40 40 40 40 40
   :header-rows: 1
   
   * - Heading Tool
     - Heading Input files
     - Heading RAM (peak memory)
     - Heading Time
     - Heading Output (size)
   * - addToTable.pl
     - sequences.fasta > 300G; metadata.tsv ~10G
     - 6.0G - 8.0G
     - ~20 genomes per hour (on a single CPU)
     - 6.0G - 8.0G
  

If you already have all your metadata in HaploCoV format, executing the full workflow should require less than 3hrs.
If you use a "locales" file to restrict the analyses to a specific time-interval or geographic region, execution times should be considerably reduced (see HaploCoV: workflow).
In any case execution times might change also depending on your computational environment. 
