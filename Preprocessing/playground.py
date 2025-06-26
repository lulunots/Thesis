import sys

def revcomp(seq):
    """Return the reverse complement of a DNA sequence."""
    complement = str.maketrans("ACGTN", "TGCAN")
    return seq.translate(complement)[::-1]

def process_fastq(infile, outfile):
    with open(infile, 'r') as fin, open(outfile, 'w') as fout:
        while True:
            header = fin.readline()
            if not header:
                break  # End of file
            seq = fin.readline().rstrip()
            plus = fin.readline()
            qual = fin.readline().rstrip()

            # # Extract UMI+BC from header and get its reverse complement.
            # adapter = parse_header(header)
            # if adapter is None:
            #     # If we cannot parse the header, write the record unchanged.
            #     fout.write(header + seq + plus + qual + "\n")
            #     continue



process_fastq('trial.fastq', 'outtrial.fastq')

print(revcomp("ACGTGGGTTAAC"))