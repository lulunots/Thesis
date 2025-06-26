for platenr in 195 197 199 200
do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/adapter_trimmed"
    mkdir -p "${out_loc}"

    for r2 in "${in_loc}"/processed_${platenr}_R2.fastq
    do
        output_1="${out_loc}/P5RA5_${platenr}_R2"
        output_2="${out_loc}/UMI_BC_${platenr}_R2"
        output_3="${out_loc}/PolyA_${platenr}_R2"
        output_4="${out_loc}/RA3_${platenr}_R2"

        echo "Running P5 and RA5 adapter trimming by cutadapt on R2 file: $r2"
        cutadapt -a TTACTATGCCGCTGGTGGCTCTAGATGTGCAAGTCTCAAGATGTCAGGCTGCTAGX \
          -o "${output_1}.fastq" "$r2" -e 0.05 > "${output_1}.log" 2>&1
        echo "Finished P5 and RA5 adapter trimming by cutadapt on R2 file: $r2"

        echo "Started UMI and Barcode trimming by custom python script on file ${output_1}.fastq"
        python3 Preprocessing/custom_UMI_BC_trim.py "${output_1}.fastq" "${output_2}.fastq" > "${output_2}.log" 2>&1
        echo "Finished UMI and Barcode trimming by custom python script on file ${output_2}.fastq"

        echo "Running poly(A) trimming by cutadapt on file: ${output_2}.fastq"
        cutadapt --poly-a \
          -o "${output_3}.fastq" "${output_2}.fastq" > "${output_3}.log" 2>&1
        echo "Finished poly(A) trimming by cutadapt on file: ${output_3}.fastq"

        echo "Running reverse RA3 adapter trimming by cutadapt on file: ${output_3}.fastq"
        cutadapt -g XCACTGACCTCAAGGAACCGTGGGCTCTTAAGGT \
          -o "${output_4}.fastq" "${output_3}.fastq" -e 0.05 > "${output_4}.log" 2>&1
        echo "Finished reverse RA3 adapter trimming by cutadapt on file: ${output_4}.fastq"

    done
done