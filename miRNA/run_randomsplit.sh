OUT_FOLDER="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Shuffled"

rm -rf "$OUT_FOLDER"
mkdir -p "$OUT_FOLDER"


for PATIENT in 1 2 3; do
    for GROUP in lagging control; do
        FASTQ="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Patients/P${PATIENT}_${GROUP}.fastq"
        OUTPUT="${OUT_FOLDER}/P${PATIENT}_${GROUP}"
        
        rm -rf "$OUTPUT"
        mkdir -p "$OUTPUT"

        /home/lulunots/Documents/MEP/miRMaster/randomly_split_fastq_three.sh "${FASTQ}" "${OUTPUT}/P${PATIENT}_${GROUP}"
    done
done
