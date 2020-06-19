
rule kb_ref:
    output:
        index="resources/kb/index.idx",
        t2g="resources/kb/t2g.txt"
    params:
        species=config["kb"]["species"]
    log:
        out="results/logs/kb_ref.out",
        err="results/logs/kb_ref.err"
    conda:
        "../envs/kallisto.yaml"
    threads: config['kb']['threads']
    threads: 1
    resources:
        mem_free_gb=4
    shell:
        """
        kb ref \
        -d {params.species} \
        -i {output.index} \
        -g {output.t2g} 2> {log.err} > {log.out}
        """

        
def get_count_options():
    '''
    '''
    option_list = []
    
    if config['kb']['loom']:
        option_list.append(" --loom")
    
    if config['kb']['h5ad']:
        option_list.append(" --h5ad")
    
    if config['kb']['lamanno']:
        option_list.append(" --lamanno")
    
    if config['kb']['nucleus']:
        option_list.append(" --nucleus")
    
    return " ".join(option_list)
    

rule kb_count:
    input:
        get_fastqs
    output:
        "results/kb/{sample}/output.bus"
    params:
        output_folder=lambda wildcards, output: output[0].replace("test", ""),
        index="resources/kb/index.idx",
        t2g="resources/kb/t2g.txt",
        technology=config["kb"]["technology"],
        extra_options=get_count_options(),
        memory=config['kb']['memory_per_cpu'] * config['kb']['threads'],
        threads=config['kb']['threads']
    log:
        out="results/logs/kb_count/{sample}.out",
        err="results/logs/kb_count/{sample}.err"
    conda:
        "../envs/kallisto.yaml"
    threads: config['kb']['threads']
    resources:
        mem_free_gb=config['kb']['memory_per_cpu']
    shell:
        """
        kb count \
        -i {params.index} \
        -g {params.t2g} \
        -x {params.technology} \
        -t {params.threads} \
        -m {params.memory}G \
        {params.extra_options} \
        -o {params.output_folder} \
        {input} 2> {log.err} > {log.out}
        """