process AssembleRrnaTabs {
    cpus 2
    memory  = 5.GB
    
    publishDir "${params.out_dir}", enabled: true, mode: 'copy', overwrite: true

    input:
    path input_file

    output:
    path "assembled_file.txt"
    path "rRNA_content.pdf"
    path "rRNA_table.csv"

    script:
    script:
    """
    cat > script.R << 'EOF'
    system('echo "library_name\trRNA_read_count\tdepth\trRNA_percent" > header.txt')
    system('cat header.txt *.name.txt > assembled_file.txt')

    library(ggplot2)
    library(dplyr)
    rrna_data <- read.table('assembled_file.txt', header = TRUE, sep = '\\t')
    pdf("rRNA_content.pdf", width = 15, height = 10)
    ggplot(rrna_data, aes(x = library_name, y = rRNA_percent)) +
        geom_bar(stat = 'identity', fill = 'steelblue') +
        labs(x = 'Library', y = 'rRNA Content [%]', title = 'Ribosomal RNA Content') +
        theme(axis.text.x = element_text(angle = 45, hjust = 1), plot.title = element_text(hjust = 0.5))
    dev.off()
    write.csv(rrna_data[, c("library_name", "rRNA_percent")], "rRNA_table.csv", row.names = FALSE)
    EOF

    /opt/conda/envs/cornalin/bin/Rscript script.R
	"""
}
