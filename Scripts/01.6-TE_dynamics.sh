#!/bin/bash
#SBATCH --job-name=TE_dynamics
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=02:00:00
#SBATCH --output=/data/users/sschaerer/Eukaryote_Genome_Annotation/Logs/01.6_TE_dynamics_%j.out
#SBATCH --error=/data/users/sschaerer/Eukaryote_Genome_Annotation/Logs/01.6_TE_dynamics_%j.err

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
BASE="/data/users/sschaerer/Eukaryote_Genome_Annotation"

GENOME="hifiasm_p_ctg.fasta"
EDTA_OUT="$BASE/Results/Part_1/01-EDTA_annotation/${GENOME}.mod.EDTA.anno"
RM_OUT="$EDTA_OUT/${GENOME}.mod.out"

OUTDIR="$BASE/Results/Part_1/07-TE_dynamics"
mkdir -p "$OUTDIR"
mkdir -p "$BASE/logs"

# ------------------------------------------------------------
# 1. Run parseRM.pl (writes outputs next to RM_OUT)
# ------------------------------------------------------------
module load BioPerl/1.7.8-GCCcore-10.3.0

echo "Running parseRM.pl on $RM_OUT ..."
perl /data/courses/assembly-annotation-course/CDS_annotation/scripts/05-parseRM.pl \
    -i "$RM_OUT" \
    -l 50,1 \
    -v

# The file we need:
TAB_SRC="${RM_OUT}.landscape.Div.Rname.tab"

if [ ! -f "$TAB_SRC" ]; then
  echo "ERROR: Expected file not found: $TAB_SRC"
  exit 1
fi

# Copy to OUTDIR so everything for this step is together
cp "$TAB_SRC" "$OUTDIR/"
TAB_BASENAME=$(basename "$TAB_SRC")
TAB="$OUTDIR/$TAB_BASENAME"

echo "Using parsed table: $TAB"
