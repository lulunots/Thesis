REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
WORKDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/bwaIndex"

for platenr in 195 197 199 200 202; do
    for GROUP in lagging control; do
        # Define file paths
        READS="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged/${platenr}_${GROUP}_merged.fastq"
        OUTPUT="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/Grouped/${platenr}_${GROUP}"
        
        # Remove previous output directory if it exists, create (a new) one
        rm -rf "$OUTPUT"
        mkdir -p "$OUTPUT"

        echo "$(date): Started alignment on ${READS}"
        
        # Run bwa to generate a SAM file
        bwa mem \
        -M \
        -t 16 \
        -T 19 \
        "${WORKDIR}/$(basename "${REF_FASTA}")" \
        "${READS}" \
        > "${OUTPUT}/${platenr}_${GROUP}.sam"

    done
done
