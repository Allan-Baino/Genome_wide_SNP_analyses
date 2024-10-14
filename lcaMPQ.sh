#!/bin/bash

#SBATCH --job-name=caMPQ
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err

set -e # exit on error

# load bash profile
source ~/.bashrc

WORKDIR="/home/ab0530s/NovaSeq/genome_readsAL/"
cd $WORKDIR

# define variables
JAVA_MEM_SIZE="30g"
INPUT_FILE="cans_108indvsf_mkdup.bam"
OUTPUT_FILE="cans_108indvf_mkdup_mq.pdf"

# activate qualimap
conda activate qualimap

# generate mapping quality stats
qualimap bamqc --java-mem-size="$JAVA_MEM_SIZE" \
  -bam "$INPUT_FILE" \
  -outfile "$OUTPUT_FILE"

# deactivate qualimap
conda deactivate