#!/usr/bin/env Rscript

# ----------------------------
# Load required packages
# ----------------------------
suppressPackageStartupMessages({
  library(rtracklayer)
  library(GenomicFeatures)
  library(dplyr)
})

# ----------------------------
# Set paths
# ----------------------------
gtf_file     <- "/media/lulunots/DATA/Analysis/GffCompare/merged.annotated.gtf"  
output_gtf   <- "/media/lulunots/DATA/Analysis/lncRNA_rerun/filtered_lncRNAs.gtf"  

# ----------------------------
# Import GTF
# ----------------------------
cat("Importing GTF...\n")
gtf <- import(gtf_file)

# Remove entries with missing or invalid strand (keep only '+' or '-')
gtf <- gtf[strand(gtf) %in% c("+", "-")]

# ----------------------------
# Filter: keep transcripts only
# ----------------------------
cat("Filtering transcript features...\n")
transcripts <- gtf[gtf$type == "transcript"]

# ----------------------------
# Class code filter
# ----------------------------
# Common lncRNA class codes from gffcompare:
#   u: unknown intergenic
#   x: exonic overlap with known on opposite strand
#   i: fully contained in intron of reference
#   o: other same strand overlap
keep_class_codes <- c("u", "x", "i", "o")

transcripts <- transcripts[mcols(transcripts)$class_code %in% keep_class_codes]

# ----------------------------
# Length filter
# ----------------------------
# Remove transcripts < 200 nt
transcripts <- transcripts[width(transcripts) >= 200]

# ----------------------------
# Build TxDb and get exon info
# ----------------------------
cat("Calculating exon counts and lengths...\n")
txdb <- makeTxDbFromGRanges(gtf)
exons_by_tx <- exonsBy(txdb, by = "tx", use.names = TRUE)

# Filter only retained transcripts
tx_ids <- mcols(transcripts)$transcript_id
exons_by_tx <- exons_by_tx[names(exons_by_tx) %in% tx_ids]

# Get exon count
exon_counts <- sapply(exons_by_tx, length)

# Get minimum exon length
min_exon_lengths <- sapply(exons_by_tx, function(e) min(width(e)))

# Create data.frame to join
filter_df <- data.frame(
  transcript_id = names(exons_by_tx),
  exon_count = exon_counts,
  min_exon_length = min_exon_lengths,
  stringsAsFactors = FALSE
)

# Join with transcripts
transcripts_df <- as.data.frame(mcols(transcripts))
transcripts_df$width <- width(transcripts)
transcripts_df$tx_id <- transcripts_df$transcript_id

merged <- inner_join(transcripts_df, filter_df, by = "transcript_id")

# Apply exon-based filters
filtered_tx_ids <- merged %>%
  filter(exon_count >= 2, min_exon_length >= 30) %>%
  pull(transcript_id)

# Final filtered GTF
filtered_gtf <- gtf[mcols(gtf)$transcript_id %in% filtered_tx_ids]

# ----------------------------
# Export filtered GTF
# ----------------------------
cat("Writing filtered GTF to:\n", output_gtf, "\n")
export(filtered_gtf, output_gtf, format = "gtf")
