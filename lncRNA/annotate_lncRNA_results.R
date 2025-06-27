#!/usr/bin/env Rscript

# ----------------------------
# CONFIGURATION
# ----------------------------
suppressPackageStartupMessages({
  library(data.table)
  library(dplyr)
  library(biomaRt)
})

# Set paths
results_file   <- "/media/lulunots/DATA/Analysis/lncRNA_Results/lncRNA_wilcox_results_with_avgs.csv"
tracking_file  <- "/media/lulunots/DATA/Analysis/GffCompare/merged.tracking"
output_file    <- "/media/lulunots/DATA/Analysis/lncRNA_Results/lncRNA_results_annotated.csv"

# ----------------------------
# LOAD RESULTS
# ----------------------------
cat("Reading Wilcoxon results...\n")
res <- fread(results_file) %>% as_tibble()
gene_ids <- unique(res$gene_id)

# ----------------------------
# SPLIT GENE IDS
# ----------------------------
known_ids <- gene_ids[grepl("^ENSG", gene_ids)]
novel_ids <- gene_ids[grepl("^MSTRG", gene_ids)]

cat("  • Found", length(known_ids), "known gene IDs\n")
cat("  • Found", length(novel_ids), "novel gene IDs\n\n")

# ----------------------------
# ANNOTATE KNOWN GENES VIA BIOMART
# ----------------------------
cat("Querying Ensembl for known gene annotation...\n")
ensembl <- useEnsembl(biomart = "genes", dataset = "hsapiens_gene_ensembl")

annot_known <- getBM(
  attributes = c("ensembl_gene_id", "external_gene_name", "gene_biotype", "description"),
  filters    = "ensembl_gene_id",
  values     = known_ids,
  mart       = ensembl
) %>%
  rename(
    gene_id   = ensembl_gene_id,
    gene_name = external_gene_name,
    gene_type = gene_biotype,
    gene_desc = description
  ) %>%
  # ensure all columns are character
  mutate(across(everything(), as.character))

# ----------------------------
# ANNOTATE NOVEL MSTRG GENES USING merged.tracking (data.table)
# ----------------------------
cat("Annotating novel MSTRG transcripts using merged.tracking...\n")
tracking <- fread(tracking_file, header = FALSE, fill = TRUE)

annot_novel_dt <- tracking[V1 %in% novel_ids, .(
  gene_id        = V1,
  ref_gene       = V2,
  ref_transcript = V3
)]

annot_novel_dt[, `:=`(
  gene_name = ifelse(ref_gene != ".", ref_gene, NA_character_),
  gene_type = ifelse(ref_gene != ".", "potential_match", "novel_lncRNA"),
  gene_desc = ifelse(ref_gene != ".",
                     paste("Possible match to", ref_gene),
                     "No known match")
)]

annot_novel <- annot_novel_dt[, .(gene_id, gene_name, gene_type, gene_desc)] %>%
  as.data.table() %>%
  # ensure same column types
  mutate(across(everything(), as.character)) %>%
  as.data.frame()

# ----------------------------
# MERGE ANNOTATIONS
# ----------------------------
cat("Merging annotations with Wilcoxon results...\n")
full_annot <- bind_rows(annot_known, annot_novel)

res_annot <- res %>%
  dplyr::left_join(full_annot, by = "gene_id") %>%
  # drop protein_coding but keep novel or NA
  dplyr::filter(dplyr::coalesce(gene_type != "protein_coding", TRUE)) %>%
  # now select columns
  dplyr::select(gene_id, gene_name, gene_type, gene_desc, dplyr::everything())

# ----------------------------
# SAVE OUTPUT
# ----------------------------
fwrite(res_annot, output_file)
cat("Annotated results saved to:\n", output_file, "\n")
