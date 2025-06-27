# ==========================================================
# Script 3: Auto-generate coldata (sample,condition)
# ==========================================================
# Usage: ./make_coldata_auto.sh <stringtie_output_dir> <output_file>
#   - stringtie_output_dir: directory of sample subfolders
#   - output_file: destination for coldata.csv with header sample,condition

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <stringtie_output_dir> <output_file>"
  exit 1
fi

STR_DIR="$1"
OUT_COLDATA="$2"

# Write header
echo "sample,condition" > "$OUT_COLDATA"

# Loop through each sample directory
for d in "$STR_DIR"/*; do
  if [ -d "$d" ]; then
    SAMPLE=$(basename "$d")
    # Extract last underscore-separated field as condition
    COND=${SAMPLE##*_}
    echo "$SAMPLE,$COND" >> "$OUT_COLDATA"
  fi
done

echo "Coldata written to $OUT_COLDATA"
