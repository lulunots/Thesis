import pandas as pd

# Load the first CSV and get the list of genes
df_genes = pd.read_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/Significant_Limma_EC3samples_laggingvsctrl_fromrawcounts_20250404.csv')
gene_list = df_genes['Gene'].dropna().astype(str).str.strip().tolist()

# Load the second CSV (tab-separated)
df_targets = pd.read_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/miRTarBase_incl_200.csv')

# Filter rows where 'Target' is in gene_list
filtered_df = df_targets[df_targets['Target'].isin(gene_list)]

# Save filtered results to a new CSV file (comma-separated)
filtered_df.to_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/filtered_output_incl_200.csv', index=False)

# Optionally print first few rows to verify
print(filtered_df.head())
