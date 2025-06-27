#!/usr/bin/env python3
import sys
import os
import argparse

def load_whitelist(whitelist_file):
    """
    Load a whitelist mapping from a file with three columns:
      well_name    well_number    barcode
    The mapping returned is: barcode -> "wellname_wellnumber"
    """
    mapping = {}
    with open(whitelist_file, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) < 3:
                continue
            well_name, well_number, barcode = parts[0], parts[1], parts[2]
            mapping[barcode] = f"{well_name}_{well_number}"
    return mapping

def demultiplex_fastq(fastq_file, whitelist, original_filename, outdir):
    """
    Reads the input FASTQ file and writes separate FASTQ files for each cell barcode.
    Assumes the header contains an underscore-separated structure where the second-to-last field
    is the cell barcode and the last field (before any space) is the UMI, such as produced by UMI-tools with standard settings earlier on in the preprocessing.
    
    Example header:
      @LH00250:21:22GYFYLT3:7:1101:1518:1128_ACGCTCTT_AGATTT 2:N:0:TAATCGATCT
    Here, the barcode is "ACGCTCTT".
    
    Records are written to output files named:
      {original_basename}_{wellID}.fastq
    within the output folder.
    
    Returns a dictionary mapping wellID to the number of reads written.
    """
    outputs = {}
    read_counts = {}
    base_name = os.path.basename(original_filename)
    
    with open(fastq_file, "r") as fq:
        while True:
            header = fq.readline()
            if not header:
                break  # End of file reached. If there is no header anymore you are at the end of the file
            seq = fq.readline()
            plus = fq.readline()
            qual = fq.readline()
            if not (seq and plus and qual):
                print(f"Warning: Incomplete read detected after header: {header.strip() if header else '[unknown]'}")
                break

            header = header.strip()
            parts = header.split("_")
            if len(parts) < 3:
                # Unexpected header structure, skip this read
                print(f"Skipping read with unexpected header: {header}")
                continue
            # Assume the second-to-last field is the cell barcode.
            cell_barcode = parts[-2]
            # UMI is the last underscore field (strip any trailing spaces).
            _ = parts[-1].split()[0] #this variable is not used now but could be used to extract the UMI if desired

            # Lookup well identifier using the barcode.
            wellID = whitelist.get(cell_barcode, "unknown")
            
            # Open output file for this well if not already open.
            if wellID not in outputs:
                out_filename = os.path.join(outdir, f"{os.path.splitext(base_name)[0]}_{wellID}.fastq")
                outputs[wellID] = open(out_filename, "w")
                read_counts[wellID] = 0

            # Optionally, append well information to the header.
            new_header = f"{header} WELL:{wellID}"
            outputs[wellID].write(f"{new_header}\n{seq}{plus}{qual}")
            read_counts[wellID] += 1

    for fh in outputs.values():
        fh.close()

    return read_counts

def write_report(report_file, read_counts, total_reads):
    """
    Writes a summary report listing the number of reads per output file.
    """
    with open(report_file, "w") as rep:
        rep.write("Demultiplexing Report\n")
        rep.write("=====================\n")
        rep.write(f"Total reads processed: {total_reads}\n\n")
        rep.write("Reads per well:\n")
        for well, count in sorted(read_counts.items()):
            rep.write(f"  {well}: {count}\n")
    print(f"\nReport written to: {report_file}")

def count_total_reads(fastq_file):
    """
    Counts the total number of reads in the FASTQ file.
    Each read occupies four lines.
    """
    total = 0
    with open(fastq_file, "r") as fq:
        for i, _ in enumerate(fq):
            pass
    return (i + 1) // 4

def main():
    parser = argparse.ArgumentParser(description="Demultiplex a FASTQ file based on a cell barcode whitelist.")
    parser.add_argument("fastq", help="Input FASTQ file")
    parser.add_argument("whitelist", help="Whitelist file with three columns: well name, well number, barcode")
    parser.add_argument("--outdir", default=".", help="Output folder for demultiplexed files and report (default: current directory)")
    args = parser.parse_args()

    # Create output directory if it doesn't exist.
    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)
        print(f"Created output directory: {args.outdir}")

    # Load whitelist mapping.
    whitelist = load_whitelist(args.whitelist)
    
    total_reads = count_total_reads(args.fastq)
    print(f"Total reads in input file: {total_reads}")

    # Demultiplex the FASTQ file.
    read_counts = demultiplex_fastq(args.fastq, whitelist, args.fastq, args.outdir)

    # Write a summary report.
    base_name = os.path.basename(args.fastq)
    report_filename = os.path.join(args.outdir, f"{os.path.splitext(base_name)[0]}_demux_report.txt")
    write_report(report_filename, read_counts, total_reads)
    print("Demultiplexing complete.")

if __name__ == "__main__":
    main()
