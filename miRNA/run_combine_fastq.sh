IN_PATH="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Merged"
OUT_PATH="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/Patients"

rm -rf "$OUT_PATH"
mkdir -p "$OUT_PATH"

# P1
## control
/home/lulunots/Documents/MEP/miRMaster/combine_fastq.sh "${OUT_PATH}/P1_control.fastq" "${IN_PATH}/195_control_merged.fastq" "${IN_PATH}/197_control_merged.fastq"
## lagging
/home/lulunots/Documents/MEP/miRMaster/combine_fastq.sh "${OUT_PATH}/P1_lagging.fastq" "${IN_PATH}/195_lagging_merged.fastq" "${IN_PATH}/197_lagging_merged.fastq"

# P2
## control
/home/lulunots/Documents/MEP/miRMaster/combine_fastq.sh "${OUT_PATH}/P2_control.fastq" "${IN_PATH}/199_control_merged.fastq" "${IN_PATH}/200_control_merged.fastq"
## lagging
/home/lulunots/Documents/MEP/miRMaster/combine_fastq.sh "${OUT_PATH}/P2_lagging.fastq" "${IN_PATH}/199_lagging_merged.fastq" "${IN_PATH}/200_lagging_merged.fastq"