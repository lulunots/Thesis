import pandas as pd

# Paths to your input files
genes_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/Significant_Limma_EC3samples_laggingvsctrl_fromrawcounts_20250404.csv"         # the file with one column: Gene
pairs_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNA_mRNA.tsv"  # the second file with geneID and pairGeneName

# Output file path
output_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/filtered_lncRNA_gene_pairs.csv"

# Load the list of genes
genes_df = pd.read_csv(genes_file)
genes_set = set(genes_df['Gene'].str.strip())  # Make a set for faster lookup

# Load the pairs file (TSV)
pairs_df = pd.read_csv(pairs_file, sep='\t')

# Filter rows where 'pairGeneName' is in the genes list
filtered_df = pairs_df[pairs_df['pairGeneName'].isin(genes_set)]

# Save the filtered data to CSV
filtered_df.to_csv(output_file, index=False)

print(f"Filtered pairs saved to {output_file}, total rows: {len(filtered_df)}")
