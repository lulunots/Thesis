CB_whitelist='/home/lulunots/Documents/1_ncRNA/4_datafiles/SORTseq_cellbarcodes.txt'
script_loc='Plate3'

input="/home/lulunots/Documents/1_ncRNA/3_fastq/RiboDepletion/out/other.fq"
output="/home/lulunots/Documents/1_ncRNA/3_fastq/Demultiplexed/plate_202"
mkdir -p "${output}"

echo "Demultiplexing 202"
python "${script_loc}/Demux.py" "${input}" "${CB_whitelist}" --outdir "${output}"
echo "Finished demultiplexing 202"
