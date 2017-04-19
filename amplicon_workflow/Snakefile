""" Amplicon Metagenomics Workflow for GRDI EcoBiomics project.

Version: 0.3
Author: Christine Lowe and Oksana Korol
Date: 2017.04.18

Steps of the workflow:

The firsts rule (rule all:...) specifies the final output of the workflow. 
The rule righ after it is the first step in the workflow. The rest of the 
steps (rules) are specified in order of execution. See message:, version:,
shell: and other keywords to gain understanding what each step is doing.

"""

# Workdir can be changed when executing workflow:
# snakemake --config workdir="data/amplicon_workflow/"
workdir: config["workdir"]

# Unpack the input files:
import os
import os.path
from os.path import join

#dynamically set input directory
INPUTDIR = config["initial_input_dir"]
if not os.path.isabs(config["initial_input_dir"]):
    INPUTDIR=join(config["workdir"],config["initial_input_dir"])
    if not os.path.isabs(config["workdir"]):
        INPUTDIR=join(os.getcwd(),config["initial_input_dir"])

postfix_length =  len(config["input_file_forward_postfix"])
samples_prefix = {f[:-postfix_length] 
    for f in os.listdir(config["initial_input_dir"]) 
    if f.endswith(config["input_file_forward_postfix"])
    }

extension_length = len(config["input_file_extension"])
file_names = {f[:-extension_length] 
    for f in os.listdir(config["initial_input_dir"]) 
    if f.endswith(config["input_file_extension"])
    }

#Patterns for input files 
PATTERN_INITIAL = '{file_name}' + config["input_file_extension"]
PATTERN_TRIM1 = '{sample}' + config["input_file_forward_postfix"]
PATTERN_TRIM2= '{sample}' + config["input_file_reverse_postfix"]

if not os.path.isabs(config["reference_fasta"]):
    if not os.path.isabs(config["workdir"]):
        config["reference_fasta"]=join(os.getcwd(),config["reference_fasta"])
    else:
        config["reference_fasta"]=join(config["workdir"],config["reference_fasta"])

rule all:
    input:       
        # Final step
        "step8_otu/otu_table.otu"

        # representative
        #"step5_pick_representatives/representative_seqs_set.fasta"

        # cluster
        #"step4_pick_otu/all_paired_trimmed_seqs_unsorted_otus.txt"

        # convert to fasta
        #"step3_convert_to_fasta/all_paired_trimmed_seqs_unsorted.fasta"
        #expand("step3_convert_to_fasta/{sample}_trimmed_joined.fasta", sample=samples_prefix)

        # join quality 
        #expand("step2_join/quality/{sample}_fastqjoin.join_fastqc.html", sample=samples_prefix)
        
        # join 
        #expand("step2_join/{sample}_fastqjoin.join.fastq", sample=samples_prefix)

        # trimm quality 
        #expand("step1_trimmomatic/quality/{file_name}_trimmed_fastqc.html", file_name=file_names)

        # trimm 
        #expand("step1_trimmomatic/{sample}_R1_001_trimmed.fastq", sample=samples_prefix),
        #expand("step1_trimmomatic/{sample}_R2_001_trimmed.fastq", sample=samples_prefix),
        
        # initial quality 
        # expand("step0_initial_data_quality/{file_name}_fastqc.html", file_name=file_names),


rule initial_data_quality:
    version: "0.11.2"
    input:
        join(INPUTDIR, PATTERN_INITIAL),
    output:
        "step0_initial_data_quality/{file_name}_fastqc.html",
    message:
        "\n ===== Running FastQC to determine the quality of the initial input data."
    benchmark:
        "benchmarks/step0_initial_data_quality.txt"
    shell:
        """
        initial_data_quality_cmd="fastqc {input} --outdir=step0_initial_data_quality" ;\
        echo "Executed command:\n" $initial_data_quality_cmd ;\
        $initial_data_quality_cmd 
        """

rule trimm:
    version: "0.36"
    input:
        exec = os.path.expanduser(config["trimmomatic"]["path"]),
        forward = join(INPUTDIR,PATTERN_TRIM1),
        reverse = join(INPUTDIR, PATTERN_TRIM2),
        quality = expand("step0_initial_data_quality/{file_name}_fastqc.html", file_name=file_names),
    output:
        forward_paired = "step1_trimmomatic/{sample}_R1_001_trimmed.fastq",
        reverse_paired = "step1_trimmomatic/{sample}_R2_001_trimmed.fastq",
        forward_unpaired = "step1_trimmomatic/{sample}_R1_unpaired.fastq",
        reverse_unpaired = "step1_trimmomatic/{sample}_R2_unpaired.fastq",
    message:
        "\n ===== Trimming input sequences with Trimomatic 0.36"
    benchmark:
        "benchmarks/step1_trimmomatic.txt"
    threads: config["threads"]
    shell:
        """
        touch null.fa
        java -jar {input.exec} PE -threads {threads} -phred33 {input.forward} {input.reverse} \
        {output.forward_paired} {output.forward_unpaired} {output.reverse_paired} {output.reverse_unpaired} \
        ILLUMINACLIP:{config[trimmomatic][ILLUMINACLIP]} \
        HEADCROP:{config[trimmomatic][HEADCROP]} \
        LEADING:{config[trimmomatic][LEADING]} \
        SLIDINGWINDOW:{config[trimmomatic][SLIDINGWINDOW]} \
        TRAILING:{config[trimmomatic][TRAILING]} \
        AVGQUAL:{config[trimmomatic][AVGQUAL]} \
        MINLEN:{config[trimmomatic][MINLEN]} \
        CROP:{config[trimmomatic][CROP]}
        rm null.fa
        """

