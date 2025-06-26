for platenr in 195 197 199 200
do
    in_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/UMI-tools_extract_${platenr}"
    out_loc="/home/lulunots/Documents/1_ncRNA/3_fastq/VASAtrim"
    mkdir -p "${out_loc}"  # Ensure the directory exists

    for r2 in "${in_loc}"/processed_${platenr}_R2.fastq
    do
        echo "Running cutadapt on R2 file: $r2"

        file2trim=${r2}
        outdir=${out_loc}

        # Trim adapters with Trim Galore (no compression)
        echo "Running Trim Galore on ${file2trim}"
        trim_galore --path_to_cutadapt /home/lulunots/anaconda3/bin/cutadapt --dont_gzip "${file2trim}" -o "${outdir}"

        # Ensure Trim Galore produces the expected output files
        trimmed_file="${outdir}/$(basename ${file2trim} .fastq)_trimmed.fastq"
        trimming_report="${outdir}/$(basename ${file2trim} .fastq)_trimmed_trimming_report.txt"
        
        # Check if the trimmed file exists
        if [[ ! -f "$trimmed_file" ]]; then
            echo "Trim Galore failed to produce the expected trimmed file: ${trimmed_file}"
            continue
        fi
        
        # Correctly rename the trimming report
        mv "$trimming_report" "${outdir}/$(basename ${file2trim} .fastq)_trimming_report.txt"
        echo "Trim Galore finished successfully for ${file2trim}."

        # Trim homopolymers (polyA, polyT, polyG, polyC)
        echo "Running cutadapt for homopolymers on ${trimmed_file}"
        cutadapt -m 15 --trim-n \
          -a "polyG1=GG{5}" -a "polyC1=CC{5}" -a "polyT1=TT{5}" -a "polyA1=AA{5}" \
          -o "${outdir}/$(basename ${file2trim} .fastq)_trimmed_homoATCG.fastq" \
          "$trimmed_file"

        echo "Finished trimming homopolymers for ${file2trim}"
    done
done
