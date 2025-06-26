# === CONFIGURATION ===
CIRI2_DIR="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped"
BAM_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/Ungrouped"
GENOME_FA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
ANNOTATION_GTF="/path/to/your/annotation.gtf"  # Update this path
OUTPUT_DIR="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRIquant"
THREADS=6
CIRIQUANT="CIRIquant"

# # === ACTIVATE ENVIRONMENT ===
# conda activate ciriquant_py2

# # === CHECK IF CIRIquant.py IS AVAILABLE ===
# if ! command -v CIRIquant.py &> /dev/null; then
#     echo "❌ CIRIquant.py not found. Make sure it's installed in your conda environment."
#     exit 1
# fi

# === CREATE OUTPUT DIRECTORY ===
mkdir -p "$OUTPUT_DIR"

# === CREATE SAMPLE GROUP FILE ===
GROUP_FILE="${OUTPUT_DIR}/sample_groups.txt"
echo -e "Sample\tGroup" > "$GROUP_FILE"
for platenr in 195 197 199 200 202; do
    echo -e "${platenr}_Lagging\tLagging" >> "$GROUP_FILE"
    echo -e "${platenr}_Control\tControl" >> "$GROUP_FILE"
done

# === RUN CIRIquant ===
for platenr in 195 197 199 200 202; do
    for GROUP in Lagging Control; do
        SAMPLE="${platenr}_${GROUP}"
        CIRI_FILE="${CIRI2_DIR}/${SAMPLE}.ciri"
        BAM_FILE="${BAM_DIR}/${SAMPLE}.bam"
        SAMPLE_OUTPUT_DIR="${OUTPUT_DIR}/${SAMPLE}"

        mkdir -p "$SAMPLE_OUTPUT_DIR"

        echo "$(date): Started CIRIquant analysis on ${SAMPLE}"

        "${CIRIQUANT}" \
            -t $THREADS \
            -1 "$CIRI_FILE" \
            -2 "$BAM_FILE" \
            -r "$GENOME_FA" \
            -a "$ANNOTATION_GTF" \
            -o "$SAMPLE_OUTPUT_DIR" \
            --merge \
            --group "$GROUP_FILE" \
            --visual

        echo "$(date): Finished CIRIquant analysis on ${SAMPLE}"
    done
done

echo "✅ CIRIquant analysis complete. Results saved to $OUTPUT_DIR"