rule trimm_quality:
    version: "0.11.2"
    input:
        forward = expand("step1_trimmomatic/{sample}_R1_001_trimmed.fastq", sample = samples_prefix) ,
        reverse = expand("step1_trimmomatic/{sample}_R2_001_trimmed.fastq", sample = samples_prefix),
    output:
        forward = "step1_trimmomatic/quality/{sample}_R1_001_trimmed_fastqc.html",
	reverse = "step1_trimmomatic/quality/{sample}_R2_001_trimmed_fastqc.html",
    message:
        "\n ===== Running FastQC to check quality of the trimming."
    benchmark:
        "benchmarks/step1_trimmomatic_quality.txt"
    shell:
        """
        trimm_quality_cmd="fastqc {input.forward} --outdir=step1_trimmomatic/quality" ;\
        echo "Executed command:\n" $trimm_quality_cmd ;\
        $trimm_quality_cmd
        trimm_quality_cmd="fastqc {input.reverse} --outdir=step1_trimmomatic/quality" ;\
        echo "Executed command:\n" $trimm_quality_cmd ;\
        $trimm_quality_cmd
        """

rule join:
    version: "1.9"
    input:
        forward_paired = "step1_trimmomatic/{sample}_R1_001_trimmed.fastq",
        reverse_paired = "step1_trimmomatic/{sample}_R2_001_trimmed.fastq",
        quality_forward = "step1_trimmomatic/quality/{sample}_R1_001_trimmed_fastqc.html",
        quality_reverse = "step1_trimmomatic/quality/{sample}_R2_001_trimmed_fastqc.html"
    output:
        joined_seqs = "step2_join/{sample}_fastqjoin.join.fastq",
        unjoined_forward_seqs = "step2_join/{sample}_fastqjoin.un1.fastq",
        unjoined_reverse_seqs = "step2_join/{sample}_fastqjoin.un2.fastq",
    message:
        "\n ===== Joining forward and reverse paired-end sequences with Qiime 1.9 join_paired_ends.py script."
    benchmark:
        "benchmarks/step2_join.txt"
    threads: 99
    shell:
        """
        join_cmd="join_paired_ends.py -f {input.forward_paired} -r {input.reverse_paired} -o step2_join/ -m fastq-join" ;\
        echo "Executed command:\n" $join_cmd ;\
        $join_cmd ;\
        mv step2_join/fastqjoin.join.fastq {output.joined_seqs} ;\
        mv step2_join/fastqjoin.un1.fastq {output.unjoined_forward_seqs} ;\
        mv step2_join/fastqjoin.un2.fastq {output.unjoined_reverse_seqs} ;\
        """
        #-j 20 -p 2

rule join_quality:
    version: "0.11.2"
    input:
        "step2_join/{sample}_fastqjoin.join.fastq"
    output:
        "step2_join/quality/{sample}_fastqjoin.join_fastqc.html"
    message:
        "Running FastQC to check quality of the join."
    benchmark:
        "benchmarks/step2_join_quality.txt"
    threads: 99
    shell:
        """
        join_quality_cmd="fastqc {input} --outdir=step2_join/quality" ;\
        echo "Executed command:\n" $join_quality_cmd ;\
        $join_quality_cmd
        """

rule convert_fastq_to_fasta_qiime:
    input:
        fastq = expand("step2_join/{sample}_fastqjoin.join.fastq", sample = samples_prefix),
        quality = expand("step2_join/quality/{sample}_fastqjoin.join_fastqc.html", sample = samples_prefix)
    output:
        "step3_convert_to_fasta/all_paired_trimmed_seqs_unsorted.fasta"
    message:
        """\n ===== Converting fastq files to fasta, converting sequence names into qiime acceptable \
format and combining all sequences into one file."""
    benchmark:
        "benchmarks/step3_convert_to_fasta.txt"
    shell:
        """
        for file in {input.fastq}; do \
          echo "Converting file $file" ;\
          sample_id=$(echo $file | rev | cut -d'/' -f1 | rev |cut -d'_' -f1) ;\
          echo "Sample id: $sample_id"
          sed -n '1~4s/^@/>'"$sample_id"'_/p;2~4p' "$file" >> {output}; \
        done
        """

