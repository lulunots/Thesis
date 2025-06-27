REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
CIRI2="/home/lulunots/Documents/software/CIRI_v2.0.6/CIRI2.pl"
WORKDIR="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped"
THREADS="6"     

for platenr in 195 197 199 200 202; do
    for GROUP in Lagging Control; do
        # Define base directories
        READ_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/Ungrouped/${platenr}_${GROUP}"
        OUTPUT_DIR="${WORKDIR}/${platenr}_${GROUP}"

        # Remove previous output directory if it exists, then create a new one
        rm -rf "$OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
        
        # Loop over each FASTQ file
        for READ_FILE in "$READ_DIR"/*.sam; do
            BASENAME=$(basename "$READ_FILE" .sam)
            
            echo "$(date): Started CIRI2 analysis on ${READ_FILE}"
                
            # 2) CIRI2 circular RNA detection
            perl "${CIRI2}" \
            -I "${READ_DIR}/${BASENAME}.sam" \
            -O "${OUTPUT_DIR}/${BASENAME}.ciri" \
            -F "${REF_FASTA}" \
            --thread_num "${THREADS}"              
            # --log "${OUTPUT}_log" \               # think it already produces an output file?
            # -0 \                                  # perhaps do one run with -low, and one with -0
            # -A "${GTF}"                           # this one is optional, and I dont have the GTF so left it out

            echo "$(date): Finished CIRI2 analysis on ${READ_FILE}"

        done
    done
done
