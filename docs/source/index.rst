.. HaploCoV documentation master file, created by
   sphinx-quickstart on Wed Jul 20 11:58:46 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to HaploCoV's documentation!
====================================

**HaploCoV**: provides a collection of Perl utilities that can be used to:

1. **align** SARS-CoV-2 genome asssemblies with the reference genomic sequence and **identify genomic variants**, 
2. identify **regional variation** reaching a **"high frequency"** locally or globally, 
3. extend an existing classification with **novel candidate lineages/viral variants**, 
4. use genomic features and prevalence data to pinpoint those that might be **epidemiologically relevant** 
5. and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice.

HaploCoV is composed of **6(+3)** utilities, which are combined in a workflow. The complete workflow can be executed with just a couple of commands. 
Please see the following sections for point to point instructions and tips for the execution of HaploCov.

Should you find any issue, please contact me at matteo.chiara@unimi.it , or open an issue here on github

Should you find any of this software useful for your work, please cite:
*Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.*

If you find any issue with the software, please contact `me <mailto:matteo.chiara@unimi.it>`_, or report it  on `github <https://github.com/matteo14c/HaploCoV/issues>`_.

.. toctree::
   :maxdepth: 2
   :caption: Before you start:

   data.rst
   perlMummer.rst
   configuration.rst
   etimes.rst

.. toctree::
   :maxdepth: 2
   :caption: Running
   
   metadata.rst
   hfalleles.rst
   novel.rst
   features.rst
   prior.rst
   assign.rst
   impatient.rst

.. toctree::
   :maxdepth: 2
   :caption: Executing custom analyses

   subsetting.rst
   customalleles.rst


Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
