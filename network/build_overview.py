import pandas as pd

# Load the first file (miRNA associations)
file1 = pd.read_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/filtered_output_incl_200.csv')

# Load the second file (lncRNA associations)
file2 = pd.read_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/filtered_lncRNA_gene_pairs.csv')

# Extract relevant columns for ease of use
miRNA_df = file1[['miRNA', 'Target']].copy()
lncRNA_df = file2[['geneID', 'pairGeneName']].copy()

# Get unique gene names from both files
genes_file1 = set(miRNA_df['Target'].unique())
genes_file2 = set(lncRNA_df['pairGeneName'].unique())

all_genes = sorted(genes_file1.union(genes_file2))

# Create output dataframe
output_df = pd.DataFrame({'GeneName': all_genes})

# Map gene -> associated miRNAs (comma separated if multiple)
miRNA_map = miRNA_df.groupby('Target')['miRNA'].apply(lambda x: ','.join(sorted(set(x)))).to_dict()
output_df['miRNA'] = output_df['GeneName'].map(miRNA_map).fillna('')

# Map gene -> associated lncRNAs (geneIDs) (comma separated if multiple)
lncRNA_map = lncRNA_df.groupby('pairGeneName')['geneID'].apply(lambda x: ','.join(sorted(set(x)))).to_dict()
output_df['lncRNA'] = output_df['GeneName'].map(lncRNA_map).fillna('')

# Save the combined output
output_df.to_csv('/home/lulunots/Documents/1_ncRNA/6_analysis/Network/combined_miRNA_lncRNA_by_gene.tsv', sep='\t', index=False)
