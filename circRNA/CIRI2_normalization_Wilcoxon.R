# =====================================================
# circRNA Single‑Cell DE Pipeline with Output Directory
# Robust handling of .ciri files; skips empty/malformed files
# =====================================================

# --- PACKAGES ----------------------------------------------------------------
suppressPackageStartupMessages({
  library(tidyverse)
  library(purrr)
})

# --- USER INPUT ---------------------------------------------------------------
folders <- tibble(
  path  = c(
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/195_Lagging",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/197_Lagging",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/199_Lagging",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/200_Lagging",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/202_Lagging",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/195_Control",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/197_Control",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/199_Control",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/200_Control",
    "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/Ungrouped/202_Control"
  ),
  group = c(rep("lagging", 5), rep("control", 5))
)

output_dir <- "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/analysis_results"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# --- STEP 1: Collect .ciri file paths ----------------------------------------
all_files <- folders %>%
  mutate(files = map(path, ~ list.files(.x, pattern = "\\.ciri$", full.names = TRUE))) %>%
  select(group, files) %>%
  unnest(files)

# Debug: report how many files found
message(length(all_files$files), " .ciri files found across specified folders.")
if (nrow(all_files) == 0) stop("No .ciri files found in specified folders.")

# Track skipped files
skipped <- tibble(file = character(), reason = character())

# --- Helper: read single .ciri into tibble ----------------------------------
read_ciri <- function(fp) {
  df <- tryCatch(read.delim(fp, header = TRUE, stringsAsFactors = FALSE),
                 error = function(e) NULL)
  if (is.null(df)) {
    skipped <<- add_row(skipped, file = basename(fp), reason = "Read error")
    message(basename(fp), ": read error, skipping.")
    return(NULL)
  }
  message(basename(fp), ": read ", nrow(df), " rows.")
  if (nrow(df) == 0) {
    skipped <<- add_row(skipped, file = basename(fp), reason = "Empty file")
    message(basename(fp), ": empty file, skipping.")
    return(NULL)
  }
  # Detect any column with 'junction_reads'
  jcols <- grep("junction_reads", colnames(df), value = TRUE)
  if (length(jcols) < 1) {
    skipped <<- add_row(skipped, file = basename(fp), reason = "Missing junction_reads column")
    message(basename(fp), ": no junction_reads column, skipping.")
    return(NULL)
  }
  # If multiple, choose the one exactly matching '#junction_reads' if present
  if ("#junction_reads" %in% jcols) {
    jcol <- "#junction_reads"
  } else {
    jcol <- jcols[1]
    message(basename(fp), ": using '", jcol, "' as junction count column.")
  }
  sample <- tools::file_path_sans_ext(basename(fp))
  tib <- df %>% select(circRNA_ID, !!sym(jcol)) %>%
    distinct(circRNA_ID, .keep_all = TRUE) %>%
    rename(!!sample := !!sym(jcol))
  return(tib)
}

# --- STEP 2: Read and merge counts ------------------------------------------: Read and merge counts ------------------------------------------
list_tibs <- map(all_files$files, read_ciri)
list_tibs <- compact(list_tibs)  # remove NULL entries
if (length(list_tibs) == 0) stop("No valid .ciri files with data found.")

count_mat <- reduce(list_tibs, full_join, by = "circRNA_ID") %>%
  replace(is.na(.), 0) %>%
  column_to_rownames("circRNA_ID") %>%
  as.matrix()

# --- STEP 3: Build metadata ------------------------------------------------
meta <- all_files %>%
  mutate(cell = tools::file_path_sans_ext(basename(files))) %>%
  select(cell, group) %>%
  distinct(cell, .keep_all = TRUE) %>%
  column_to_rownames("cell")

# Align count matrix columns to metadata
count_mat <- count_mat[, rownames(meta)]

# --- STEP 4: Seurat-style normalization (CP10K + log1p) ---------------------
libsize <- colSums(count_mat)
cp10k   <- sweep(count_mat, 2, libsize/1e4, "/")
logm    <- log1p(cp10k)

# --- STEP 5: Wilcoxon tests per circRNA -------------------------------------
grp1 <- rownames(meta)[meta$group == "control"]
grp2 <- rownames(meta)[meta$group == "lagging"]
pvals <- apply(logm, 1, function(v) wilcox.test(v[grp1], v[grp2])$p.value)
padj  <- p.adjust(pvals, method = "BH")

# --- STEP 6: Compute averages & logFC ---------------------------------------
avg1 <- rowMeans(logm[, grp1, drop = FALSE])
avg2 <- rowMeans(logm[, grp2, drop = FALSE])
logFC <- avg2 - avg1

results <- tibble(
  circRNA     = rownames(logm),
  avg_control = avg1,
  avg_lagging = avg2,
  logFC       = logFC,
  pvalue      = pvals,
  padj        = padj
)

# --- STEP 7: Save results --------------------------------------------------
write_csv(results, file.path(output_dir, "circRNA_DE_results_all.csv"))
write_csv(filter(results, padj < 0.05), file.path(output_dir, "circRNA_DE_significant.csv"))
if (nrow(skipped) > 0) write_csv(skipped, file.path(output_dir, "skipped_files_summary.csv"))
message("Pipeline complete. Results saved in: ", normalizePath(output_dir))
