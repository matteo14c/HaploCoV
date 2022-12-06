Perl and mummer
===============

HaploCoV is written in the Perl programming language. Hence you will need Perl to run it. Perl should be already installed by default on any unix and Mac OSX system. 
Please follow this `link <https://www.perl.org/get.html>`_ for instructions on how to install Perl. 

HaploCoV uses mummer to align genome sequences and derive genomic variants. Please follow this `link <https://sourceforge.net/projects/mummer/files/>`_ for detailed instruction on how to install and run Mummer. 
Or see the installation instructions below.

Mummer installation
===================

Unix, ubuntu
============

Under the most recent versions of ubuntu, Mummer can be installed directly from your system package manager (apt-get). If you have super-user privileges, you can open a terminal and then issue the following command:

::

  sudo apt-get install mummer

this will install mummer for all the users in your system.


Unix, from binaries
====================

If you OS does not feature pre-compiled software packages for the installation of Mummer, you can compile from binaries. Please follow this link https://sourceforge.net/projects/mummer/files/ for detailed instructions on how to install and run Mummer. Please notice that after you have succesfully compiled all the executables by running:

::

  make install

you will still need to place add these files to your executable PATH, either by adding/copying all the files to one of the directories already included in the PATH or by adding the whole Mummer directory (where all the software was compiled) to the your PATH of executables. If for example all your executables are in a folder called "Mummer" in your home directory on a unix system you can symply run:

::

  export PATH=~/Mummer:$PATH
  
Mummer installation MacOS X
===========================

Download Mummer at: https://sourceforge.net/projects/mummer/files/latest/download and extract the archive (tar.gz) file.
Open up Terminal and:

::

  tar xvzf MUMmer3.23.tar.gz

As explained in the INSTALL file, included in the Mummer package to build Mummer:

::

  cd MUMmer3.23
  make check

If make check does not report any error everything should be ok, then run:

::

  make install

You should get something similar to `this <https://gist.githubusercontent.com/mtangaro/53ec0c88a21255aaf38f460b5cddb340/raw/eb2504d17d2606384fab4e4d805fafe66406087b/mummer_make_install.txt>`_.

::

Now that you have successfully built the binaries are, you need to add them to $PATH. Run the following command with your favourite text editor:
::

  sudo vim /etc/paths

Enter your password, when prompted.
Go to the bottom of the file, and enter the path you wish to add. For example, if you built Mummer in /Users/yourname/test/MuMmer3.23, add this to the file:
::

  /usr/local/bin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  /Users/yourname/test/MUMmer3.23

Save the file in vim
::

  :wq
  
And finally you can test if everything is in place. Open a *NEW* terminal. To test if mummer is now in your PATH, run:
::

  echo $PATH
  
You should see something like:
::

  echo $PATH
  /usr/local/opt/ruby/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/yourname/test/MUMmer3.23

The Mummer package, and all its utilities are now available to be executed in your shell, and for HaploCoV as well. For example, type “nucmer” to execute nucmer:
::

  nucmer
  USAGE: nucmer  [options]  <Reference>  <Query>
  
  Try 'nucmer -h' for more information.


