#!/bin/bash

#SBATCH --job-name=caSBP
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err
#SBATCH --array=0-7

set -e # exit on error

# load bash profile
source ~/.bashrc

# set WD
WORKDIR="/home/ab0530s/NovaSeq/genome_readsAL/"

# define job-specific variables
case $SLURM_ARRAY_TASK_ID in
  0)
    # 1st task
    INDIVIDUALS=("C001" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C010" "C010TR1" "C010TR2" "C011" "C012" "C012TR1")
	;;
  1)
	# 2nd task
	INDIVIDUALS=("C012TR2" "C013" "C013TR1" "C013TR2" "C014" "C015" "C016" "C016TR1" "C016TR2" "C018" "C019" "C019TR1" "C019TR2")
	;;
  2)	
    # 3rd task 
	INDIVIDUALS=("C020" "C021" "C022" "C023" "C023TR1" "C024" "C025" "C026" "C027" "C028" "C029" "C030" "C031" "C032")
	;;
  3)  
    # 4th task 
	INDIVIDUALS=("C033" "C034" "C035" "C036" "C037" "C038" "C039" "C040" "C041" "C042" "C043" "C047" "C047TR1" "C047TR2")
    ;;
  4)
    # 5th task
    INDIVIDUALS=("C048" "C048TR1" "C048TR2" "C051" "C052" "C053" "C055" "C057" "C058" "C059" "C060" "C063" "C065" "C067") 
	;;
  5)
	# 6th task
	INDIVIDUALS=("C069" "C071" "C074" "C075" "C076" "C077" "C078" "C079" "C080" "C081" "C082" "C083" "C084" "C085")
	;;
  6)
	# 7th task
	INDIVIDUALS=("C086" "C087" "C088" "C089" "C090" "C091" "C094" "C096" "C097" "C099" "C100" "C101" "C103" "C104")
	;;
  7)
	# 8th task
	INDIVIDUALS=("C106" "C107" "C108" "C109" "C111" "C112" "C113" "C114" "C115" "C116" "C117")
    ;;
esac

# navigate to WD
cd $WORKDIR

# convert .sam to .bam format, add @RG with Picard, qc before sorting and indexing
for IND in "${INDIVIDUALS[@]}"; do
    
	    # convert .sam to .bam
	    conda activate samtools
	    samtools view -bh ${IND}.sam > ${IND}.bam
    	conda deactivate
	    
		# define variables
		input_bam="${IND}.bam"
		output_bam="${IND}_rgad.bam"
		picard_jar="/home/ab0530s/picard/picard.jar"
		
		# add @RG to bam files with Picard tools 
		conda activate openjdk
		java -jar "$picard_jar" AddOrReplaceReadGroups \
		        -I "$input_bam" \
		        -O "$output_bam" \
		        -RGID "$IND" \
		        -RGLB "lib1" \
		        -RGPL "illumina" \
		        -RGPU "unit_$IND" \
		        -RGSM "$IND" \
		        -VALIDATION_STRINGENCY LENIENT
		
		echo "read groups added to $IND"
		conda deactivate
	
		# check for @RG in the bam files
	    conda activate samtools
		if samtools view -H ${IND}_rgad.bam | grep -q '@RG'; then
	        echo "@RG line found in ${IND}_rgad.bam"
        
	        # proceed with sorting and indexing
	      	samtools sort ${IND}_rgad.bam -o ${IND}_rgsorted.bam
	        samtools index ${IND}_rgsorted.bam
        
	        echo "sorted and indexed ${IND}_rgsorted.bam"
	    else
	        echo "no @RG line found in ${IND}_rgad.bam"
	    fi
		# deactivate env
		conda deactivate
done