# Set variables
THREADS=6
REF_GTF="/home/lulunots/Documents/1_ncRNA/4_datafiles/GTF/ensembl.GRCh38.r111.gtf"
STRINGTIE_DIR="/media/lulunots/DATA/Analysis/StringTie2_Deduped"
MERGE_OUT_DIR="/media/lulunots/DATA/Analysis/StringTie2_Merge"
GFFCOMPARE_OUT_DIR="/media/lulunots/DATA/Analysis/GffCompare"
LOG_FILE="$MERGE_OUT_DIR/merge_report.log"

# Create output directories
mkdir -p "$MERGE_OUT_DIR"
mkdir -p "$GFFCOMPARE_OUT_DIR"

# Start log
echo "==== StringTie Merge Report ====" > "$LOG_FILE"
echo "Date: $(date)" >> "$LOG_FILE"
echo "Reference GTF: $REF_GTF" >> "$LOG_FILE"
echo "StringTie GTF Directory: $STRINGTIE_DIR" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Create filtered list of GTFs with transcripts
MERGELIST="$MERGE_OUT_DIR/mergelist.txt"
> "$MERGELIST"

echo "Filtering GTFs for valid transcripts..." | tee -a "$LOG_FILE"
for GTF in "$STRINGTIE_DIR"/*.gtf; do
  if grep -q "transcript_id" "$GTF"; then
    echo "$GTF" >> "$MERGELIST"
    echo "Included: $GTF" >> "$LOG_FILE"
  else
    echo "Skipped (no transcripts): $GTF" >> "$LOG_FILE"
  fi
done

echo "" >> "$LOG_FILE"
echo "Merging valid GTFs..." | tee -a "$LOG_FILE"
MERGED_GTF="$MERGE_OUT_DIR/merged.gtf"
stringtie --merge -p $THREADS -G "$REF_GTF" -o "$MERGED_GTF" "$MERGELIST" &>> "$LOG_FILE"

if [[ -f "$MERGED_GTF" ]]; then
  echo "Merging complete → $MERGED_GTF" | tee -a "$LOG_FILE"
else
  echo "Merging failed. Check above logs." | tee -a "$LOG_FILE"
  exit 1
fi

echo "" >> "$LOG_FILE"
echo "Running Gffcompare on merged GTF..." | tee -a "$LOG_FILE"
gffcompare -r "$REF_GTF" -o "$GFFCOMPARE_OUT_DIR/merged" "$MERGED_GTF" &>> "$LOG_FILE"

echo "Gffcompare complete → ${GFFCOMPARE_OUT_DIR}/merged.*" | tee -a "$LOG_FILE"
echo "==== Done ====" >> "$LOG_FILE"
