#!/usr/bin/env python3
import sys

def revcomp(seq):
    """Return the reverse complement of a DNA sequence."""
    complement = str.maketrans("ACGTN", "TGCAN")
    return seq.translate(complement)[::-1]

def parse_header(header):
    """
    Parse a header formatted as:
      @<readname>_BC_UMI <other info>
    Returns the concatenated BC+UMI.
    """
    parts = header[1:].strip().split()
    fields = parts[0].split('_')
    if len(fields) < 3:
        sys.stderr.write(f"Header format unexpected: {header}\n")
        return None
    # fields[1] is the barcode (BC) and fields[2] is the UMI.
    bc = fields[1]
    umi = fields[2]
    return bc + umi

def process_fastq(infile, outfile, min_overlap=5):
    with open(infile, 'r') as fin, open(outfile, 'w') as fout:
        while True:
            header = fin.readline()
            if not header:
                break  # End of file
            seq = fin.readline().rstrip()
            plus = fin.readline()
            qual = fin.readline().rstrip()
            
            # Get the BC+UMI adapter from the header.
            adapter = parse_header(header)
            if adapter is None:
                fout.write(header + seq + plus + qual + "\n")
                continue
            
            # Compute the reverse complement of the adapter.
            adapter_rc = revcomp(adapter)
            trim_len = 0

            # Check for the longest suffix of adapter_rc present in the read's 3' end.
            # We iterate from the full length down to the minimum overlap.
            for i in range(len(adapter_rc), min_overlap - 1, -1):
                if seq.endswith(adapter_rc[-i:]):
                    trim_len = i
                    break

            if trim_len > 0:
                trimmed_seq = seq[:-trim_len]
                trimmed_qual = qual[:-trim_len]
            else:
                trimmed_seq = seq
                trimmed_qual = qual
            
            # Write the (possibly trimmed) record.
            fout.write(header)
            fout.write(trimmed_seq + "\n")
            fout.write(plus)
            fout.write(trimmed_qual + "\n")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.stderr.write("Usage: python trim_umi_bc.py <input_fastq> <output_fastq>\n")
        sys.exit(1)
    input_fastq = sys.argv[1]
    output_fastq = sys.argv[2]
    process_fastq(input_fastq, output_fastq)
