#!/bin/bash
#SBATCH --job-name=maker_setup
#SBATCH --partition=pibu_el8
#SBATCH --mem=8G
#SBATCH --time=01:00:00
#SBATCH --output=Logs/02.1_maker_setup_%j.out
#SBATCH --error=Logs/02.1_maker_setup_%j.err

# path to working directory and container
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2/01-MAKER_annotation_setup"
CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/MAKER_3.01.03.sif"

# Create and enter the working directory 
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1


# 2. Generate MAKER control files via Apptainer (or Singularity)

# Detect which binary exists
if command -v apptainer &> /dev/null; then
    CONTAINER_CMD="apptainer"
elif command -v singularity &> /dev/null; then
    CONTAINER_CMD="singularity"
else
    echo "Error: Neither Apptainer nor Singularity found on this system."
    exit 1
fi

# Generate control files
$CONTAINER_CMD exec --bind "$WORKDIR" "$CONTAINER" maker -CTL
