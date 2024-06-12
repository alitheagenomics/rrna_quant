process AssembleRrnaTabs {
    cpus 2
    memory  = 5.GB
    
    publishDir "${params.out_dir}", enabled: true, mode: 'copy', overwrite: true

    input:
    path input_file

    output:
    path "assembled_file.txt"

    script:
    """
    echo "library_name\trRNA_read_count\tdepth\trRNA_percent" > header.txt
    cat header.txt *.name.txt > assembled_file.txt
    # Rscript plot_figure.R 
    sleep 5
	"""
}


