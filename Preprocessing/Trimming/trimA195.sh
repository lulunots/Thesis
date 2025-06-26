for platenr in 195
do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/trimgalore/cutadapt_${platenr}_R2_cutfive_reverse_control.fastq"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/onlyA_195"
    mkdir -p "${out_loc}"

    # Define the file to process (assuming one file per platenr)
    r2="${in_loc}/processed_${platenr}_R2_trimmed.fq"
    output_r2="${out_loc}/195_polyAtrim"

    echo "Running cutadapt on R2 file: $r2"

    cutadapt -m 15 --trim-n -a "polyA1=AA{5}" -o "${output_r2}.fastq" "$r2"  > "${output_r2}.log" 2>&1

    echo "Finished trimming R2 file: $r2"
done
