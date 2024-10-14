#!/bin/bash

#SBATCH --job-name=caVC
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

# we want to call variants (SNPs) from merged .bam (C. ansorgei genome) files
# reads aligned better to C. ansorgei genome (better mapping metrics compared
# to C. gambianus genome).

# We shall use the algorithms mpileup and call in bcftools. mpileup requires 
# an input file .bam and a reference genome. flags can be specified as follows: 
# -fasta-ref reference genome, --annotate add extra info to the output .vcf file
# these can be AD - allele depth, DP - total depth/coverage. The output is piped | to
# the call command and flags can specified as: -m multi-allelic version of the 
# genotype caller (different to -c consensus model) -v print only variant sites,
# if not, all sites in the ref genome will be printed (for some analyses you may want all sites),
# -f adding extra format fields such as genotype quality score GQ, --skip-variants
# specifies variant type in this case SNPs and not indels, --group-samples makes 
# sures variants are grouped by popn, -o output file name.

# activate env
conda activate bcftools
bcftools mpileup --fasta-ref GCA_026225945.1_Cans_v1.0_COR_genomic.fa -a AD,DP cans_108indvsf_mkdup.bam | 
bcftools call -m -v -f GQ --skip-variants indels --group-samples popn_grps.txt -o cans_108inds.vcf
#deactivate env
conda deactivate

echo "processing complete."
