#!/usr/bin/env nextflow

params.input = ""
params.rrna_ref = "data/rRNA.fa"
params.barcodes = ""
params.out_dir = "results"

include { ComputeRrna } from './modules/ComputeRrna'
include { AssembleRrnaTabs } from './modules/AssembleRrnaTabs'
include { AnalyzeBarcodes } from './modules/AnalyzeBarcodes'

workflow {
    // Load FASTQs into channel
    sample_run_ch = Channel.fromFilePairs( params.input + '*_R{1,2}.fastq.gz', checkIfExists:true ) 
    rrna_ref_ch = Channel.fromPath( params.rrna_ref ).collect()
    barcodes_channel = Channel.fromPath(params.barcodes).collect()
 
    // Run Step 1 : 
    processed_files_ch = ComputeRrna( sample_run_ch, rrna_ref_ch )

    // Run Step 2 : 
    output_ch = AssembleRrnaTabs( processed_files_ch.toList() )	

    // Run Step 3 :
    output_barcodes = AnalyzeBarcodes(sample_run_ch, barcodes_channel)
}
