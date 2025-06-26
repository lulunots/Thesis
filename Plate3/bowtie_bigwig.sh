# Number of threads for bamCoverage (adjust as needed)
BIGWIG_THREADS=8

# Define the parent directory where your sorted BAM files are stored.
# This is where your previous alignment script put your outputs.
ALIGNMENT_DIR="/home/lulunots/Documents/1_ncRNA/alignment/bowtie2"

# Define the parent directory for the BigWig outputs
BIGWIG_OUT="/home/lulunots/Documents/1_ncRNA/6_analysis/BigWig/bowtie2"

# Create the BigWig parent directory if it doesn't exist
mkdir -p "$BIGWIG_OUT"

# Loop over your plate numbers and sample groups
for platenr in 202; do
    for GROUP in lagging control; do
        # Construct the directory path where the sorted BAM is stored
        SAMPLE_DIR="${ALIGNMENT_DIR}/${platenr}_${GROUP}"
        BAM_FILE="${SAMPLE_DIR}/alignment.sorted.bam"

        # Check if the sorted BAM file exists
        if [ ! -f "$BAM_FILE" ]; then
            echo "$(date): Error - BAM file not found: ${BAM_FILE}" >&2
            continue
        fi

        # Create a corresponding output subdirectory for BigWig file
        SAMPLE_BIGWIG_OUT="${BIGWIG_OUT}/${platenr}_${GROUP}"
        mkdir -p "$SAMPLE_BIGWIG_OUT"

        # Define the output BigWig file path
        BIGWIG_FILE="${SAMPLE_BIGWIG_OUT}/alignment.bw"

        echo "$(date): Running bamCoverage on ${BAM_FILE}"

        # Run bamCoverage using specified parameters
        bamCoverage -b "$BAM_FILE" \
                    -o "$BIGWIG_FILE" \
                    --normalizeUsing CPM \
                    --binSize 50 \
                    --smoothLength 150 \
                    --ignoreDuplicates \
                    -p "$BIGWIG_THREADS" > "${SAMPLE_BIGWIG_OUT}/bamCoverage.log" 2>&1

        if [ $? -eq 0 ]; then
            echo "$(date): BigWig file created: ${BIGWIG_FILE}"
        else
            echo "$(date): bamCoverage encountered an error for ${BAM_FILE}" >&2
        fi
    done
done
