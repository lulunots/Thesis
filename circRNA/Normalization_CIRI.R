# ==========================
# Script 2: Normalization
# - Load count matrix and metadata
# - Normalize counts to CP10K + log1p
# ==========================

# Load data
count_matrix <- read.csv(file.path(output_dir, "count_matrix.csv"), row.names=1, check.names=FALSE)
metadata     <- read.csv(file.path(output_dir, "metadata.csv"), row.names=1)

# Seurat‐style normalization
libsize <- colSums(count_matrix)
cp10k   <- sweep(count_matrix, 2, libsize/1e4, "/")
log_norm <- log1p(cp10k)

# Save normalized matrix
write.csv(log_norm, file.path(output_dir, "normalized_matrix.csv"))
message("Script 2 complete: normalized_matrix.csv created.")