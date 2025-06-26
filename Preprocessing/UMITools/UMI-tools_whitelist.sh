for platenr in 195 197 199 200
do  
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/ERA-MC-v${platenr}_fastq"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    
    for r1 in "${in_loc}"/*R1_001.fastq
    do
        # Extract the base filenames for R1 and R2 using basename
        r1_basename=$(basename "$r1")

        # Define the output filenames
        output_r1="${out_loc}/processed_${platenr}_R1.fastq"

        # Print the file being processed
        echo "Whitelist extraction on reads in R1 file: $r1"

        # Run umi_tools whitelist
        umi_tools whitelist \
          -I "$r1" \
          -S "${out_loc}/whitelist_out.tsv" \
          --bc-pattern=NNNNNNCCCCCCCC \
          --log="${out_loc}/umi_tools_${platenr}_log.txt"

        # Print finished message
        echo "Finished whitelist extraction on R1 file: $r1"
    done
done
