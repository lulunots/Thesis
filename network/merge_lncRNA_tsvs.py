import os
import glob
import pandas as pd

# Directory containing your TSV files
input_dir = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNAtsvs"  # change this to your folder path

# Output file
output_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNAtsvs/combined_miRNA_interactions.tsv"

# Collect results here
all_data = []

# Find all .tsv files in the directory
tsv_files = glob.glob(os.path.join(input_dir, "*.tsv"))

for filepath in tsv_files:
    # Extract ENSEMBL gene ID from filename (assuming filename is ENSG...tsv)
    ensembl_id = os.path.basename(filepath).replace(".tsv", "")
    
    # Load TSV
    df = pd.read_csv(filepath, sep="\t", dtype=str)
    
    # Filter only PartnerType == 'miRNA'
    df_miRNA = df[df['PartnerType'] == 'miRNA']
    
    # If there are no miRNA rows, skip
    if df_miRNA.empty:
        continue
    
    # For each row, collect gene id, partner name, description
    for _, row in df_miRNA.iterrows():
        all_data.append({
            'Ensembl_Gene_ID': ensembl_id,
            'PartnerName': row['PartnerName'],
            'Description': row['Description']
        })

# Convert to DataFrame
result_df = pd.DataFrame(all_data)

# Save combined output
result_df.to_csv(output_file, sep="\t", index=False)

print(f"Combined miRNA interactions saved to: {output_file}")
