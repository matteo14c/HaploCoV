.. HaploCoV documentation master file, created by
   sphinx-quickstart on Wed Jul 20 11:58:46 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to HaploCoV's documentation!
====================================

**HaploCoV**: provides a collection of Perl utilities that can be used to:

1. **align** complete assemblies of SARS-CoV-2 genomes with the reference genomic sequence and **identify genomic variants**, 
2. pinpoint **regional variation** and flag genomic variant with **"increased frequency"** locally or globally,  
3. **identify epidemiologically relevant variants and/or novel lineages/sub-lineages of the virus** (using a custom scoring system), 
4. **extend an existing classification system** to include novel designations/variants,
5. and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice.

HaploCoV is composed of **9(+3)** utilities, which are combined in a workflow. The complete workflow can be executed with just a couple of commands (or several commands for more complex use cases).
In brief, input files need to be formatted according to the format used by HaploCoV by applying either **addToTable.pl** or **NexstainToHaploCoV.pl** (depending on the input, see below). 
Then the complete HaploCoV workflow can be executed by running **HaploCoV.pl** (recommended) or, if you prefer, by running each individual tool in the HaploCoV workflow in the right order yourself.
Please see the manual for point to point instructions and tips for the execution of HaploCov.

Should you find any of this software useful for your work, please cite:
*Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.*

If you find any issue with the software, please contact `me <mailto:matteo.chiara@unimi.it>`_, or report it  on `github <https://github.com/matteo14c/HaploCoV/issues>`_.

.. toctree::
   :maxdepth: 2
   :caption: HaploCoV in brief
   
   intro.rst

.. toctree::
   :maxdepth: 2
   :caption: Data and formats

   data.rst
   
.. toctree::
   :maxdepth: 2
   :caption: Prerequisites
   
   perlMummer.rst
   configuration.rst
   
   
.. toctree::
   :maxdepth: 2
   :caption: HaploCoV: input
   
   metadata.rst
   genomic.rst
   etimes.rst

.. toctree::
   :maxdepth: 2
   :caption: HaploCov: workflow
   
   impatient1.rst
   haplocov.rst

.. toctree::
   :maxdepth: 2
   :caption: HaploCoV: tools
   
   impatient2.rst
   hfalleles.rst
   novel.rst
   features.rst
   prior.rst
   assign.rst
   increase.rst
   
.. toctree::
   :maxdepth: 2
   :caption: HaploCoV: Use Cases
   
   customreports.rst
   whatnext.rst


.. toctree::
   :maxdepth: 2
   :caption: HaploCoV: advanced

   subsetting.rst
   


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
