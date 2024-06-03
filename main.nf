#!/usr/bin/env nextflow

params.in_dir = ""

include { Step1 } from './modules/Step1'
include { Step2 } from './modules/Step2'

workflow {
    input_files_ch = Channel.fromPath( "${params.in_dir}/**" )
    
    // Run Step 1 : 
    processed_files_ch = Step1( input_files_ch )

    // Run Step 2 : 
    output_ch = Step2( processed_files_ch.toList() )	
}
