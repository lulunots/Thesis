REF_FASTA="/home/lulunots/Documents/1_ncRNA/4_datafiles/STAR_References/Homo_sapiens.GRCh38.dna.primary_assembly.fa"
GTF_FILE="/home/lulunots/Documents/1_ncRNA/4_datafiles/Annotations/Homo_sapiens.GRCh38.109.gtf"
CIRIQUANT="CIRIquant"
CONFIG="/home/lulunots/Documents/1_ncRNA/configs/CIRIquant_config.yml"

# quant results go here:
WORKDIR_QUANT="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRIQuant/Ungrouped"
# **actual** CIRI2 outputs live here:
WORKDIR_CIRI2="/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped"

THREADS=6

for platenr in 195 197 199 200 202; do
  for GROUP in Lagging Control; do
    READ_DIR="/home/lulunots/Documents/1_ncRNA/7_alignment/bwa/Ungrouped/${platenr}_${GROUP}"
    OUT_QUANT="${WORKDIR_QUANT}/${platenr}_${GROUP}"
    mkdir -p "${OUT_QUANT}"

    # look for .ciri under CIRI2/Ungrouped
    CIRI2_DIR="${WORKDIR_CIRI2}/${platenr}_${GROUP}"
    if ! compgen -G "${CIRI2_DIR}/*.ciri" > /dev/null; then
      echo "No CIRI2 outputs found in ${CIRI2_DIR} – skipping"
      continue
    fi

    for CIRI_OUT in "${CIRI2_DIR}"/*.ciri; do
      BASENAME=$(basename "${CIRI_OUT}" .ciri)
      echo "$(date): quantifying ${BASENAME}"

      "${CIRIQUANT}" \
        --config "${CONFIG}" \
        -1 "${READ_DIR}/${BASENAME}_1.fastq" \
        -2 "${READ_DIR}/${BASENAME}_2.fastq" \
        --circ "${CIRI_OUT}" \
        --tool CIRI2 \
        -t "${THREADS}" \
        -o "${OUT_QUANT}" \
        -p "${BASENAME}" \
        --bed "${REF_FASTA}" \
        --a "${GTF_FILE}"

      echo "$(date): done ${BASENAME}"
    done
  done
done
