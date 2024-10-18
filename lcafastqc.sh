#!/bin/bash

#SBATCH --job-name=fastQC
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err
#SBATCH --array=0-11

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

# define job-specific variables
case $SLURM_ARRAY_TASK_ID in
  0)
    idx="Idx1"
    ;;
  1)
    idx="Idx2"
    ;;
  2)
    idx="Idx3"
    ;;
  3)
    idx="Idx4"
    ;;
  4)
    idx="Idx5"
    ;;
  5)
    idx="Idx6"
    ;;
  6)
    idx="Idx7"
    ;;
  7)
    idx="Idx8"
    ;;
  8)
    idx="Idx9"
    ;;
  9)
    idx="Idx10"
    ;;
  10)
    idx="Idx11"
    ;;
  11)
    idx="Idx12"
    ;;
esac

# ensure each index folder has a corresponding output folder
mkdir -p "$OUTPUT_DIR/$idx"

# run fastQC for each lane's PE folder    
for file in "$idx"/*.fastq.gz; do
    fastqc "$file" -o "$OUTPUT_DIR/$idx"
done

# deactivate env
conda deactivate
