# Check for input file
if [ $# -lt 1 ]; then
    echo "Usage: $0 input.fastq [output_prefix]"
    exit 1
fi

INPUT=$1
BASENAME=$(basename "$INPUT" .fastq)

# Check for optional output prefix
if [ $# -ge 2 ]; then
    BASENAME=$2
fi

SHUFFLED="${BASENAME}_shuffled.fastq"

# Ensure output directory exists
OUTDIR=$(dirname "$BASENAME")
mkdir -p "$OUTDIR"

LENGTH_OG=$(wc -l < "$INPUT")

# Step 1: Shuffle the FASTQ file
echo "Shuffling FASTQ file..."
seqtk sample -s 100 "$INPUT" $LENGTH_OG > "$SHUFFLED"

# Step 2: Count total reads
total_lines=$(wc -l < "$SHUFFLED")
total_reads=$((total_lines / 4))
split_size=$((total_reads / 3))

echo "Total lines: $total_lines"
echo "Total reads: $total_reads"
echo "Reads per split: ~$split_size"

# Step 3: Split into three parts
awk -v n=$split_size -v base="$BASENAME" '{
    file = int((NR-1)/(4*n));
    if (file > 2) file = 2;  # Ensure only 3 files
    fname = sprintf("%s_part%d.fastq", base, file+1);
    print >> fname
}' "$SHUFFLED"

echo "Done. Output files: ${BASENAME}_part1.fastq, ${BASENAME}_part2.fastq, ${BASENAME}_part3.fastq"