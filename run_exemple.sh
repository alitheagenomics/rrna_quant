#!/bin/bash

# launch nextflow pipeline with two parameters
nextflow run main.nf --input ../data/dataset_test_TGBEK12/ --out_dir results_new --ref data/rRNA.fa
