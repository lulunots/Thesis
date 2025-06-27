import pandas as pd

# Load your CSV file
df = pd.read_csv('/home/lulunots/Downloads/Limma_EC3samples_laggingvsctrl_fromrawcounts_20250404.csv')  # replace with your actual filename

# Select the column and clean it
words = df['Gene'].dropna().astype(str).str.strip()

# Join without spaces
word_list = ','.join(words)

print(word_list)
