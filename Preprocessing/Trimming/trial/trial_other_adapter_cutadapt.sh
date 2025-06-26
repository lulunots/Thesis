for platenr in 195 197 199 200
  do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/cutadapt_R2_trimv2"
    mkdir -p "${out_loc}"
    
    for r2 in "${in_loc}"/processed_${platenr}_R2.fastq
    do
        output_r2="${out_loc}/cutadapt_${platenr}_R2_reverse_trial_five.fastq"
        
        echo "Running cutadapt on R2 file: $r2"
        
        cutadapt -g TGGAATTCTCGGGTGCCAAGGAACTCCAGTCAC \
          -o "$output_r2" "$r2" -e 0.05 > cutadapt_${platenr}_R2_reverse_trial_five.log 2>&1 
        
        echo "Finished trimming R2 file: $r2"
    done
  done