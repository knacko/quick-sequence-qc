#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

include { fastp } from './modules/fastp.nf'
include { nanoq } from './modules/nanoq.nf'

workflow {
  if (!(params.illumina ^ params.nanopore)) { //XNOR
      throw new Exception("Either --nanopore or --illumina must be flagged.")
  }

  output_prefix = params.prefix == '' ? params.prefix : params.prefix + '_'
  
  main:
    if (params.illumina) {
      def grouping = { file -> file.name.lastIndexOf('_R').with {it != -1 ? file.name[0..<it] : file.name} }
      ch_fastq_input = Channel.fromFilePairs( params.illumina_search_path, flat: true, grouping).map{ it -> [it[0], it.tail()] }
      fastp(ch_fastq_input)
      fastp.out.stats.collectFile(keepHeader: true, sort: { it.text }, name: "${output_prefix}basic_qc_stats.csv", storeDir: "${params.outdir}")
    }

    if (params.nanopore) {
      def grouping = { file -> file.name.lastIndexOf('_').with {it != -1 ? file.name[0..<it] : file.name} }
      ch_fastq_input = Channel.fromFilePairs( params.nanopore_search_path, flat: true , size: -1, grouping).map{ it -> [(it[0] =~ /barcode\d{1,3}/)[0], it.tail()] }
      nanoq(ch_fastq_input)
      nanoq.out.stats.collectFile(keepHeader: true, sort: { it.text }, name: "${output_prefix}basic_qc_stats.csv", storeDir: "${params.outdir}")
    }
}
