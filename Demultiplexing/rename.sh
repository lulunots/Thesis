for platenr in 195 197 199 200
do
    file_loc_ctrl="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/Control"
    file_loc_lag="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}/Lagging"

    for file in "${file_loc_ctrl}"/*.fastq; do
        mv "$file" "${file%.fastq}_${platenr}.fastq"
    done

    for file in "${file_loc_lag}"/*.fastq; do
        mv "$file" "${file%.fastq}_${platenr}.fastq"
    done
done