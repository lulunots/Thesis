for platenr in 195 197 199 200
do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/trimgalore"
    mkdir -p "${out_loc}"

    # Define the file to process (assuming one file per platenr)
    r2="${in_loc}/processed_${platenr}_R2.fastq"
    output_r2="${out_loc}/cutadapt_${platenr}_R2_cutfive_reverse_control.fastq"

    echo "Running trimgalore on R2 file: $r2"

    trim_galore --path_to_cutadapt /home/lulunots/anaconda3/bin/cutadapt --output_dir "$output_r2" "$r2"

    echo "Finished trimming R2 file: $r2"
done
