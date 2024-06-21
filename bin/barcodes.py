#!/usr/bin/python3
import subprocess
import os
import glob
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import gzip
from Bio import SeqIO
import argparse
import csv

def main(fastq_file, barcodes_dir, output_dir, save_plot=False):
    subprocess.call(f"zcat {fastq_file} | head -100000 > FASTQ_sub.fq", shell=True)    # to read first 100k lines of FASTQ file

    barcodes_analysis(barcodes_dir, output_dir, save_plot)

def barcodes_analysis(barcodes_dir, output_dir, save_plot=False):    
    # Alithea's barcodes
    barcodes_files = glob.glob(os.path.join(barcodes_dir, '*brb.txt'))
    barcodes_names = [os.path.splitext(os.path.basename(bfiles))[0] for bfiles in barcodes_files]
    barcodes_names = [name.replace('barcodes_', '').replace('_brb','') for name in barcodes_names]
    alithea_barcodes = {}
    for barcode_file, barcode_name in zip(barcodes_files, barcodes_names):
        with open(barcode_file, 'r') as file:
            seq = []
            next(file)  # skip first line (name)
            for line in file :
                sep = line.split()    # don't want the name
                seq.append(sep[1])    # all sequences from a set of barcodes
            alithea_barcodes[barcode_name] = seq

    # Read barcodes embedded in the FASTQ
    fastq_file = 'FASTQ_sub.fq'
    barcodes = []
    with open(fastq_file, "r") as handle:
        recs = SeqIO.parse(handle, "fastq")
        for rec in recs:
            barcode = str(rec.seq)[0:14]
            barcodes.append(barcode)

    # Calculate percentage of reads associated with each barcode
    percentages = {}
    counts = {brc: 0 for brc in barcodes_names}
    for seq in barcodes:      # for each read in the FASTQ file
        for brc in barcodes_names:
            if len(alithea_barcodes[brc][0]) == 12:
                if seq[:12] in alithea_barcodes[brc]:  # if barcodes is only 12 nt, look at first 12 positions
                    counts[brc] += 1
            else:
                if seq in alithea_barcodes[brc]:
                    counts[brc] += 1
    total_reads = len(barcodes)
    percentages_dict = {brc: (counts[brc] / total_reads) * 100 for brc in counts}
    percentages = sorted([(key, value) for key, value in percentages_dict.items()], key=lambda x: x[1], reverse=True)
    
    barcodes_hierarchy = "/Users/athonet/Library/CloudStorage/OneDrive-AlitheaGenomicsSA/Desktop/Shiny_app1/rrna_quant/barcodes_hierarchy.txt"
    with open(barcodes_hierarchy, 'r') as file:
        hierarchy = [line.strip() for line in file]

    # Checks if ties
    ties = []
    max_p = percentages[0][1]
    for barcode, percentage in percentages:
        if percentage == max_p:
            ties.append(barcode)
        else:
            break
    if len(ties) > 1:
        for barcode in hierarchy:
            if barcode in ties:
                chosen_barcode = barcode
                break
    else:
        chosen_barcode = percentages[0][0]
    
    percentages = [(barcode, percentage) for barcode, percentage in percentages if barcode == chosen_barcode] + \
              [(barcode, percentage) for barcode, percentage in percentages if barcode != chosen_barcode]

    # Barplot
    barcodes = [item[0] for item in percentages]
    values = [item[1] for item in percentages]
    if save_plot:
        barplot = plt.figure(figsize=(10, 6))
        plt.bar(barcodes, values)
        plt.xlabel('Barcodes')
        plt.xticks(fontsize=6, rotation=45, ha='right')
        plt.ylabel('Percentage of Reads')
        plt.title(f'Percentage of reads associated with each barcode for a given library')
        plt.ylim(0, 100)
        plt.subplots_adjust(left=0.1, right=0.9, top=0.9, bottom=0.4)
        ax = plt.gca()
        xticks = ax.get_xticklabels()
        for label in xticks:           
            if label.get_text() == chosen_barcode:
                label.set_color('red')
        output_file = os.path.join(output_dir, 'Barcode_analysis.pdf')
        plt.savefig(output_file, format='pdf', bbox_inches='tight')    
        plt.close()

    # Saving to .csv
    table_data = [(f'{item[0]}', f'{item[1]}') for item in percentages]  
    output_csv_file = os.path.join(output_dir, 'Barcode_analysis.csv')
    with open(output_csv_file, 'w', newline='') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(['Barcode', 'Percentage of Reads'])
        csvwriter.writerows(table_data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process FASTQ file and barcodes directory")
    parser.add_argument("fastq_file", help="Path to the FASTQ file")
    parser.add_argument("barcodes_dir", help="Path to the directory containing barcode files")
    parser.add_argument("output_dir", help="Directory to save the output plot")
    parser.add_argument("--plot", action='store_true', help="Option to save plot as Barcode_analysis.pdf")
    args = parser.parse_args()

    main(args.fastq_file, args.barcodes_dir, args.output_dir, args.plot)
