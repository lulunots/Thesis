for platenr in 195 197 199 200
do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/trimgalore/cutadapt_${platenr}_R2_cutfive_reverse_control.fastq"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/trimgalore"
    mkdir -p "${out_loc}"

    # Define the file to process (assuming one file per platenr)
    r2="${in_loc}/processed_${platenr}_R2_trimmed.fq"
    output_r2="${in_loc}/cutadapt_${platenr}_R2_homopolymers.fastq"

    echo "Running cutadapt on R2 file: $r2"

    cutadapt -m 15 --trim-n -a "polyG1=GG{5}" -a "polyC1=CC{5}" -a "polyT1=TT{5}" -a "polyA1=AA{5}" -o "${output_r2}" "$r2"

    echo "Finished trimming R2 file: $r2"

done
