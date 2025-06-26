THREADS=6
REF_GTF="/home/lulunots/Documents/1_ncRNA/4_datafiles/GTF/ensembl.GRCh38.r111.gtf"
STRINGTIE_DIR="/home/lulunots/Documents/1_ncRNA/6_analysis/StringTie2"
GFFCOMPARE_OUT_DIR="/home/lulunots/Documents/1_ncRNA/6_analysis/GffCompare"

rm -rf "$GFFCOMPARE_OUT_DIR"
mkdir -p "$GFFCOMPARE_OUT_DIR"

for CELL_GTF in "$STRINGTIE_DIR"/*.gtf; do
  BASENAME=$(basename "$CELL_GTF" .gtf)
  LOG="${GFFCOMPARE_OUT_DIR}/${BASENAME}.gffcompare.log"
  OUT_PREFIX="${GFFCOMPARE_OUT_DIR}/${BASENAME}"

  echo "$(date): GffCompare on $BASENAME" | tee -a "$LOG"

  gffcompare \
    -r "$REF_GTF" \
    -o "$OUT_PREFIX" \
    "$CELL_GTF" \
    &>> "$LOG"

  echo "$(date): Done $BASENAME → ${OUT_PREFIX}.tracking" | tee -a "$LOG"
done
