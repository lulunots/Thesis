import pandas as pd

# Read CSV
df = pd.read_csv("/home/lulunots/Documents/filtered_lncRNA_gene_pairs.csv", sep=",") 

# Group and concatenate pairGeneName values
print(df.columns.tolist())
grouped = df.groupby('geneID')['pairGeneName'].apply(lambda x: ', '.join(x)).reset_index()

# Save to new CSV
grouped.to_csv("/home/lulunots/Documents/grouped_genes.csv", index=False)
