import pandas as pd # type: ignore

# Load the Excel file
file_path = "/home/lulunots/Documents/1_ncRNA/6_analysis/MiRMaster/expression_known_mirnas.xlsx"
xls = pd.ExcelFile(file_path)

# Read both sheets into DataFrames
sheet1 = xls.parse(sheet_name=xls.sheet_names[0])
sheet2 = xls.parse(sheet_name=xls.sheet_names[1])

# Standardize column names (strip spaces)
sheet1.columns = sheet1.columns.str.strip()
sheet2.columns = sheet2.columns.str.strip()

# Check if 'precursor' and 'miRNA' columns exist in both sheets
required_columns = {'precursor', 'miRNA'}
if not required_columns.issubset(sheet1.columns) or not required_columns.issubset(sheet2.columns):
    raise KeyError("Columns 'precursor' and 'miRNA' not found in one or both sheets. Check column names.")

# Merge data on 'precursor' and 'miRNA' columns using outer join to include all entries
merged_df = pd.merge(sheet1, sheet2, on=['precursor', 'miRNA'], how='outer', suffixes=('_sheet1', '_sheet2'))

# Fill NaN values with 0 (optional, depends on the use case)
merged_df.fillna(0, inplace=True)

# Save merged data to a new Excel file
output_file = "/home/lulunots/Documents/1_ncRNA/6_analysis/MiRMaster/merged_expression_known_mirnas.xlsx"
merged_df.to_excel(output_file, index=False)

print(f"Merged file saved as: {output_file}")