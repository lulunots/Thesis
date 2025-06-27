# ==========================
# Script 1: Data Preparation
# - Collect .ciri file paths
# - Build count matrix
# - Generate metadata
# ==========================

suppressPackageStartupMessages({
  library(tidyverse)
})

# --- User input: folders and groups -----------------------------------------
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
  group = c(rep("lagging",5), rep("control",5))
)

# Output directory for intermediate files
output_dir <- "/home/lulunots/Documents/1_ncRNA/6_analysis/CIRI2/analysis_results"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Helper to read a .ciri file and return tibble of counts
read_ciri <- function(fp) {
  df <- tryCatch(read.delim(fp, header=TRUE, stringsAsFactors=FALSE), error = function(e) NULL)
  if (is.null(df) || nrow(df)==0) return(NULL)
  jcol <- if("#junction_reads" %in% names(df)) "#junction_reads" else grep("junction_reads", names(df), value=TRUE)[1]
  df %>% select(circRNA_ID, !!sym(jcol)) %>% distinct(circRNA_ID, .keep_all=TRUE) %>%
    rename(count = !!sym(jcol)) %>% mutate(sample = tools::file_path_sans_ext(basename(fp)))
}

# Collect files
all_files <- folders %>% mutate(files=map(path, ~list.files(.x, pattern="\\.ciri$", full.names=TRUE))) %>%
  select(group, files) %>% unnest(files)

# Read and build count matrix
counts_tbl <- map_dfr(all_files$files, read_ciri)
count_matrix <- counts_tbl %>% pivot_wider(names_from=sample, values_from=count, values_fill=0) %>%
  column_to_rownames("circRNA_ID") %>% as.matrix()
write.csv(count_matrix, file.path(output_dir, "count_matrix.csv"))

# Build metadata
metadata <- all_files %>% mutate(cell=tools::file_path_sans_ext(basename(files))) %>%
  select(cell, group) %>% distinct(cell, .keep_all=TRUE)
write.csv(metadata, file.path(output_dir, "metadata.csv"), row.names=FALSE)

message("Script 1 complete: count_matrix.csv and metadata.csv created.")
