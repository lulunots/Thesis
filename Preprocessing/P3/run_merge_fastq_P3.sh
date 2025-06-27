script_loc="/home/lulunots/Documents/MEP/Plate3"
out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged"
mkdir -p ${out_loc}
file_locs="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/plate_202"

file_loc_ctrl="${file_locs}/Control"
file_loc_lag="${file_locs}/Lagging"

python "${script_loc}/merge_fastq.py" --input_dir ${file_loc_ctrl} --output_file "${out_loc}/202_control_merged.fastq"  
python "${script_loc}/merge_fastq.py" --input_dir ${file_loc_lag} --output_file "${out_loc}/202_lagging_merged.fastq"  