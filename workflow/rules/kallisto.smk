        
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
