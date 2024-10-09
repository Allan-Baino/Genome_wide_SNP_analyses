#!/bin/bash

#SBATCH --job-name=nsfastQC
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
WORKDIR="/home/ab0530s/NovaSeq/FastQraw/X204SC24061184-Z01-F001/01.RawData"
cd $WORKDIR

# output folder
OUTPUT_DIR="$WORKDIR/fastqc_output"

# activate env
conda activate fastqc             

# run fastQC for each lane's PE folder
for idx in Idx{1..12}; do
    # ensure each index folder has a corresponding output folder
    mkdir -p "$OUTPUT_DIR/$idx"

    for file in "$idx"/*.fastq.gz; do
        fastqc "$file" -o "$OUTPUT_DIR/$idx"
    done
done

# deactivate env
conda deactivate