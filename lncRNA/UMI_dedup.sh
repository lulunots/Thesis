THREADS=6
INPUT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR/Ungrouped"
OUTPUT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/UMI_dedup"

mkdir -p "$OUTPUT_DIR"

for SORTED_BAM in "$INPUT_DIR"/*/*.Aligned.sortedByCoord.out.bam; do
  BASENAME=$(basename "$SORTED_BAM" .Aligned.sortedByCoord.out.bam)
  SAMPLE_DIR=$(dirname "$SORTED_BAM")
  OUT_DIR="$OUTPUT_DIR/$(basename "$SAMPLE_DIR")"
  mkdir -p "$OUT_DIR"

  echo "$(date): Starting UMI dedup on $BASENAME"  

  umi_tools dedup \
    --stdin "$SORTED_BAM" \
    --stdout "$OUT_DIR/${BASENAME}.dedup.bam" \
    --log "$OUT_DIR/${BASENAME}.dedup.log" \
    --extract-umi-method=read_id \

  samtools index -@ "$THREADS" "$OUT_DIR/${BASENAME}.dedup.bam"

  echo "$(date): Finished UMI dedup on $BASENAME"
done