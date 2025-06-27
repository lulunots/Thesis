#!/usr/bin/env Rscript

# ----------------------------
# CONFIGURATION
# ----------------------------
setwd("/media/lulunots/DATA/Analysis/StringTie2_Quant")  # Input working directory
base_dir    <- getwd()
gffcmp_dir  <- "/media/lulunots/DATA/Analysis/GffCompare"
annot_gtf   <- file.path(gffcmp_dir, "merged.annotated.gtf")

output_dir  <- "/media/lulunots/DATA/Analysis/lncRNA_Results"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

out_raw_fpkm <- file.path(output_dir, "lncRNA_FPKM_matrix.csv")
out_log2mat  <- file.path(output_dir, "lncRNA_log2FPKM_matrix.csv")

# ----------------------------
# LIBRARIES
# ----------------------------
suppressPackageStartupMessages({
  library(data.table)
  library(rtracklayer)
  library(dplyr)
  library(tidyr)
  library(stringr)
})

# ----------------------------
# 1. Load GffCompare annotation
# ----------------------------
cat("Loading annotated GTF and filtering lncRNAs à la VASA-seq (Salmen et al)...\n")

# Import the full GTF
gtf <- import(annot_gtf)
gtf_df <- as.data.frame(gtf)

# Filter to get transcript-level metadata
transcripts <- gtf_df %>%
  filter(type == "transcript" & class_code %in% c("u", "x", "i", "k", "m", "n", "j", "y", "="))

# Get exon-level data
exons <- gtf_df %>% filter(type == "exon")

# Merge to get exon count and check for short exons
exons_summary <- exons %>%
  mutate(exon_length = width) %>%
  group_by(transcript_id) %>%
  summarise(
    exon_count = n(),
    min_exon_length = min(exon_length)
  )

# Merge exon summaries with transcripts
transcripts_filtered <- transcripts %>%
  left_join(exons_summary, by = "transcript_id") %>%
  filter(
    exon_count >= 3,
    min_exon_length > 30,
    width >= 200  # transcript length
  )

# Extract final list of lncRNA gene IDs
lnc_genes <- unique(transcripts_filtered$gene_id)

cat("> Found", length(lnc_genes), "lncRNA gene IDs (Salmen-style filtered)\n\n")

# ----------------------------
# 2. Discover cells & metadata
# ----------------------------
cat("Discovering cell folders...\n")
folders <- list.dirs(base_dir, recursive = FALSE, full.names = TRUE)
meta <- tibble(folder = basename(folders)) %>%
  mutate(
    path    = file.path(base_dir, folder),
    group   = str_extract(folder, "control|lagging"),
    cell_id = str_replace(folder, "^other_|_control$|_lagging$", "")
  )
cat("  •", nrow(meta), "cells found.\n\n")

# ----------------------------
# 3. Extract per-cell lncRNA FPKM
# ----------------------------
get_lnc_fpkm <- function(ctab, lnc_ids) {
  dt <- fread(ctab)
  dt <- dt[gene_id %in% lnc_ids, .(FPKM = sum(FPKM)), by=gene_id]
  return(dt)
}

expr_list <- list()
for(i in seq_len(nrow(meta))) {
  cid  <- meta$cell_id[i]
  ct   <- file.path(meta$path[i], "t_data.ctab")
  if(!file.exists(ct)) {
    warning("Missing t_data.ctab for ", cid); next
  }
  dt <- get_lnc_fpkm(ct, lnc_genes)
  dt[, cell_id := cid]
  expr_list[[cid]] <- dt
  cat(sprintf("  • %s: %d genes\n", cid, nrow(dt)))
}
cat("\n")

# ----------------------------
# 4. Build raw FPKM matrix
# ----------------------------
cat("Building raw FPKM matrix...\n")
expr_df <- bind_rows(expr_list) %>%
  pivot_wider(names_from = cell_id, values_from = FPKM, values_fill = 0) %>%
  arrange(gene_id)

write.csv(expr_df, out_raw_fpkm, row.names = FALSE)
cat("> Raw FPKM matrix saved to", out_raw_fpkm, "\n\n")

# ----------------------------
# 5. Log2(FPKM + 1) normalization
# ----------------------------
cat("Applying log2(FPKM + 1) transform...\n")
log2_df <- expr_df
log2_df[,-1] <- log2(log2_df[,-1] + 1)

write.csv(log2_df, out_log2mat, row.names = FALSE)
cat("> Log2-normalized matrix saved to", out_log2mat, "\n\n")

cat("Done.\n")
