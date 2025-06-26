#!/usr/bin/env python3
import argparse
import os

def parse_fastq(file_path):
    """
    Generator to read a fastq file record by record.
    Each record consists of four lines:
      1. Header line (starting with '@')
      2. Sequence line
      3. Plus line ('+')
      4. Quality line
    """
    with open(file_path, "r") as f:
        while True:
            header = f.readline().rstrip()
            if not header:
                break  # End of file
            seq = f.readline().rstrip()
            plus = f.readline().rstrip()
            qual = f.readline().rstrip()
            yield (header, seq, plus, qual)

def extract_read_id(header):
    """
    Extract the read ID from a FASTQ header.
    This function:
      - Removes the initial '@'
      - Splits by whitespace and takes the first token
      - Splits by '_' and returns the part before the first underscore,
        so that modified R2 headers (which include extra info) match
        the original R1/R2 headers.
    """
    # Remove leading '@' and take the first token
    token = header[1:].split()[0]
    # Return the part before any underscore (if present)
    return token.split('_')[0]

def main():
    parser = argparse.ArgumentParser(description="Filter paired-end FASTQ files based on modified R2 read IDs.")
    
    parser.add_argument("--modified-r2", required=True, help="Path to modified R2 reads (file1)")
    parser.add_argument("--all-r2", required=True, help="Path to all R2 reads (file2)")
    parser.add_argument("--all-r1", required=True, help="Path to all R1 reads (file3)")
    parser.add_argument("--output", required=True, help="Directory where output files (selected_R2.fastq and selected_R1.fastq) will be saved")
    
    args = parser.parse_args()

    # Ensure output directory exists
    os.makedirs(args.output, exist_ok=True)

    # Define output file paths
    output_r2 = os.path.join(args.output, "selected_R2.fastq")
    output_r1 = os.path.join(args.output, "selected_R1.fastq")

    # Step 1: Build a set of read IDs from the modified R2 file (file1)
    modified_ids = set()
    for header, seq, plus, qual in parse_fastq(args.modified_r2):
        read_id = extract_read_id(header)
        modified_ids.add(read_id)
    print(f"Found {len(modified_ids)} modified read IDs in {args.modified_r2}.")

    # Step 2: Process the all-R2 file (file2) and write matching reads to output_R2
    kept_ids = set()  # Record IDs that are kept for the corresponding R1 reads
    with open(output_r2, "w") as out_r2:
        for header, seq, plus, qual in parse_fastq(args.all_r2):
            read_id = extract_read_id(header)
            if read_id in modified_ids:
                out_r2.write(f"{header}\n{seq}\n{plus}\n{qual}\n")
                kept_ids.add(read_id)
    print(f"Wrote {len(kept_ids)} R2 reads to {output_r2}.")

    # Step 3: Process the all-R1 file (file3) and write matching R1 reads to output_R1
    with open(output_r1, "w") as out_r1:
        for header, seq, plus, qual in parse_fastq(args.all_r1):
            read_id = extract_read_id(header)
            if read_id in kept_ids:
                out_r1.write(f"{header}\n{seq}\n{plus}\n{qual}\n")
    print(f"Wrote matching R1 reads to {output_r1}.")

if __name__ == "__main__":
    main()
