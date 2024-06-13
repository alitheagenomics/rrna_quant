process AnalyzeBarcodes {
    publishDir "${params.out_dir}/$library_name", mode: 'copy'
    
    input:
    tuple val(library_name), path(reads)
    path barcodes

    output:
    path "${params.out_dir}/$library_name/*"

    script:
    def (read1, read2) = reads
    """
    mkdir -p ${params.out_dir}/$library_name
    python3 $projectDir/bin/barcodes.py ${read1} ${barcodes} ${params.out_dir}/$library_name
    """
}
