process ComputeRrna {
    maxForks 10

    input:
    tuple val(library_name), path(reads)
    path rrna_ref

    output:
    path "*.name.txt"

    script:
    def (read1, read2) = reads 
    """ 
        # Run BBTools - BBSplit with reference rRNA fasta 
        /opt/conda/envs/cornalin/bin/bbsplit.sh in=${read2} ref="${rrna_ref}" outu="${library_name}_clean.fastq"
        # count Reads - Outputs a file
        echo \$(wc -l ${library_name}_clean.fastq | cut -d' ' -f1)" "\$(zcat $read2 | wc -l | cut -d' ' -f1) > ${library_name}_wc_counts.txt
        
        # Use kmercountexract to analyze kmer composition
        /opt/conda/envs/cornalin/bin/kmercountexact.sh -Xmx48g in=${read2} mincount=1000 k=21 out=${library_name}_kmer.txt overwrite=true
        # 2. Parse the kmer.fa file to order it by usage
        grep "^>" ${library_name}_kmer.txt > ${library_name}_headers.txt
        grep -v "^>" ${library_name}_kmer.txt > ${library_name}_sequences.txt
        paste ${library_name}_headers.txt ${library_name}_sequences.txt > ${library_name}_combined.txt
        sort -t'>' -k2,2n ${library_name}_combined.txt > ${library_name}_sorted_combined.txt
        rm ${library_name}_clean.fastq
 
        # Assemble results
        echo "${library_name}" > filename.txt
        cat ${library_name}_wc_counts.txt | awk '{print \$2-\$1, \$2, 100*(\$2-\$1)/\$2}' | tr " " "\t" > ${library_name}.percent.txt
        paste filename.txt ${library_name}.percent.txt > ${library_name}.name.txt
    """
}
