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
#	1) make sure you back up your data directory
#	2) > ./test.sh -clean -run
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
#echo $snakemake_dir

### Functions

function run_test {
	echo "Running the test."

	if [ -d "$snakemake_dir/data/input" ] && [ -d $snakemake_dir/data/step0_* ] && 
		[ -d $snakemake_dir/data/step7_* ] && [ -d $snakemake_dir/data/benchmarks ] ; then
		echo "ERROR: input directory (data/input) and intermediate execution data directories (data/step*) already exist."
		echo "       Consider backing them up and then run \"./test.sh -clean\", before executing the test again."
		exit 1
	fi

	# Copy test data to data/input directory
	if [ ! -d "$snakemake_dir/data/input" ] ; then
		mkdir -p "$snakemake_dir/data/input"
	fi

	if [ ! -e "$snakemake_dir/data/input/ENV0001_S1_L001_R1_001.fastq.gz" ] && [ ! -e "$snakemake_dir/data/input/ENV0001_S1_L001_R2_001.fastq.gz" ] &&
	    [ ! -e "$snakemake_dir/data/input/ENV0002_S4_L001_R1_001.fastq.gz" ] && [ ! -e "$snakemake_dir/data/input/ENV0002_S4_L001_R2_001.fastq.gz" ] ; then
		cp test/data/ENV000* data/input/
	else
		echo "INFO: Input files already exist (data/input/ENV000...). Proceeding with the test."
	fi

	# Copy reference data to data directory
	cp $snakemake_dir/test/data/unite.* $snakemake_dir/data/


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

	#echo "Snakemake -npr output is" $snakemake_npr_output

	# Run snakemake
	snakemake_output=$(snakemake)
	echo "**************** Snakemake output *****************"
	echo $snakemake_output
	echo "*********************************"
	# Check the output for successfull execution
	if [[ $snakemake_output == *"21 of 21 steps (100%) done"* ]] ; then
		echo "All 21 steps of the workflow were executed successfully."
	else
		echo "ERROR: Not all 21 steps of the workflow were executed. See $snakemake_dir/data for intermediate data results."
		exit 2
	fi
	

	# Check intermediate data directories exist:
	expected_dir_list=( "benchmarks" "step0_initial_data_quality" "step1_trimmomatic" "step2_join" "step3_convert_to_fasta" "step4_pick_otu" "step5_pick_representatives" "step6_classify" "step7_otu")

	for (( i=0;i<${#expected_dir_list[@]};i++)); do
		#echo "*** dir is $snakemake_dir/data/${expected_dir_list[${i}]}"
		echo "*** dir is ${i}"
		if [ ! -d "$snakemake_dir/data/${expected_dir_list[${i}]}" ] ; then
			echo "ERROR: Expecting $snakemake_dir/data/${expected_dir_list[${i}]} directory, but did not locate it."
		fi
		exit 2
	done

	# Compare resulting OTU table
	diff_result=$(diff $snakemake_dir/data/step7_otu/otu_table.otu $snakemake_dir/test/data/expected_otu_table.otu )
	if [[ ! -z "${diff_result// }" ]] ; then
		echo "ERROR: otu_table.otu did not match expected."
		exit 2
	fi
}

function clean_test_data {
	echo "Removing test data."
	rm -r $snakemake_dir/data/
}


### Parse arguments

if [ "$#" -eq 0 ]; then
	echo "Usage: "
	echo "    -run   : run the test;"
	echo "    -clean : clean test data"
	exit 0
fi

for i in "$@"
do
	case $i in
		"-run" ) run_test ;;
		"-clean" ) clean_test_data ;;
		* ) echo "ERROR: Unknown argument. Run \"./test.sh\" with no arguments to see the script usage. "
	esac
done

