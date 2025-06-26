# Set variables
THREADS=6
MERGED_GTF="/home/lulunots/Documents/1_ncRNA/6_analysis/StringTie2_Merge/merged.gtf"
OUTPUT_BASE="/home/lulunots/Documents/1_ncRNA/8_expression/StringTie2_Quant"
ALIGNMENT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR/Ungrouped"
LOG_FILE="$OUTPUT_BASE/requantify_report.log"

# Create output directory
mkdir -p "$OUTPUT_BASE"
echo "==== StringTie Re-Quantification Report ====" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "Merged GTF: $MERGED_GTF" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Loop through all BAM files
find "$ALIGNMENT_DIR" -name "*.Aligned.sortedByCoord.out.bam" | while read -r BAM; do
  SAMPLE_NAME=$(basename "$BAM" .Aligned.sortedByCoord.out.bam)
  SAMPLE_DIR="$OUTPUT_BASE/$SAMPLE_NAME"
  mkdir -p "$SAMPLE_DIR"

  echo "$(date): Quantifying $SAMPLE_NAME" | tee -a "$LOG_FILE"

  stringtie "$BAM" \
    -e -B -p $THREADS \
    -G "$MERGED_GTF" \
    -o "$SAMPLE_DIR/transcripts.gtf" \
    &>> "$LOG_FILE"

  echo "$(date): Done $SAMPLE_NAME → $SAMPLE_DIR" | tee -a "$LOG_FILE"
done

echo "==== All samples processed ====" >> "$LOG_FILE"
