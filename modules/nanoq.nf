process nanoq {

    publishDir params.outdir, mode: 'copy', pattern: 'nanoq_*', saveAs: {filename -> "$filename".replaceAll('nanoq_','')}

    tag { sample_id }

    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}_nanoq.csv"), emit: stats
    path("nanoq_${sample_id}.fastq.gz")

    script:
    """
    echo 'sample_id' >> sample_id.csv
    echo "${sample_id}" >> sample_id.csv

    cat ${reads} | nanoq --header --report report.csv --output nanoq_${sample_id}.fastq.gz --output-type g | 

    echo report.csv | tr ' ' ',' > nanoq.csv

    paste -d ',' sample_id.csv nanoq.csv > ${sample_id}_nanoq.csv
    """
}