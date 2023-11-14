process fastp {

    publishDir params.outdir, mode: 'copy', pattern: 'fastp_*', saveAs: {filename -> "$filename".replaceAll('fastp_','')}

    tag { sample_id }

    input:
    tuple val(sample_id), path(reads)

    output:
    path("${sample_id}_fastp.csv"), emit: stats
    path("fastp_${reads[0]}")
    path("fastp_${reads[1]}")
    
    script:
    """
    fastp \
      -t ${task.cpus} \
      -i ${reads[0]} \
      -I ${reads[1]} \
      --cut_tail \
      -j ${sample_id}_fastp.json \
      --unpaired1 \
      --unpaired2 \
      -o fastp_${reads[0]} \
      -O fastp_${reads[1]}

    fastp_json_to_csv.py -s ${sample_id} ${sample_id}_fastp.json > ${sample_id}_fastp.csv
    """
}