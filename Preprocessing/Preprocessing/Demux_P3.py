import sys
import os
import argparse
import logging
import contextlib

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

def load_whitelist(whitelist_file):
    """
    Load whitelist mapping: barcode -> "wellname_wellnumber"
    """
    mapping = {}
    with open(whitelist_file, "r") as f:
        for lineno, line in enumerate(f, start=1):
            line = line.strip()
            if not line:
                continue
            parts = line.split()
            if len(parts) < 3:
                logging.warning(f"Line {lineno}: malformed, skipped: {line}")
                continue
            well_name, well_number, barcode = parts[:3]
            mapping[barcode] = f"{well_name}_{well_number}"
    logging.info(f"Loaded {len(mapping)} barcodes from whitelist")
    return mapping

def hamming_distance(s1, s2):
    return sum(ch1 != ch2 for ch1, ch2 in zip(s1, s2))

def demultiplex_fastq(fastq_file, whitelist, max_mismatch=0, outdir='.'):
    """
    Demultiplex reads into per-well FASTQ files using ExitStack for automatic closing.
    """
    read_counts = {}
    ambiguous_count = 0
    base_name = os.path.basename(fastq_file)
    whitelist_keys = list(whitelist.keys())

    with contextlib.ExitStack() as stack:
        outputs = {}
        with open(fastq_file, 'r') as fq:
            while True:
                header = fq.readline()
                if not header:
                    break
                seq = fq.readline()
                plus = fq.readline()
                qual = fq.readline()
                if not (seq and plus and qual):
                    logging.warning("Incomplete read at end of file")
                    break

                header = header.strip()
                parts = header.split("_")
                if len(parts) < 3:
                    logging.warning(f"Skipping unexpected header: {header}")
                    continue

                cell_barcode = parts[-2]

                # Exact or fuzzy match
                if cell_barcode in whitelist:
                    wellID = whitelist[cell_barcode]
                else:
                    candidates = [bc for bc in whitelist_keys
                                  if len(bc) == len(cell_barcode)
                                  and hamming_distance(bc, cell_barcode) <= max_mismatch]
                    if len(candidates) == 1:
                        wellID = whitelist[candidates[0]]
                    else:
                        if candidates:
                            logging.debug(f"Ambiguous {cell_barcode}: {candidates}")
                        ambiguous_count += 1
                        wellID = 'unknown'

                # Open per-well file if needed
                if wellID not in outputs:
                    out_fn = os.path.join(outdir, f"{os.path.splitext(base_name)[0]}_{wellID}.fastq")
                    fh = stack.enter_context(open(out_fn, 'w'))
                    outputs[wellID] = fh
                    read_counts[wellID] = 0

                new_header = f"{header} WELL:{wellID}"
                fh = outputs[wellID]
                fh.write(f"{new_header}\n{seq}{plus}{qual}")
                read_counts[wellID] += 1

    logging.info(f"Processed {sum(read_counts.values()) + ambiguous_count} reads; ambiguous: {ambiguous_count}")
    return read_counts, ambiguous_count

def write_report(report_file, read_counts, total_reads, ambiguous_count):
    with open(report_file, 'w') as rep:
        rep.write("Demultiplexing Report\n=====================\n")
        rep.write(f"Total reads processed: {total_reads}\n")
        rep.write(f"Ambiguous barcodes: {ambiguous_count}\n\n")
        rep.write("Reads per well:\n")
        for well, count in sorted(read_counts.items()):
            rep.write(f"  {well}: {count}\n")
    logging.info(f"Report written to {report_file}")

def count_total_reads(fastq_file):
    with open(fastq_file, 'r') as fq:
        return sum(1 for _ in fq) // 4

def main():
    parser = argparse.ArgumentParser(
        description="Demultiplex FASTQ using a barcode whitelist with optional mismatch tolerance.",
        formatter_class=argparse.RawTextHelpFormatter
    )
    parser.add_argument("fastq", help="Input FASTQ file with barcoded reads.")
    parser.add_argument("whitelist", help="Whitelist file with columns: well_name, well_number, barcode.")
    parser.add_argument("--outdir", default='.', help="Directory to write demultiplexed FASTQ files and report.")
    parser.add_argument(
        "--mismatch",
        type=int,
        default=0,
        help=(
            "Maximum number of mismatches allowed when matching barcodes (default: 0).\n"
            "Use this to tolerate sequencing errors in barcodes.\n"
            "Examples:\n"
            "  --mismatch 0   Only exact matches allowed\n"
            "  --mismatch 1   Allow barcodes with up to 1 base difference\n"
            "NOTE: If multiple whitelist barcodes match a read within this threshold,\n"
            "the read will be marked as ambiguous and assigned to 'unknown'."
        )
    )
    args = parser.parse_args()

    os.makedirs(args.outdir, exist_ok=True)
    logging.info(f"Output directory: {args.outdir}")

    whitelist = load_whitelist(args.whitelist)
    total_reads = count_total_reads(args.fastq)
    logging.info(f"Total reads in input: {total_reads}")

    read_counts, ambiguous_count = demultiplex_fastq(
        args.fastq, whitelist,
        max_mismatch=args.mismatch,
        outdir=args.outdir
    )

    report_fn = os.path.join(args.outdir, f"{os.path.splitext(os.path.basename(args.fastq))[0]}_demux_report.txt")
    write_report(report_fn, read_counts, total_reads, ambiguous_count)
    logging.info("Demultiplexing complete.")

if __name__ == '__main__':
    main()
