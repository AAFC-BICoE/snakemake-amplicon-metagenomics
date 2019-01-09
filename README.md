# Amplicon Metagenomic Workflow

## Synopsis
This workflow describes a series of steps executed to get from raw fastq files, resulting from the amplicon sequencing of sample(s), to OTU table, describing the taxonomic determination summary for the analysed sample(s). It executes on Linux command line, using a Snakemake workflow management system. 

### Workflow

1. QC of input files
2. Trim input files
3. QC of trimmed files
4. Join forward and referse sequences
5. QC of joined sequences
6. Cluster sequences
7. Pick representative sequences
8. Detect and remove chimeric representative sequences/clusters
9. Taxonomic classification
10. Create OTU table

## Setup

1. Create a directory with input data. This should be paired illumina sequences. 
    * This can be a directory of symbolic links to data elsewhere on a file system. 
2. In _config.yaml_ file:
    * Verify the working directory, this is the location of the pipeline output
    * Verify input directory, this can be an absolute path or relative to the working directory
    * Verify reference fasta and taxonomy, this can be absolute paths or relative to the working directory
    * Verify that input sequences file extension 
    * Verify the _input_file_forward_postfix_ parameter corresponds to the naming of your raw files. Change it, if necessary.
4. Optional: change tools parameters/paths in _config.yaml_ file.

For details on the workflow tools, their version, arguments used, and order of execution  see _Snakefile_.

## Execute

To check if the workflow will run correctly without executing the steps:

	$ snakemake -np --configfile config.yaml

To execute the workflow:

	$ snakemake --configfile config.yaml
	
Note: If you are not in the same directory as the Snakefile you will need the extra parameter `--snakefile` with the path to the Snakefile

## Installation

This worflow runs on Linux. To install this workflow, either locally or on a cluster, you will need to have the following requirements installed.

##### Requirements
* Python 3.5+
* PyYAML 4.2b1
* Snakemake 3.7.1
* FastQC 0.11.5
* Trimomatic 0.36
* Qiime 1.9

Download the latest release of this project:

https://github.com/AAFC-MBB/snakemake-amplicon-metagenomics/releases

OR

Check out this project (requires git):

    $ git clone https://github.com/AAFC-MBB/snakemake-workflows.git

## Tests

Automated test is located in _snakemake-workflows/amplicon_workflow/test/_. To run the test, first download the test data to _snakemake-workflows/amplicon_workflow/test/data/_ directory (see README in that directory for the instructions). Before you execute the test please note, that the test runs _Snakefile_ with the test data and therefore uses the same output directory as a regular _snakemake_ command (default is _snakemake-workflows/amplicon_workflow/data_). Therefore if you already have some input or intermetiate workflow execution data in your _data_ directory and you would like to keep it - back it up. 

Execute the tests:

    $ ./test.sh -clean -run

## Info

For more information about Snakemake, visit their website: https://bitbucket.org/snakemake/snakemake/wiki/Home


## Authors

[Oksana Korol](https://github.com/oxyko)

[Christine Lowe](https://github.com/ChristineLowe)

## Licensing

See [License file.](https://github.com/AAFC-MBB/snakemake-workflows/blob/master/LICENSE)
