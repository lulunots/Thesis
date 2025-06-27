import pandas as pd
import re
import argparse


def parse_gtf(gtf_path):
    """
    Parse GTF/GFF2 file and extract transcript ranges per gene_id.
    Returns a dict mapping gene_id -> (chrom, min_start, max_end)
    """
    gene_coords = {}
    attr_pattern = re.compile(r'gene_id "([^"]+)"')

    with open(gtf_path, 'r') as f:
        for line in f:
            if line.startswith('#'):
                continue
            parts = line.strip().split('\t')
            if len(parts) < 9:
                continue

            chrom, source, feature, start, end, score, strand, phase, attrs = parts

            # Skip if any of the coordinate fields are missing
            if not chrom or not start or not end:
                continue

            if feature.lower() != 'transcript':
                continue

            m = attr_pattern.search(attrs)
            if not m:
                continue
            gene_id = m.group(1)
            try:
                start, end = int(start), int(end)
            except ValueError:
                continue  # Skip entries where start/end are not integers

            if gene_id not in gene_coords:
                gene_coords[gene_id] = (chrom, start, end)
            else:
                c, s, e = gene_coords[gene_id]
                s = min(s, start)
                e = max(e, end)
                gene_coords[gene_id] = (c, s, e)
    return gene_coords


def format_coord(chrom, start, end):
    """
    Format chromosome and positions as requested.
    Numeric chromosomes: chrN; others (X, Y, MT) as-is.
    """
    chrom = chrom.replace('M', 'MT') if chrom == 'M' else chrom
    if chrom.isdigit():
        prefix = f"chr{chrom}"
    elif chrom in ['X', 'Y', 'MT']:
        prefix = chrom
    else:
        prefix = chrom
    return f"{prefix}:{start}|{end}"


def main(gtf_file, csv_file, output_file):
    # Read CSV
    df = pd.read_csv(csv_file, sep=',')
    # Filter for MSTRG gene_ids
    df_mstrg = df[df['gene_id'].str.startswith('MSTRG')].copy()

    # Parse GTF for coordinates
    gene_coords = parse_gtf(gtf_file)

    # Build rows
    records = []
    for _, row in df_mstrg.iterrows():
        gid = row['gene_id']
        if gid in gene_coords:
            chrom, start, end = gene_coords[gid]
            coord_str = format_coord(chrom, start, end)
        else:
            coord_str = ''
        records.append({
            'gene_id': gid,
            'coord': coord_str,
            'pvalue': row['pvalue'],
            'adj_pvalue': row['adj_pvalue'],
            'fc': row['fc']
        })

    result = pd.DataFrame.from_records(records)
    result.to_csv(output_file, index=False)
    print(f"Merged data written to {output_file}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Merge CSV and GTF to extract coordinates and stats')
    parser.add_argument('--gtf', required=True, help='Input GTF/GFF file path')
    parser.add_argument('--csv', required=True, help='Input CSV stats file path')
    parser.add_argument('--out', required=True, help='Output CSV file path')
    args = parser.parse_args()
    main(args.gtf, args.csv, args.out)
