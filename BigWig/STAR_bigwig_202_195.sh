# Number of threads for conversion, sorting and indexing
THREADS=6

# Number of threads to use with bamCoverage
BIGWIG_THREADS=8

# Directory containing STAR alignment outputs (each sample in a subdirectory)
STAR_ALIGN_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR"

# Output directory for BigWig files from STAR alignments
BIGWIG_OUT="/home/lulunots/Documents/1_ncRNA/6_analysis/BigWig/STAR"

# Create the BigWig parent directory if it doesn't exist
mkdir -p "$BIGWIG_OUT"

# Loop through plate numbers and sample groups
for platenr in 195 202; do
    for GROUP in lagging control; do
        
        # Define the STAR sample directory and expected SAM file name
        SAMPLE_DIR="${STAR_ALIGN_DIR}/${platenr}_${GROUP}"
        SAM_FILE="${SAMPLE_DIR}/Aligned.out.sam"
               
        echo "$(date): Processing STAR alignment file ${SAM_FILE}"
    
        # Define paths for intermediate and final BAM files
        UNSORTED_BAM="${SAMPLE_DIR}/Aligned.unsorted.bam"
        SORTED_BAM="${SAMPLE_DIR}/Aligned.sorted.bam"
        
        # Convert SAM to unsorted BAM
        samtools view -@ "$THREADS" -bS "$SAM_FILE" > "$UNSORTED_BAM"
        
        # Sort the BAM file
        samtools sort -@ "$THREADS" "$UNSORTED_BAM" -o "$SORTED_BAM"
        
        # Index the sorted BAM file
        samtools index "$SORTED_BAM"
        
        echo "$(date): Sorted and indexed BAM created at ${SORTED_BAM}"
        
        # Create a unique output subdirectory in the BigWig directory for each sample
        SAMPLE_BIGWIG_OUT="${BIGWIG_OUT}/${platenr}_${GROUP}"
        mkdir -p "$SAMPLE_BIGWIG_OUT"
        
        # Define the output BigWig file name
        BIGWIG_FILE="${SAMPLE_BIGWIG_OUT}/Aligned.bw"
        
        # Run bamCoverage to generate the BigWig file with desired parameters
        bamCoverage -b "$SORTED_BAM" \
                    -o "$BIGWIG_FILE" \
                    --normalizeUsing CPM \
                    --binSize 50 \
                    --smoothLength 150 \
                    --ignoreDuplicates \
                    -p "$BIGWIG_THREADS" > "${SAMPLE_BIGWIG_OUT}/bamCoverage.log" 2>&1
        
        if [ $? -eq 0 ]; then
            echo "$(date): BigWig file successfully created: ${BIGWIG_FILE}"
        else
            echo "$(date): Error encountered while creating BigWig for ${SORTED_BAM}" >&2
        fi
        
        # Optional: Remove intermediate SAM and unsorted BAM files to save space.
        # Uncomment the following lines if you wish to remove them:
        # rm "$SAM_FILE"
        # rm "$UNSORTED_BAM"
        
    done
done
