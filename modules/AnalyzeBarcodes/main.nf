process AnalyzeBarcodes {
    publishDir "${params.out_dir}", mode: 'copy'
    
    input:
    tuple val(library_name), path(reads)
    path barcodes

    output:
    path "${library_name}"

    script:
    def (read1, read2) = reads
    """
    mkdir -p "${library_name}"
    python3 $projectDir/bin/barcodes.py ${read1} ${barcodes} "${library_name}"
    """
}
