
REF="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
WORKDIR="/home/lulunots/Documents/1_ncRNA/4_datafiles/bowtie2Index"

bowtie2-build $REF "${WORKDIR}/GRCh38_index"
