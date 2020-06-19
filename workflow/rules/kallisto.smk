localrules: install_kb


rule install_kb:
    input:
        "workflow/envs/kallisto.yaml"
    output:
        "results/logs/kb-python.path"
    log: "results/logs/install/kb-python.log"
    conda:
        "../envs/kallisto.yaml"
    shell:
        """
        pip install kb-python > {log} &&
        which kb > {output}
        """
