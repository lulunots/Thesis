CB_whitelist='/home/lulunots/Documents/1_ncRNA/4_datafiles/SORTseq_cellbarcodes.txt'
script_loc='Demultiplexing'

for platenr in 195 197 199 200
do
    input="/home/lulunots/Documents/1_ncRNA/3_fastq/RiboDepletion/${platenr}/out/other.fq"
    output="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/${platenr}"
    mkdir -p "${output}"

    echo "Demultiplexing $platenr"
    python "${script_loc}/demultiplex.py" "${input}" "${CB_whitelist}" --outdir "${output}"
    echo "Finished demultiplexing $platenr"
done
