# Set the genome index directory (ensure it is a valid Bowtie2 index directory)
GENDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/bowtie2Index/GRCh38_index"

# Number of threads to use in alignment and sorting/indexing steps
THREADS=6

for platenr in 195; do
    for GROUP in lagging; do
        # Define file paths
        READS="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged/${platenr}_${GROUP}_merged.fastq"
        OUTPUT="/home/lulunots/Documents/1_ncRNA/7_alignment/bowtie2/${platenr}_${GROUP}/"
        
        # Remove previous output directory if it exists, create (a new) one
        rm -rf "$OUTPUT"
        mkdir -p "$OUTPUT"

        echo "$(date): Started alignment on ${READS}"
        
        # Run Bowtie2 to generate a SAM file
        bowtie2 -x "$GENDIR" \
                -U "$READS" \
                -S "${OUTPUT}/alignment.sam" \
                -p "$THREADS" > "${OUTPUT}/bowtie2.log" 2>&1

        echo "$(date): Finished alignment on ${READS}"
        
        # Convert SAM to BAM, sort and index it
        echo "$(date): Converting SAM to BAM, sorting and indexing."
        
        # Convert SAM to unsorted BAM using samtools view
        samtools view -@ "$THREADS" -bS "${OUTPUT}/alignment.sam" > "${OUTPUT}/alignment.unsorted.bam"
        
        # Sort the BAM file using samtools sort
        samtools sort -@ "$THREADS" "${OUTPUT}/alignment.unsorted.bam" -o "${OUTPUT}/alignment.sorted.bam"
        
        # Index the sorted BAM file
        samtools index "${OUTPUT}/alignment.sorted.bam"
        
        echo "$(date): Finished processing ${READS}. Sorted and indexed BAM is available at ${OUTPUT}"

        # Optionally, you can remove intermediate files to save space
        rm "${OUTPUT}/alignment.sam"
        rm "${OUTPUT}/alignment.unsorted.bam"
    done
done
