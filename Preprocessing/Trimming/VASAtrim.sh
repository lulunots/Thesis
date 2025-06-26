#!/bin/bash

if [ $# -ne 4 ]; then
    echo "Usage: $0 <input_fastq> <output_directory> <path_to_trimgalore> <path_to_cutadapt>"
    exit 1
fi

file2trim=$1
outdir=$2
path2trimgalore=$3
path2cutadapt=$4

# Trim adapters with Trim Galore (no compression)
${path2trimgalore}/trim_galore --path_to_cutadapt ${path2cutadapt}/cutadapt --dont_gzip "${file2trim}" -o "${outdir}"

# Rename trimming report for consistency
mv "${outdir}/$(basename ${file2trim})_trimming_report.txt" "${outdir}/$(basename ${file2trim} .fastq)_trimming_report.txt"

# Trim homopolymers (polyA, polyT, polyG, polyC)
${path2cutadapt}/cutadapt -m 15 --trim-n \
  -a "polyG1=GG{5}" -a "polyC1=CC{5}" -a "polyT1=TT{5}" -a "polyA1=AA{5}" \
  -o "${outdir}/$(basename ${file2trim} .fastq)_trimmed_homoATCG.fastq" \
  "${outdir}/$(basename ${file2trim} .fastq)_trimmed.fastq"

exit 0
