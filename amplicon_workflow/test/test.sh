#!/bin/bash

#############################################################
# Test script for snakemake amplicon workflow.
#
# Usage:
#       test.sh        : prints script parameters
#       test.sh -run   : executs the test
#       test.sh -clean : cleans all test data
#
# Quick start: 
#	1) make sure you back up your snakemake working directory
#   2) make sure you have test data in test/data directory
#	3) > ./test.sh -clean -run
#
# Note: 
#	1) the script assumes a default config.yaml configuration, 
#	   where workfing directory is <Snakemake directory>/data
#   2) script runs snakemake like user would on command line, 
#	   so back up your data directory
#
# Author: Oksana Korol
# Date: 2016.08.08
#############################################################

cd ..
snakemake_dir=$(pwd)
working_dir="$snakemake_dir/data"
test_data_dir="$snakemake_dir/test/data"
input_data_dir="$working_dir/input"

# Data from:
# /isilon/biodiversity/data/raw/illumina/AAFC/150408_M01696_0021_000000000-ADYMN/Data/Intensities/BaseCalls
input_file1_forward="ENV0001_S1_L001_R1_001.fastq.gz"
input_file1_reverse="ENV0001_S1_L001_R2_001.fastq.gz"
input_file2_forward="ENV0002_S4_L001_R1_001.fastq.gz"
input_file2_reverse="ENV0002_S4_L001_R2_001.fastq.gz"
input_files_common_prefix="ENV000*"

# Data from:
#isilon/biodiversity/data/raw/illumina/AAFC/140829_M01696_0013_000000000-AAP8W
#input_file1_forward="P11-1975_S21_L001_R1_001.fastq.gz"
#input_file1_reverse="P11-1975_S21_L001_R2_001.fastq.gz"
#input_file2_forward="P11-1976_S24_L001_R1_001.fastq.gz"
#input_file2_reverse="P11-1976_S24_L001_R2_001.fastq.gz"
#input_files_common_prefix="P11-197*"


### Functions

function run_test {
	echo "Running the test."

	if [ -d $input_data_dir ] && [ -d $working_dir/step0_* ] && 
		[ -d $working_dir/step7_* ] && [ -d $working_dir/benchmarks ] ; then
		echo "ERROR: input directory ($input_data_dir) and intermediate execution data directories ($working_dir/step*) already exist."
		echo "       Consider backing them up and then run \"./test.sh -clean\", before executing the test again."
		exit 1
	fi

	# Copy test data to data/input directory
	if [ ! -d $input_data_dir ] ; then
		mkdir -p $input_data_dir
	fi

	if [ ! -e $input_data_dir/$input_file1_forward ] && [ ! -e $input_data_dir/$input_file1_reverse ] &&
	    [ ! -e $input_data_dir/$input_file2_forward ] && [ ! -e $input_data_dir/$input_file2_reverse ] ; then
		cp $test_data_dir/$input_files_common_prefix $input_data_dir
	else
		echo "INFO: Input files already exist ($input_data_dir/$input_files_common_prefix). Proceeding with the test."
	fi

	# Copy reference data to data directory
	cp $test_data_dir/unite.* $working_dir


	# Run snakemake in trial mode
	cd $snakemake_dir
	snakemake_npr_output=$(snakemake -npr)
	# Check the output for successfull execution
	if [[ $snakemake_npr_output == *"Error"* ]] ; then
		echo "There were some errors in the snakemake execution. Run \"snakemake -npr\" in Snakemake directory for the full error description."
		exit 2
	fi
	if [[ $snakemake_npr_output == *"Nothing to be done."* ]] ; then
		echo "Snakemake intermediate files / directories already exist, so the test will not be executed. Run \"./test.sh -clean -run\" to first remove Snakemake execution files, then run the test."
		exit 2
	fi


	# Run snakemake
	snakemake > $working_dir/snakemake.out
	
	# Check the output for successfull execution
	#grep_out=$(grep "(100%) done" $working_dir/snakemake.out)
	#if [[ -z $grep_out ]] ; then
	#	echo "ERROR: Not everything in the workflow was executed successfully. See $working_dir for intermediate data results."
	#	#exit 2
	#fi
	

	# Check intermediate data directories exist:
	expected_dir_list=( "benchmarks" "step0_initial_data_quality" "step1_trimmomatic" "step2_join" "step3_convert_to_fasta" "step4_pick_otu" "step5_pick_representatives" "step6_classify" "step7_otu")

	for (( i=0;i<${#expected_dir_list[@]};i++)); do
		if [ ! -d "$working_dir/${expected_dir_list[${i}]}" ] ; then
			echo "ERROR: Expecting $working_dir/${expected_dir_list[${i}]} directory, but did not locate it."
			exit 2
		fi
	done

	# Check if OTU table was created
	if [[ ! -e $working_dir/step7_otu/otu_table.otu ]]; then
		echo "ERROR: OTU table $working_dir/step7_otu/otu_table.otu could not be located."
		exit 2
	fi

	# Compare resulting OTU table
	diff_result=$(diff $working_dir/step7_otu/otu_table.otu $test_data_dir/expected_otu_table.otu )
	if [[ ! -z $diff_result ]] ; then
		echo "ERROR: otu_table.otu did not match expected."
		exit 2
	fi

	echo "SUCCESS: Test executed successfully. See $working_dir for workflow execution results."
}

function remove_working_dir {
	echo "Removing Snakemake working directory."
	rm -r $working_dir
}


### Parse arguments

if [ "$#" -eq 0 ]; then
	echo "Usage: "
	echo "    -run   : run the test;"
	echo "    -clean : clean workflow data. NOTE: this removed workflow working directory (i.e. data directory)."
	echo "             So if you have data there that you would like to keep - back it up!"
	exit 0
fi

for i in "$@"
do
	case $i in
		"-run" ) run_test ;;
		"-clean" ) remove_working_dir ;;
		* ) echo "ERROR: Unknown argument. Run \"./test.sh\" with no arguments to see the script usage. "
	esac
done

