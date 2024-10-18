
**The aim of this analysis layout is to detail the prcoess of generating a high confidence dataset of variants for African giant pouched rats sequenced by the ddRAD method**.

**Brief overview**:
Knowledge of ddRADseq (Peterson et al., 2012), BASH and access to a high performance computing cluster is recommended. Knowledge of dual-indexed sample multiplexing/demultiplexing is recommended and is NOT covered in appended scripts. Knowledge and use of bioinformatics software to wrangle high-throughput sequencing data for population genetics is highly recommended. 

**Data description & availability**:
Raw paired-end reads 2X150 bp, were generated on two lanes of an illumina NovaSeq X series system. Reads were organised into 12 sample pools/directories of sequenced individuals (12 pools = 12 i7 multiplexing indices). Each pool contained a set of individuals adding up to a total of 108 individuals for all 12 pools. To assign reads to respective individuals, the program STACKS v2.68 was used to demultiplex individuals, see ddRADseq protocol attached to familiarise with ddRAD DNA sequencing library design. Data can be accessed at ...SRA.

**Scripts' description**: 
Uploaded shell scripts require a cluster with a Unix/Linux environment and execution of scripts is dependent on data structure. 

**Script 00**: lcafastQC.sh - This script performs standard illumina sequence quality checks https://www.bioinformatics.babraham.ac.uk/projects/fastqc/ with output in the form of .html reports for sequenced pools (2 lanes of 12 sample pools). This script also provides a 'basic' layout for threading tasks through multiple resources on a cluster (SLURM).

**Scripts 01 & 02**: lcatRD12.sh & lcatRD12_2.sh - After demultiplexing, forward (read 1) and reverse (read 2) reads were arranged into individual IDs and sequencing lane i.e read 1 & read 2 for lane 3..read 1 and read 2 for lane 5. These scripts concatenate sequencing output from the two lanes into a single read 1 and 2 files for each unique individual ID. Script 01 was trialed for pool 1 or Idx1, script 02 was then optimized for Idx2..12 pools.

**Script 03**: lgsub.sh - This AWK script is designed to perform substitution of /_ / with ":" (works well with PICARD 🛠️) separating arguments on the header section of read 1 and 2 fastq files for all individuals.  

**Script 04**: lcaMapSM.sh - This script maps forward and reverse reads to an African giant pouched rat reference genome (accession no. GCA_026225945.1) to generate .sam files for each sequenced individual, see bwa-mem2 https://github.com/bwa-mem2/bwa-mem2 and samtools http://www.htslib.org/doc/samtools.html documentation.

**Script 05**: lcaSBP.sh - This script converts .sam files to .bam files (-bh flag specified), adds unique @RG's and checks whether unique @RG's are present for every individual ID before sorting and indexing sorted .bam files. All sorted .bam files were merged to create 
a single .bam file for all 108 individuals which was then indexed (this was done separately on the cluster and NOT included in script). It is also recommended to confirm whether merged .bam file has entire sample size (108 individuals), a simple check/count of unique @RGs 
in the .bam file i.e. samtools | grep can confirm.  

**Script 06**: lcaBAMf.sh - This script is designed to filter merged .bam file (all individuals) with bamtools https://github.com/pezmaster31/bamtools & specified flags to filter out: mapQuality - reads that have mapped below a certain map quality score, isPrimaryAlignment - reads that are not the primary alignment, insertSize - paired-reads mapped beyond a specified distance threshold. Reasons and stringency for specifying filters are dependent on downstream applications of the data..somewhat good practice would be to ask..how much can you afford to throw away? and how will it affect downstream analayses?

**Script 07**: lcaMKDP.sh - This script is designed to locate and tag optical or PCR duplicates (technical artifacts from the PCR process) and, also technical replicates - sequencing library design (estimating discordance in genotypes called for the same sample - genotyping error) using Picard tools https://broadinstitute.github.io/picard/

**Script 08**: lcaMAPQ.sh - This script generates mapping statistics such as average mapping quality, coverage and many more http://qualimap.conesalab.org. One advantage of doing this would be to help make an informed decision on the alignment to advance for further study...before running script 04, DNA library validation data generated on a MiSeq system was used to get mapping statistics for two pouched rat genome alignments (_C. ansorgei_ accession no. GCA_026225945.1 and _C. gambianus_ accession no. GCA_004027575.1). Alignment with better mapping statistics (_C. ansorgei_) was advanced for further investigation.

**Script 09** lcaVC.sh - This script calls variants (SNPs) using BCFtools https://samtools.github.io/bcftools/bcftools.html, there are multiple variant calling software, algorithmic bias can play a role in exact number of SNPs called however, the biological conclusions from downstream analyses will very likely be similar. After generating your .vcf file a rigorous filtering process should ensue to get a high confidence dataset...main aim...acquire a reliable catalog of variants accross samples (variants from comparable regions in the genome across all individuals). Nano run on MiSeq system (DNA library validation) yielded 74,145 variant loci, larger sequencing effort (NovaSeq run) yielded 626,004 variant loci across all individuals. Filtering reduced NovaSeq variant loci to....        
