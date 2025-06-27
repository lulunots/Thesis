import pandas as pd

# Input and output files
input_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNAtsvs/combined_miRNA_interactions.tsv"  # replace with your filename
output_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/Network/lncRNAtsvs/filtered_miRNA_interactions.tsv"

# List of miRNAs to keep
miRNA_list = {
    "hsa-miR-8485", "hsa-miR-3613-5p", "hsa-miR-5100", "hsa-miR-7977",
    "hsa-miR-3196", "hsa-miR-574-5p", "hsa-miR-4454", "hsa-miR-10400-5p",
    "hsa-miR-1260b", "hsa-miR-10401-3p", "hsa-miR-1973", "hsa-miR-1260a",
    "hsa-miR-200c-5p", "hsa-miR-200c-3p", "hsa-miR-200b-3p", "hsa-miR-200b-5p"
}

# Read the TSV file
df = pd.read_csv(input_file, sep="\t", dtype=str)

# Filter rows where PartnerName is in miRNA_list
filtered_df = df[df['PartnerName'].isin(miRNA_list)]

# Save filtered results
filtered_df.to_csv(output_file, sep="\t", index=False)

print(f"Filtered data saved to {output_file}")
