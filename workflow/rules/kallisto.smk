
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
    TODO: test and document.
    '''
    option_list = []
    
    if config['kb']['h5ad']:
        option_list.append("--h5ad")
    
    return " ".join(option_list)

        
def get_filter_option():
    '''
    TODO: test and document.
    '''    
    filter_choice = config['kb']['filter']
    
    if filter_choice != "":
        filter_option = f"--filter {filter_choice}"
    else:
        filter_option = ""
    
    return filter_option
    

rule kb_count:
    input:
        get_fastqs
    output:
        "results/kb/{sample}/output.bus"
    params:
        index="resources/kb/index.idx",
        t2g="resources/kb/t2g.txt",
        technology=config["kb"]["technology"],
        filter_option=get_filter_option(),
        count_options=get_count_options(),
        memory=config['kb']['memory_per_cpu'],
        threads=config['kb']['threads']
    log: "results/logs/kb_count/{sample}.err"
    conda:
        "../envs/kallisto.yaml"
    threads: config['kb']['threads']
    resources:
        mem_free_gb=config['kb']['memory_per_cpu'] + 1
    shell:
        """
        rm -rf results/kb/{wildcards.sample} &&
        kb count \
        -i {params.index} \
        -g {params.t2g} \
        --overwrite \
        -t {params.threads} \
        -m {params.memory}G \
        -x {params.technology} \
        {params.filter_option} \
        {params.count_options} \
        -o results/kb/{wildcards.sample} \
        {input} 2> {log}
        """