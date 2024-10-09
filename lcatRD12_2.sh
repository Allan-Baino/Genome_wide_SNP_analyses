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

# set base WD
BASEWORKDIR="/home/ab0530s/NovaSeq/FastQraw/X204SC24061184-Z01-F001/01.RawData"

# define directories for samples
dir3="samples3"
dir5="samples5"
output_dir="combined_samples"

# loop through directories Idx2 to Idx12
for idx in {2..12}; do
    WORKDIR="$BASEWORKDIR/Idx$idx"

    # check if directory exists before proceeding
    if [ -d "$WORKDIR" ]; then
        echo "processing directory: $WORKDIR"
        cd "$WORKDIR"

        # create output directory for concatenated files
        mkdir -p "$output_dir"

        # loop over all read 1 and read 2 files in the samples3 directory
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
    else
        echo "directory $WORKDIR not found, skipping."
    fi
done