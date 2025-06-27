import pandas as pd

# === INPUT ===

# Path to the interactions CSV
input_csv = "/run/user/1001/gvfs/smb-share:server=smb01.isi01-rx.erasmusmc.nl,share=chien_data/Lab/Data_and_Analysis/Lulu_Notschaele/1_ncRNA/5_Results/miRNA_mRNA_interactions.csv"

# Path to the miRNA list
mirna_list_file = "/run/user/1001/gvfs/smb-share:server=smb01.isi01-rx.erasmusmc.nl,share=chien_data/Lab/Data_and_Analysis/Lulu_Notschaele/1_ncRNA/5_Results/mirna_list.txt"

# === LOAD DATA ===

# Read the interactions table
df = pd.read_csv(input_csv, sep=",")  # or sep="," if comma-separated
# Fix broken characters like '+AC0-' to '-'
df['miRNA'] = df['miRNA'].str.replace(r'\+AC0-', '-', regex=True)

print(df.columns.tolist())
print("Unique miRNAs in the CSV:")
print(df['miRNA'].unique()[:10])  # Print first 10 for sanity check

# Read the miRNA list
with open(mirna_list_file) as f:
    mirnas_of_interest = [line.strip() for line in f if line.strip()]
print("miRNAs of interest:")
print(mirnas_of_interest)
# Clean column names
df.columns = df.columns.str.strip()

# Filter to just those miRNAs
df['miRNA'] = df['miRNA'].astype(str).str.strip().str.lower()
mirnas_of_interest = [m.strip().lower() for m in mirnas_of_interest]
filtered = df[df['miRNA'].isin(mirnas_of_interest)]

# Group by miRNA and collect targets
grouped = filtered.groupby('miRNA')['Target'].apply(lambda x: ', '.join(sorted(set(x)))).reset_index()

print(f"Number of matching rows: {len(filtered)}")
print(filtered.head())

# Save result
output_csv = "/run/user/1001/gvfs/smb-share:server=smb01.isi01-rx.erasmusmc.nl,share=chien_data/Lab/Data_and_Analysis/Lulu_Notschaele/1_ncRNA/5_Results/filtered_miRNA_targets.csv"
grouped.to_csv(output_csv, index=False)

print(f"Filtered results saved to: {output_csv}")
