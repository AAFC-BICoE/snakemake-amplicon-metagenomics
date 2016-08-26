# Amplicon Metagenomic Workflow

## Synopsis
This workflow describes a series of steps executed to get from raw fastq files, resulting from the amplicon sequencing of sample(s), to OTU table, describing the taxonomic determination summary for the analysed sample(s). It executes on Linux command line, using a Snakemake workflow management system. 


## Setup

Make sure you're in the directory where the _Snakefile_ is.

1. Create a _data/input/_ directory off of where the _Snakemake_ file is:
    
        $ cd <path_to>/snakemake-workflows/amplicon_workflow/
        $ mkdir -p data/input
2. Copy your raw _.fastq.gz_ files to _input_ directory
3. In _config.yaml_ file, make sure that the _input_file_forward_postfix_ parameter corresponds to the naming of your raw files. Change it, if necessary.
4. Optional: change tools parameters in _config.yaml_ file.

For details on the workflow tools, their version, arguments used, and order of execution  see _Snakefile_.

## Execute

To check if the workflow will run correctly without executing the steps:

	$ snakemake -np

To execute the workflow:

	$ snakemake 

## Installation

This worflow runs on Linux. To install this workflow, either locally or on a cluster, you will need to have the following requirements installed.

##### Requirements
* Python 3.5+
* PyYAML 3.11
* Snakemake 3.7.1
* FastQC 0.11.2
* Trimomatic 0.36
* Qiime 1.9

Check out this project (requires git):

    $ git clone https://github.com/AAFC-MBB/snakemake-workflows.git
OR

Copy _Snakefile_ and _config.yaml_ files to where you would like to store the workflow and its results.

## Tests

Automated test is located in _snakemake-workflows/amplicon_workflow/test/_. To run the test, first download the test data to _snakemake-workflows/amplicon_workflow/test/data/_ directory (see README in that directory for the instructions). Before you execute the test please note, that the test runs _Snakefile_ with the test data and therefore uses the same output directory as a regular _snakemake_ command (default is _snakemake-workflows/amplicon_workflow/data_). Therefore if you already have some input or intermetiate workflow execution data in your _data_ directory and you would like to keep it - back it up. 

Execute the tests:

    $ ./test.sh -clean -run

## Info

For more information about Snakemake, visit their website: https://bitbucket.org/snakemake/snakemake/wiki/Home


## Author

[Oksana Korol](https://github.com/oxyko)

## Licensing

See [License file.](https://github.com/AAFC-MBB/snakemake-workflows/blob/master/LICENSE)