rule cluster_otus:
    version: "1.9"
    input:
        "step3_convert_to_fasta/all_paired_trimmed_seqs_unsorted.fasta"
    output:
        "step4_pick_otu/all_paired_trimmed_seqs_unsorted_otus.txt"  
    message:
        "\n ===== Cluster sequences into OTUs (Operational Taxonomic Units)"
    benchmark:
        "benchmarks/step4_pick_otu.txt"
    shell:
        """
        cluster_otus_cmd="pick_otus.py -i {input} -m uclust -s {config[pick_otus][s]} -o step4_pick_otu" ;\
        echo "Executed command:\n" $cluster_otus_cmd ;\
        $cluster_otus_cmd
        """

rule pick_representatives:
    version: "1.9"
    input:
        otu = "step4_pick_otu/all_paired_trimmed_seqs_unsorted_otus.txt",
        fasta = "step3_convert_to_fasta/all_paired_trimmed_seqs_unsorted.fasta"
    output:
        "step5_pick_representatives/representative_seqs_set.fasta"
    message:
        "\n ===== Pick a representative sequence for each OTU."
    benchmark:
        "benchmarks/step5_pick_representatives.txt"
    shell:
        """
        pick_representatives_cmd="pick_rep_set.py -i {input.otu} -f {input.fasta} -m longest -o {output}" ;\
        echo "Executed command:\n" $pick_representatives_cmd ;\
        $pick_representatives_cmd
        """
rule check_chimeric_sequences:
    version: "1.9.1"
    input:
        dataset = "step5_pick_representatives/representative_seqs_set.fasta",
        reference_fasta = config["reference_fasta"],
        reference_txt = config["reference_taxonomy"]
    output:
        chimeric_list = "step6_removeChimericSeqs/chimeraList.txt",
        rep_set = "step6_removeChimericSeqs/representative_seq_noChimera.fasta"
    message:
        "\n ===== Check for chimeras and remove chimeric clusters."
    benchmark:
        "benchmarks/step6_check_chimeric_sequences.txt"
    shell:
        """
        check_chimeric_seqs_cmd="parallel_identify_chimeric_seqs.py -i {input.dataset} -t {input.reference_txt} -r {input.reference_fasta} -m blast_fragments -o {output.chimeric_list} -O {config[threads]}" ;\
        echo "Executed command:\n" $check_chimeric_seqs_cmd ;\
        $check_chimeric_seqs_cmd
        remove_chimeric_seqs_cmd="filter_fasta.py -f {input.dataset} -o {output.rep_set} -s {output.chimeric_list} -n" ;\
        echo "Executed command:\n" $remove_chimeric_seqs_cmd ;\
        $remove_chimeric_seqs_cmd
        """

rule classify:
    version: "1.9"
    input:
        dataset = "step6_removeChimericSeqs/representative_seq_noChimera.fasta",
        reference_fasta = config["reference_fasta"],
        reference_txt = config["reference_taxonomy"]
    output:
        "step7_classify/representative_seq_noChimera_tax_assignments.txt"
    message:
        "\n ===== Classify (i.e. assign taxonomy) to representative sequences."
    benchmark:
        "benchmarks/step7_classify.txt"
    shell:
       """
       classify_cmd="parallel_assign_taxonomy_rdp.py -i {input.dataset} -o step7_classify \
       -r {input.reference_fasta} -t {input.reference_txt} --rdp_max_memory 10000 -c {config[assign_taxonomy][c]} -O {config[threads]}" ;\
       echo "Executed command:\n" $classify_cmd ;\
       $classify_cmd
       """
        
rule make_otu:
    version: "1.9"
    input: 
        assigned_taxonomy = "step7_classify/representative_seq_noChimera_tax_assignments.txt",
        otu = "step4_pick_otu/all_paired_trimmed_seqs_unsorted_otus.txt"
    output:
        "step8_otu/otu_table.biom"
    message:
        """\n ===== Make OTU table as a biom file. \n Biom file: the columns correspond to Samples\
 and rows correspond to OTUs and the number of times a sample appears in a particular OTU."""
    benchmark:
        "benchmarks/step8_otu_make_otu.txt"
    shell:
        """
        make_otu_cmd="make_otu_table.py -i {input.otu} -t {input.assigned_taxonomy} -o {output}" ;\
        echo "Executed command:\n" $make_otu_cmd ;\
        $make_otu_cmd
        """

rule convert_otu_table:
    input:
        "step8_otu/otu_table.biom"
    output:
        "step8_otu/otu_table.otu"
    message:
        "\n ===== Convert OTU table in biom format to tab-delimited table format. "
    benchmark:
        "benchmarks/step8_otu_convert_otu.txt"
    shell:
        """
        convert_otu_table_cmd="biom convert -i {input} -o {output} --to-tsv --header-key taxonomy" ;\
        echo "Executed command:\n" $convert_otu_table_cmd ;\
        $convert_otu_table_cmd
        """
