process AssembleBarcodes {
    publishDir "${params.out_dir}", mode: 'copy', pattern: "*"

    input:
    path results
    tuple val(library_name), path(reads)
    path barcodes

    output:
    file "all_chosen_barcodes.txt"
    path "${library_name}"

    script :
    def (read1, read2) = reads
    """
    cat ${results} >> all_chosen_barcodes.txt

    mkdir -p "${library_name}"
    python3 $projectDir/bin/barcodes.py ${read1} ${barcodes} "${library_name}" --plot
    """
}
