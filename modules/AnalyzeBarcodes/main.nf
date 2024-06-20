process AnalyzeBarcodes {
    publishDir "${params.out_dir}", mode: 'copy'
    
    input:
    tuple val(library_name), path(reads)
    path barcodes

    output:
    path "${library_name}"
    path "${library_name}/chosen_barcodes.txt" 

    script:
    def (read1, read2) = reads
    """
    mkdir -p "${library_name}"
    python3 $projectDir/bin/barcodes.py ${read1} ${barcodes} "${library_name}"

    csv_barcodes_file="${library_name}/Barcode_analysis.csv"
    chosen_barcode_p=\$(awk -F',' 'NR>1 {print \$2}' "\$csv_barcodes_file" | sort -nr | head -n 1)
    if (( \$(echo "\$chosen_barcode_p < 5" | bc -l) )); then
        echo "Error: The chosen barcode is found in less than 5% of reads."
        exit 1
    fi

    chosen_barcode=\$(awk -F',' 'NR>1 {print \$1}' "\$csv_barcodes_file" | head -n 1)
    echo "\$chosen_barcode,${library_name}" > "${library_name}/chosen_barcodes.txt"
    """
}
