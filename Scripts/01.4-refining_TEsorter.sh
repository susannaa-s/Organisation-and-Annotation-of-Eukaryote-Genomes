#!/bin/bash
#SBATCH --job-name=TEsorter_refine
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=12:00:00
#SBATCH --output=./Logs/01.4_TEsorter_%j.out
#SBATCH --error=./Logs/01.4_TEsorter_%j.err

# ----------------------------------------------------------
# User-defined paths
# ----------------------------------------------------------
WORKDIR=/data/users/sschaerer/Eukaryote_Genome_Annotation_2
EDTA_LIB=$WORKDIR/Results/Part_1/01-EDTA_annotation/hifiasm_p_ctg.fasta.mod.EDTA.TElib.fa
RESULTS=$WORKDIR/Results/Part_1/04-Refinement_TEsorter
CONTAINER=/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif

# Create output directories
mkdir -p $RESULTS/Copia $RESULTS/Gypsy

echo "======================================================="
echo " Step 1: Extracting Copia and Gypsy sequences"
echo "======================================================="

# ----------------------------------------------------------
# Step 1: Extract Copia and Gypsy sequences
# ----------------------------------------------------------
seqkit grep -r -p "Copia" $EDTA_LIB > $RESULTS/Copia_sequences.fa
seqkit grep -r -p "Gypsy" $EDTA_LIB > $RESULTS/Gypsy_sequences.fa

echo "Extracted:"
echo "  - Copia: $(grep -c '>' $RESULTS/Copia_sequences.fa) sequences"
echo "  - Gypsy: $(grep -c '>' $RESULTS/Gypsy_sequences.fa) sequences"

echo "======================================================="
echo " Step 2: Running TEsorter"
echo "======================================================="

# ----------------------------------------------------------
# Run TEsorter on Copia
# ----------------------------------------------------------
echo "Running TEsorter on Copia..."
cd $RESULTS/Copia
apptainer exec --bind $WORKDIR \
    $CONTAINER TEsorter \
    $RESULTS/Copia_sequences.fa \
    -db rexdb-plant \
    -p $SLURM_CPUS_PER_TASK

echo "Copia completed."

# ----------------------------------------------------------
# Run TEsorter on Gypsy
# ----------------------------------------------------------
echo "Running TEsorter on Gypsy..."
cd $RESULTS/Gypsy
apptainer exec --bind $WORKDIR \
    $CONTAINER TEsorter \
    $RESULTS/Gypsy_sequences.fa \
    -db rexdb-plant \
    -p $SLURM_CPUS_PER_TASK

echo "Gypsy completed."

echo "======================================================="
echo " All done. TEsorter clade-level classification finished."
echo " Output in:"
echo "   $RESULTS/Copia"
echo "   $RESULTS/Gypsy"
echo "======================================================="
