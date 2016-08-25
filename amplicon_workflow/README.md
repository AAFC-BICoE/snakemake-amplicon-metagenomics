# Amplicon Metagenomic Workflow

## Synopsis
This workflow describes a series of steps executed to get from raw fastq files, resulting from the amplicon sequencing of a sample, to OTU table, describing the taxonomic determination summary for the analysed sample. It executes on Linux command line, using a Snakemake workflow management system. 


## Setup

Make sure you're in the directory where the Snakefile is.

1. Create a data/input/ directory off of where the Snakemake file is:
    
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

## Info

For more information about Snakemake, visit their website: https://bitbucket.org/snakemake/snakemake/wiki/Home


## Author

[Oksana Korol](https://github.com/oxyko)

## Licensing

See [License file.](https://github.com/AAFC-MBB/snakemake-workflows/blob/master/LICENSE)
