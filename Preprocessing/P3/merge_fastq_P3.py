#!/usr/bin/env python3

import os
import glob
import argparse

def merge_fastq(input_dir, output_file):
    """Merges all .fastq files in the given directory into a single file."""
    
    fastq_files = sorted(glob.glob(os.path.join(input_dir, "*.fastq")))

    if not fastq_files:
        print(f"No .fastq files found in {input_dir}.")
        return
    
    print(f"Found {len(fastq_files)} .fastq files. Merging into {output_file}...")

    with open(output_file, "w") as outfile:
        for file in fastq_files:
            print(f"Merging {file}...")
            with open(file, "r") as infile:
                outfile.write(infile.read())

    print(f"Merge complete. Output saved to {output_file}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge all .fastq files in a directory into a single file.")
    parser.add_argument("--input_dir", "-i", required=True, help="Path to the directory containing .fastq files")
    parser.add_argument("--output_file", "-o", required=True, help="Path to the output merged .fastq file")

    args = parser.parse_args()
    
    merge_fastq(args.input_dir, args.output_file)
