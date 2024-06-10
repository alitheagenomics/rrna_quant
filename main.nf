#!/usr/bin/env nextflow

params.in_dir = ""
params.out_dir = "results" 

include { ComputeRrna } from './modules/ComputeRrna'
include { AssembleRrnaTabs } from './modules/AssembleRrnaTabs'

workflow {
    input_files_ch = Channel.fromPath( "${params.in_dir}/**" )
    
    // Run Step 1 : 
    processed_files_ch = ComputeRrna( input_files_ch )

    // Run Step 2 : 
    output_ch = AssembleRrnaTabs( processed_files_ch.toList() )	
}
