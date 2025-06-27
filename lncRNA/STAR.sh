THREADS=6  # Adjust this based on your CPU capacity
GENDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Output"

for platenr in 195 197 199 200 202; do
    for GROUP in Lagging Control; do
        # Define base directories
        READ_DIR="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/${GROUP}"
        OUTPUT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR/Ungrouped/${platenr}_${GROUP}"
        
        # Remove previous output directory if it exists, then create a new one
        rm -rf "$OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
        
        # Loop over each FASTQ file
        for READ_FILE in "$READ_DIR"/*.fastq; do
            BASENAME=$(basename "$READ_FILE" .fastq) # The filename without the directory path or the .fastq extension. This is handy to have to define the output later on
            echo "$(date): Started alignment on ${READ_FILE}"
            
            STAR \
            --readFilesIn "$READ_FILE" \
            --genomeDir "$GENDIR" \
            --runThreadN "$THREADS" \
            --outFileNamePrefix "$OUTPUT_DIR/${BASENAME}." \
            --outSAMtype BAM SortedByCoordinate \
            > "${OUTPUT_DIR}/${BASENAME}_alignment.log" 2>&1

            # Index the .bam
            BAM="${OUTPUT_DIR}/${BASENAME}.Aligned.sortedByCoord.out.bam"
            samtools index -@ "$THREADS" "$BAM"

            echo "$(date): Finished alignment on ${READ_FILE}"
        done
    done
done
