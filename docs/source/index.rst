.. HaploCoV documentation master file, created by
   sphinx-quickstart on Wed Jul 20 11:58:46 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to HaploCoV's documentation!
====================================

**HaploCoV**: provides a collection of Perl scripts and utilities that can be used to:

1. **align** SARS-CoV-2 genome assemblies with the reference genomic sequence and **identify genomic variants**, 
2. identify **regional genomic variation** reaching a **"high frequency"** locally or globally, 
3. **extend an existing classification** based on a list of genomic variants, 
4. identify novel and potentially **epidemiologically relevant** variants/lineages/sub-lineages of SARS-CoV-2 
5. and to **classify** one or more genomes according to the method described in *Chiara et al 2021* https://doi.org/10.1093/molbev/msab049 and/or any other classification system of your choice.

This software package is composed of **8(+3)** utilities. Although the full worfklow can be executed by running a couple of commands

Please see the following sections for point to point instructions and tips for the execution of HaploCov.

Should you find any issue, please contact me at matteo.chiara@unimi.it , or open an issue here on github

Should you find any of this software useful for your work, please cite:
*Chiara M, Horner DS, Gissi C, Pesole G. Comparative genomics reveals early emergence and biased spatio-temporal distribution of SARS-CoV-2. Mol Biol Evol. 2021 Feb 19:msab049. doi: 10.1093/molbev/msab049.*

If you find any issue with the software, please contact `me <mailto:matteo.chiara@unimi.it>`_, or report it  on `github <https://github.com/matteo14c/HaploCoV/issues>`_.

.. toctree::
   :maxdepth: 2
   :caption: Prerequisites

   data.rst
   configuration.rst
   perlMummer.rst
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
