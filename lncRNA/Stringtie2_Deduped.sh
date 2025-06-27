THREADS=6
GTF="/home/lulunots/Documents/1_ncRNA/4_datafiles/GTF/ensembl.GRCh38.r111.gtf"
INPUT_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/UMI_dedup"
OUTPUT_DIR="/media/lulunots/DATA/Analysis/StringTie2_Deduped"

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

for DEDUP_BAM in "$INPUT_DIR"/*/*.dedup.bam; do
  BASENAME=$(basename "$DEDUP_BAM" .dedup.bam)
  LOG="${OUTPUT_DIR}/${BASENAME}.stringtie.log"
  GTF_OUT="${OUTPUT_DIR}/${BASENAME}.gtf"

  echo "$(date): StringTie2 on $BASENAME" | tee -a "$LOG"

  stringtie "$DEDUP_BAM" \
    -p "$THREADS" \
    -G "$GTF" \
    -o "$GTF_OUT" \
    &>> "$LOG"

  echo "$(date): Done $BASENAME → $GTF_OUT" | tee -a "$LOG"
done