from snakemake.utils import validate
import pandas as pd
import glob
import itertools

# this container defines the underlying OS for each job when using the workflow
# with --use-conda --use-singularity
singularity: "docker://continuumio/miniconda3"

##### load config and sample sheets #####

configfile: "config/config.yaml"
validate(config, schema="../schemas/config.schema.yaml")

samples = pd.read_csv(config["samples"], sep="\t").set_index("sample", drop=False)
samples.index.names = ["sample_id"]
validate(samples, schema="../schemas/samples.schema.yaml")

####### helpers ###########

def get_fastqs(wildcards):
    """
    Get raw FASTQ files from the sample sheet.
    """
    fastq1_dir = samples["fastqs"][wildcards.sample]
    fastq1_pattern = config["pattern"]["read1"]
    fastq1_glob = f"{fastq1_dir}/*{fastq1_pattern}*"
    fastq1 = glob.glob(fastq1_glob)
    
    if len(fastq1) == 0:
        raise OSError(f"No file matched pattern: {fastq1_glob}")
    
    fastq2 = [file.replace(config["pattern"]["read1"], config["pattern"]["read2"]) for file in fastq1]
    for file in fastq2:
        if not os.path.exists(file):
            raise OSError(f"Paired file not found: {file}")
            
    fastqs = [x for x in itertools.chain.from_iterable(zip(fastq1, fastq2))]
    
    return fastqs
