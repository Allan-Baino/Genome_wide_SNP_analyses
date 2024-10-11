#!/bin/bash

#SBATCH --job-name=caBAMf
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

# set WD
WORKDIR="/home/ab0530s/NovaSeq/genome_readsAL/"
cd $WORKDIR

# input and output file names
INPUT_BAM="cans_108indvs.bam"
OUTPUT_BAM="cans_108indvsf.bam"
 
# filter with BAMtools
conda activate bamtools

# filter with the specified flags, reasoning & stringency are dependent on what you can afford to loose and downstream applications.
bamtools filter \
    -mapQuality '>=20' \
    -isPrimaryAlignment 'true' \
    -insertSize '<=800' \
    -in "$INPUT_BAM" \
    -out "$OUTPUT_BAM"

# deactivate env
conda deactivate

# index output file
conda activate samtools
samtools index "$OUTPUT_BAM"
conda deactivate