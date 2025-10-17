#!/bin/bash
#SBATCH --job-name=run_EDTA
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/EDTA_%j.out
#SBATCH --error=./Logs/EDTA_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=20
#SBATCH --time=2-00:00:00
#SBATCH --mem=250G

# --- Directories ---
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation"
mkdir -p $WORKDIR/Results_2/01-EDTA_annotation
cd $WORKDIR/Results_2/01-EDTA_annotation

# --- Paths ---
EDTA_CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif"
GENOME="$WORKDIR/Data/hifiasm_p_ctg.fasta"
CDS="/data/courses/assembly-annotation-course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_updated"

echo "[$(date)] Starting EDTA annotation on $GENOME"

# --- Run EDTA ---
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
