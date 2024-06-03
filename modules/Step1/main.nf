process Step1 {
    input:
    path input_file 

    output:
    path "*.name.txt"

    script:
    file_name = input_file.getName()
    """ 
        echo "${file_name}" | sed 's/_R2.fastq_wc_counts.txt//g' > filename.txt
        cat $input_file | awk '{print \$2-\$1, \$2, 100*(\$2-\$1)/\$2}' | tr " " "\t" > ${file_name}.percent.txt
        paste filename.txt ${file_name}.percent.txt > ${file_name}.name.txt
    """
}
