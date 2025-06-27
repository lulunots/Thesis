# Check for at least two input files and one output file
if [ $# -lt 2 ]; then
    echo "Usage: $0 output.fastq input1.fastq input2.fastq [input3.fastq ...]"
    exit 1
fi

# Get the output file name
OUTPUT=$1

# Make the remaining arguments only the input files
shift

# Combine all input files into the output file
cat "$@" > "$OUTPUT"

echo "Combined FASTQ files into $OUTPUT"