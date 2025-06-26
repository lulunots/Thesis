## NOTE: I wrote this for fastq but need to rewrite it for .bam

for platenr in 195 197 199 200; do
    
    OUTPUT="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI_Deduped"

    # Create or clean work directory
    rm -rf "$OUTPUT"  # Remove previous run if exists
    mkdir -p "$OUTPUT"

    LOG_FILE="${OUTPUT}/run_log.txt"

    for GROUP in lagging control; do
        READS="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged/${platenr}_${GROUP}_merged.fastq" #NO I NEED .BAM FILES!
        
        echo "$(date): Started UMI dedip on ${READS}"

        umi_tools dedup --stdin=$READS --stdout=$OUTPUT --log=LOGFILE [OPTIONS] > LOG_FILE 

        echo "$(date): Finished UMI dedup on ${READS}"
    done

done

echo "$(date): All dedup jobs finished." | tee -a "$LOG_FILE"