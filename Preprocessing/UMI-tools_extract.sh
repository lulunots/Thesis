CB_whitelist=/home/lulunots/Documents/1_ncRNA/4_datafiles/SORTseq_cellbarcodes.tsv

for platenr in 195 197 199 200
do  
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/ERA-MC-v${platenr}_fastq"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    mkdir "${out_loc}"
    
    for r1 in "${in_loc}"/*R1_001.fastq
    do
        # Define the corresponding R2 file by replacing R1 with R2 in the filename
        r2="${r1/R1_001.fastq/R2_001.fastq}"

        # Extract the base filenames for R1 and R2 using basename
        r1_basename=$(basename "$r1")
        r2_basename=$(basename "$r2")

        # Define the output filenames
        output_r1="${out_loc}/processed_${platenr}_R1.fastq"
        output_r2="${out_loc}/processed_${platenr}_R2.fastq"

        # Print the file being processed
        echo "UMI extraction on reads in R1 file: $r1"
        echo "Processing R2 file: $r2"

        # Run umi_tools extract
        umi_tools extract \
          --stdin="$r1" \
          --stdout="$output_r1" \
          --bc-pattern=NNNNNNCCCCCCCC \
          --read2-in="$r2" \
          --read2-out="$output_r2" \
          --whitelist "$CB_whitelist" \
          --log="${out_loc}/umi_tools_${platenr}_log.txt"

        # Print finished message
        echo "Finished UMI extraction on R1 file: $r1"
        echo "Finished processing R2 file: $r2"
    done
done
