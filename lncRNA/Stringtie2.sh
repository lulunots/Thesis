GTF="/home/lulunots/Documents/1_ncRNA/4_datafiles/GTF/ensembl.GRCh38.r111.gtf" # The Ensembl one since it is ok for lncRNA and the reference genome was also from Ensembl
THREADS=6
OUTPUT="/home/lulunots/Documents/1_ncRNA/6_analysis/StringTie2"

# create clean output directory
rm -rf "$OUTPUT"  # Remove previous run if exists
mkdir -p "$OUTPUT"

for platenr in 195 197 199 200 202; do
    for GROUP in lagging control; do
        INPUT="/home/lulunots/Documents/1_ncRNA/7_alignment/STAR/${platenr}_${GROUP}/Aligned.sorted.bam"
        
        echo "$(date): Started processing ${INPUT}"

        stringtie -v "${INPUT}" \
        -p "${THREADS}" \
        -G "${GTF}" \
        -o "${OUTPUT}/${platenr}_${GROUP}.gtf" \
        > "${OUTPUT}/${platenr}_${GROUP}.log" 2>&1

        echo "$(date): Finished processing ${INPUT}"            
    done
done