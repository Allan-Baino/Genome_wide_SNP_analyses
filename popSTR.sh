#!/bin/bash

#SBATCH --job-name=popSTR
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err

# set WD
WORKDIR="/home/ab0530s/NovaSeq/SNPcallf/"
cd $WORKDIR

# input files
str_file="pr_SNPs80"   
pop_file="pop_map.txt" 

# output file
output_file="PR_SNPs80.str"

# insert population information with awk
awk 'NR==FNR {pop[$1]=$2; next} {if (FNR > 1) $2=pop[$1]; print}' OFS="\t" "$pop_file" "$str_file" > "$output_file"

echo "population information added to $output_file"
