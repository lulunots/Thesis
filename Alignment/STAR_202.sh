THREADS=6  # Adjust this based on your CPU capacity
GENDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Output"

for platenr in 195 202; do
    
    for GROUP in lagging control; do
        READS="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged/${platenr}_${GROUP}_merged.fastq"
        OUTPUT="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR/${platenr}_${GROUP}/"
        
        # create clean output directory
        rm -rf "$OUTPUT"  # Remove previous run if exists
        mkdir -p "$OUTPUT"

        echo "$(date): Started alignment on ${READS}"

        STAR "$REF_PATH" \
            --readFilesIn "${READS}" \
            --genomeDir "$GENDIR" \
            --runThreadN $THREADS \
            --outFileNamePrefix $OUTPUT \
            > "${OUTPUT}/alignment.log" 2>&1
        
        echo "$(date): Finished alignment on ${READS}"

    done
done