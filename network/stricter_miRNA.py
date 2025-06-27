import pandas as pd

# Load the TSV file
input_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/combined_miRNA_lncRNA_by_gene.tsv"
output_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/filtered_combined_miRNA_lncRNA_by_gene.tsv"

# Read the file
df = pd.read_csv(input_file, sep="\t")

# Apply the filter:
# Keep rows where:
# - 'miRNA' contains 'hsa-miR-8485' OR
# - 'lncRNA' is not null/empty
filtered_df = df[
    df['miRNA'].str.contains('hsa-miR-8485', na=False) |
    df['lncRNA'].notna() & df['lncRNA'].str.strip().ne('')
]

# Save the filtered data to a new TSV file
filtered_df.to_csv(output_file, sep="\t", index=False)

print(f"Filtered data saved to {output_file}")
