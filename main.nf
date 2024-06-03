#!/usr/bin/env nextflow

params.in_dir = ""
params.out_dir = "results" 

include { ComputeRRNA } from './modules/ComputeRRNA'
include { AssembleTabs } from './modules/AssembleTabs'

workflow {
    input_files_ch = Channel.fromPath( "${params.in_dir}/**" )
    
    // Run Step 1 : 
    processed_files_ch = ComputeRRNA( input_files_ch )

    // Run Step 2 : 
    output_ch = AssembleTabs( processed_files_ch.toList() )	
}
