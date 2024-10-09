#!/bin/bash

#SBATCH --job-name=transF
#SBATCH --partition=cpu-standard
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100G
#SBATCH --output=%x.out
#SBATCH --error=%x.err
#SBATCH --array=0-1

# set WD
WORKDIR="/home/ab0530s/NovaSeq/genome_readsAL"

# define job-specific variables
case $SLURM_ARRAY_TASK_ID in
  0)
    # 1st task
    INDIVIDUALS=("C001" "C003" "C004" "C005" "C006" "C007" "C008" "C009" "C010" "C010TR1" "C010TR2" "C011"
    "C012" "C012TR1" "C012TR2" "C013" "C013TR1" "C013TR2" "C014" "C015" "C016" "C016TR1" "C016TR2"
    "C018" "C019" "C019TR1" "C019TR2" "C020" "C021" "C022" "C023" "C023TR1" "C024" "C025"
    "C026" "C027" "C028" "C029" "C030" "C031" "C032" "C033" "C034" "C035" "C036" "C037" "C038" "C039"
    "C040" "C041")
    ;;
  1)
    # 2nd task
    INDIVIDUALS=("C042" "C043" "C047" "C047TR1" "C047TR2" "C048" "C048TR1" "C048TR2" "C051" "C052"
    "C053" "C055" "C057" "C058" "C059" "C060" "C063" "C065" "C067" "C069" "C071" "C074" "C075" "C076"
    "C077" "C078" "C079" "C080" "C081" "C082" "C083" "C084" "C085" "C086" "C087" "C088" "C089" "C090"
    "C091" "C094" "C096" "C097" "C099" "C100" "C101" "C103" "C104" "C106" "C107" "C108" "C109" "C111"
    "C112" "C113" "C114" "C115" "C116" "C117")
    ;;
esac

# navigate to WD
cd $WORKDIR

# process each individual's fastq file
for IND in "${INDIVIDUALS[@]}"; do    
	
	# forward reads
	fr_in="${IND}.1.fq"
	fr_out="${IND}.1.mod.fq"
	
	# reverse reads
	rr_in="${IND}.2.fq"
	rr_out="${IND}.2.mod.fq"
	
	# replace _ with : using awk
	awk '{if(NR%4==1) gsub(/_/,":"); print}' $fr_in > $fr_out
	awk '{if(NR%4==1) gsub(/_/,":"); print}' $rr_in > $rr_out

done