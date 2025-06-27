for platenr in 195 197 199 200
do
    script_loc="/home/lulunots/Documents/MEP/Demultiplexing"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged"
    mkdir -p ${out_loc}

    file_loc_ctrl="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/Control"
    file_loc_lag="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/Lagging"

    python "${script_loc}/merge_fastq.py" --input_dir ${file_loc_ctrl} --output_file "${out_loc}/${platenr}_control_merged.fastq"  
    python "${script_loc}/merge_fastq.py" --input_dir ${file_loc_lag} --output_file "${out_loc}/${platenr}_lagging_merged.fastq"  
done