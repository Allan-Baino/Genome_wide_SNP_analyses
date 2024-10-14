#!/bin/bash

#SBATCH --job-name=caMKDP
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

# define variables and file path
INPUT_BAM="cans_108indvsf.bam"
OUTPUT_BAM="cans_108indvsf_mkdup.bam"
METRICS_FILE="cans_108indvsf_mkdup_metrics.txt"
PICARD_JAR="/home/ab0530s/picard/picard.jar"

# execute mark duplicates 
conda activate openjdk
java -jar "$PICARD_JAR" MarkDuplicates \
  -I "$INPUT_BAM" \
  -O "$OUTPUT_BAM" \
  -M "$METRICS_FILE"

# deactivate env
conda deactivate