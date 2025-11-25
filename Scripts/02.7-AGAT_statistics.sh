#!/bin/bash
#SBATCH --job-name=AGAT_stats
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/02.7_AGAT_stats_%j.out
#SBATCH --error=./Logs/02.7_AGAT_stats_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=02:00:00
#SBATCH --mem=16G

set -euo pipefail

BASE="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2"
IN="${BASE}/04-MAKER_output_refinement/filtered.genes.renamed.gff3"
OUTDIR="${BASE}/06-AGAT_statistics"
CONTAINER="/containers/apptainer/agat-1.2.0.sif"

mkdir -p "$OUTDIR" Logs
cd "$OUTDIR"

echo "=== Running AGAT statistics ==="

apptainer exec \
  --bind "$BASE":"$BASE" \
  "$CONTAINER" \
  agat_sp_statistics.pl \
    -i "$IN" \
    -o "${OUTDIR}/annotation.stat"

echo "=== AGAT finished at $(date) ==="
