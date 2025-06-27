#!/usr/bin/env Rscript

# ----------------------------
# CONFIGURATION
# ----------------------------
base_dir      <- "/media/lulunots/DATA/Analysis/StringTie2_Quant"
gffcmp_dir    <- "/media/lulunots/DATA/Analysis/GffCompare"
annot_gtf     <- file.path(gffcmp_dir, "merged.annotated.gtf")
out_raw_fpkm  <- "lncRNA_FPKM_matrix.csv"
out_log2mat   <- "lncRNA_log2FPKM_matrix.csv"
out_wilcox    <- "lncRNA_wilcox_results.csv"

# ----------------------------
# LIBRARIES
# ----------------------------
suppressPackageStartupMessages({
  library(data.table)
  library(rtracklayer)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(stats)
})

# ----------------------------
# 1. Load GffCompare annotation
# ----------------------------
cat("Loading annotated GTF...\n")
gtf <- import(annot_gtf)
df_gtf <- as.data.frame(gtf) %>% filter(type == "transcript")
keep_codes <- c("u","x","i","=")
lnc_genes  <- unique(df_gtf$gene_id[df_gtf$class_code %in% keep_codes])
cat("> Found", length(lnc_genes), "candidate lncRNA gene IDs\n\n")

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
cat("  •", nrow(meta), "cells found.\n")
print(head(meta,2)); cat("\n")

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
  grp  <- meta$group[i]
  ct   <- file.path(meta$path[i], "t_data.ctab")
  if(!file.exists(ct)) {
    warning("Missing t_data.ctab for ", cid); next
  }
  dt <- get_lnc_fpkm(ct, lnc_genes)
  dt[, cell_id := cid]
  expr_list[[cid]] <- dt
  cat(sprintf("  • %s (%s): %d genes\n", cid, grp, nrow(dt)))
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
# 5. Log2(FPKM+1) normalization
# ----------------------------
cat("Applying log2(FPKM + 1) transform...\n")
log2_df <- expr_df
log2_df[,-1] <- log2(log2_df[,-1] + 1)

write.csv(log2_df, out_log2mat, row.names = FALSE)
cat("> Log2‐normalized matrix saved to", out_log2mat, "\n\n")

# ----------------------------
# 6. Wilcoxon test (optional)
# ----------------------------
lag   <- meta %>% filter(group=="lagging")  %>% pull(cell_id)
ctrl  <- meta %>% filter(group=="control")  %>% pull(cell_id)
common <- intersect(c(lag,ctrl), colnames(log2_df)[-1])

if(length(intersect(lag,common))>1 && length(intersect(ctrl,common))>1) {
  cat("Running Wilcoxon tests...\n")
  res <- lapply(log2_df$gene_id, function(g) {
    x <- as.numeric(log2_df[log2_df$gene_id==g, lag     , drop=TRUE])
    y <- as.numeric(log2_df[log2_df$gene_id==g, ctrl    , drop=TRUE])
    t <- wilcox.test(x,y, exact=FALSE)
    c(gene_id=g, stat=t$statistic, pval=t$p.value)
  }) %>% 
    do.call(rbind, .) %>%
    as.data.frame(stringsAsFactors=FALSE) %>%
    mutate(stat=as.numeric(stat), pval=as.numeric(pval)) %>%
    arrange(pval) %>%
    mutate(rank=row_number(),
           adj_pval=pmin(1, pval * n() / rank)) %>%
    select(gene_id, stat, pval, adj_pval)
  
  write.csv(res, out_wilcox, row.names=FALSE)
  cat("> Wilcoxon results saved to", out_wilcox, "\n")
} else {
  cat("Not enough cells in one or both groups—skipping Wilcoxon.\n")
}

cat("Done.\n")
