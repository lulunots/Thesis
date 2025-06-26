REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
WORKDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/bwaIndex"

for platenr in 195 197 199 200 202; do
    for GROUP in Lagging Control; do
        # Define base directories
        READ_DIR="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/${GROUP}"
        OUTPUT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/Ungrouped/${platenr}_${GROUP}"
        
        # Remove previous output directory if it exists, then create a new one
        rm -rf "$OUTPUT_DIR"
        mkdir -p "$OUTPUT_DIR"
        
        # Loop over each FASTQ file
        for READ_FILE in "$READ_DIR"/*.fastq; do
            BASENAME=$(basename "$READ_FILE" .fastq)
            echo "$(date): Started alignment on ${READ_FILE}"
            
            bwa mem \
                -M \
                -t 16 \
                -T 19 \
                "${WORKDIR}/$(basename "${REF_FASTA}")" \
                "$READ_FILE" \
                > "${OUTPUT_DIR}/${BASENAME}.sam"

            echo "$(date): Finished alignment on ${READ_FILE}"
        done
    done
done
