for platenr in 195 197 199 200
  do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/cutadapt_R2_trimv2"
    mkdir "${out_loc}"
    
    for r2 in "${in_loc}"/processed_${platenr}_R2.fastq
    do
        output_r2="${out_loc}/cutadapt_${platenr}_R2.fastq"
        
        echo "Running cutadapt on R2 file: $r2"
        
        cutadapt -a TTACTATGCCGCTGGTGGCTCTAGATGTGCAAGTCTCAAGATGTCAGGCTGCTAGNNNNNNNNNNNNAAAAAAAAAAAAAAAAAAAAAAAA \
          -a AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA \
          -o "$output_r2" "$r2" -e 0.05
        
        echo "Finished trimming R2 file: $r2"
    done
  done