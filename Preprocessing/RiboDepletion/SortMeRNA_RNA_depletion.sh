REF_PATH="/home/lulunots/Documents/1_ncRNA/4_datafiles/SortMeRNA_database_files/smr_v4.3_default_db.fasta"
THREADS=2  # Adjust this based on your CPU

for platenr in 195 197 199 200; do
    READS_PATH="/home/lulunots/Documents/1_ncRNA/3_fastq/PolyA_trimmed/PolyA_trimmed_${platenr}_R2"
    WORKDIR="/home/lulunots/Documents/1_ncRNA/3_fastq/RiboDepletion/${platenr}"

    # Create or clean work directory
    rm -rf "$WORKDIR"  # Remove previous run if exists
    mkdir -p "$WORKDIR"

    LOG_FILE="${WORKDIR}/run_log.txt" #REDUNDANT

    echo "$(date): Started ribo depletion on ${READS_PATH}.fastq" >> "$LOG_FILE"

    sortmerna --ref "$REF_PATH" \
              --reads "${READS_PATH}.fastq" \
              --workdir "$WORKDIR" \
              --fastx --other \
              --threads $THREADS \
              > "${WORKDIR}/sortmerna.log" 2>&1

    echo "$(date): Finished ribo depletion on ${READS_PATH}.fastq" >> "$LOG_FILE"
    echo "Finished ribo depletion on ${READS_PATH}.fastq"
done

echo "$(date): All sortmerna jobs finished." | tee -a "$LOG_FILE"
