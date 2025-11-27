#!/bin/bash
#SBATCH --job-name=run_EDTA
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/01.1_EDTA_%j.out
#SBATCH --error=./Logs/01.1_EDTA_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=2-00:00:00
#SBATCH --mem=250G

# Definition of Directories
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation"
mkdir -p $WORKDIR/Results/Part_1/01-EDTA_annotation
cd $WORKDIR/Results/Part_1/01-EDTA_annotation

# Paths to Software and Data
EDTA_CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif"
GENOME="$WORKDIR/Data/hifiasm_p_ctg.fasta"
CDS="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated"

echo "[$(date)] Starting EDTA annotation on $GENOME"

# Mounting and Running EDTA within the Container
# Settings according to manual 1 : Week1-2: Transposable Element Annotation and Classification
apptainer exec \
  --bind ${WORKDIR},/data/courses/assembly-annotation-course/CDS_annotation \
  ${EDTA_CONTAINER} EDTA.pl \
  --genome ${GENOME} \
  --species others \
  --step all \
  --sensitive 1 \
  --cds ${CDS} \
  --anno 1 \
  --force 1 \
  --threads ${SLURM_CPUS_PER_TASK}



echo "[$(date)] EDTA completed successfully."
