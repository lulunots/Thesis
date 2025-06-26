
REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
WORKDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/bwaIndex"

mkdir -p "${WORKDIR}" 
cd "${WORKDIR}"

bwa index -a bwtsw -p "$(basename "${REF_FASTA}")" "${REF_FASTA}"
