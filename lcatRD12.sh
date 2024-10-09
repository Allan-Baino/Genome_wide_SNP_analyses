#!/bin/bash

#SBATCH --job-name=catRD12
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err

set -e # exit on error

# set WD
WORKDIR="/home/ab0530s/NovaSeq/FastQraw/X204SC24061184-Z01-F001/01.RawData/Idx1"
cd $WORKDIR

# define directories
dir3="samples3"
dir5="samples5"
output_dir="combined_samples"

# create the output directory
mkdir -p "$output_dir"

# loop over all read 1 and 2 files in samples3 directory
for file in "$dir3"/*.fq; do
    # extract the filename
    filename=$(basename "$file")

    # define corresponding file in samples5 directory
    file5="$dir5/$filename"

    # check if file exists in samples5 directory
    if [ -f "$file5" ]; then
        # ensure only read 1 file is concatenated with read 1 likewise for read 2 files (multiple condition check)
        if [[ "$filename" =~ \.1\.fq$ ]]; then
            echo "concatenating read 1 files: $filename"
        elif [[ "$filename" =~ \.2\.fq$ ]]; then
            echo "concatenating read 2 files: $filename"
        else
            echo "skipping unrecognized file: $filename"
            continue
        fi

        # concatenate the files and output to new directory
        cat "$file" "$file5" > "$output_dir/$filename"
        echo "concatenated $filename from both lanes into $output_dir/$filename"
    else
        echo "file $filename not found in $dir5, skipping."
    fi
done