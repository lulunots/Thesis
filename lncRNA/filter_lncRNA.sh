# ==========================================================
# Script 2: Filter for lncRNA genes
# ==========================================================
# Usage: ./filter_lncRNA.sh <merged_gtf> <gene_count_matrix.csv> <output_dir>
#   - merged_gtf: the merged annotation GTF file
#   - gene_count_matrix.csv: full gene count matrix from Script 1
#   - output_dir: directory for filtered counts

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <merged_gtf> <gene_count_matrix.csv> <output_dir>"
  exit 1
fi

MERGED_GTF="$1"
FULL_MATRIX="$2"
FILTER_DIR="$3"

mkdir -p "$FILTER_DIR"

# Extract lncRNA gene IDs (by biotype tag: lincRNA, antisense, process, etc.)
# Adjust the biotypes as needed
awk '$3 == "gene" && /gene_biotype="(lincRNA|antisense|sense_intronic|sense_overlapping|bidirectional_promoter_lncRNA)"/ {
    match($0, /gene_id="([^"]+)"/, arr)
    print arr[1]
}' "$MERGED_GTF" | sort | uniq > "$FILTER_DIR/lncRNA_gene_ids.txt"

echo "Found $(wc -l < $FILTER_DIR/lncRNA_gene_ids.txt) lncRNA genes"

# Subset the count matrix
# Keep header, then only rows with IDs in our list
awk -F"," 'NR==1 { print; next } FNR==NR { ids[$1]; next } ($1 in ids)' \
  "$FILTER_DIR/lncRNA_gene_ids.txt" "$FULL_MATRIX" \
  > "$FILTER_DIR/gene_count_matrix_lncRNA.csv"

echo "Filtered lncRNA count matrix written to $FILTER_DIR/gene_count_matrix_lncRNA.csv"