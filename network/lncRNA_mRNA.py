import pandas as pd
import os
from glob import glob

input_dir = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNAxls"
output_file = os.path.join(input_dir, "lncRNA_mRNA.tsv")

xls_files = glob(os.path.join(input_dir, "*.csv"))

all_rows = []

for file in xls_files:
    print(f"Processing file: {file}")
    df = pd.read_csv(file, skiprows=3, sep='\t', dtype=str)
    df.columns = df.columns.str.strip()
    print("Columns found:", df.columns.tolist())

    if 'pairGeneType' not in df.columns:
        print(f"Skipping {file} as 'pairGeneType' not found.")
        continue
    
    print("Unique pairGeneType values:", df['pairGeneType'].unique())
    filtered = df[df['pairGeneType'].str.contains('protein', case=False, na=False)][['geneID', 'pairGeneName']]
    all_rows.append(filtered)

if all_rows:
    result_df = pd.concat(all_rows, ignore_index=True)
    result_df.drop_duplicates(inplace=True)
    result_df.to_csv(output_file, sep='\t', index=False)
    print(f"Saved {len(result_df)} unique entries to '{output_file}'")
else:
    print("No protein partner entries found.")
