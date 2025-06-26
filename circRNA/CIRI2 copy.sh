REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
# GTF="/annotation/human_gencode_vch38.gtf" # Optional
CIRI2="/home/lulunots/Documents/software/CIRI_v2.0.6/CIRI2.pl"
WORKDIR="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2"
THREADS="8"

for platenr in 195 197 199 200 202; do
    for GROUP in lagging control; do
        # Define file paths
        INPUT="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/${platenr}_${GROUP}/${platenr}_${GROUP}.sam"
        OUTPUT="${WORKDIR}/${platenr}_${GROUP}"
        
        # Remove previous output directory if it exists, create (a new) one
        rm -rf "$OUTPUT"
        mkdir -p "$OUTPUT"

        echo "$(date): Started CIRI2 analysis on ${INPUT}"
               
        # 2) CIRI2 circular RNA detection
        perl "${CIRI2}" \
        -I "${INPUT}" \
        -O "${OUTPUT}/${platenr}_${GROUP}.ciri" \
        -F "${REF_FASTA}" \
        --thread_num "${THREADS}" \   #gives an error, command not found
        --log "${OUTPUT}_log" \
        -0 #perhaps do one run with -low, and one with -0
       # -A "${GTF}" \     #this one is optional
        
    done
done




