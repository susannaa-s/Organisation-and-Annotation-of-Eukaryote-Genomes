#!/bin/bash
#SBATCH --job-name=BUSCO_QC
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/02.6_BUSCO_QC_%j.out
#SBATCH --error=./Logs/02.6_BUSCO_QC_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=24:00:00
#SBATCH --mem=100G

set -euo pipefail

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
BASE="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2"
IN="${BASE}/05-BUSCO"
OUT="${BASE}/05-BUSCO"
mkdir -p "$OUT" Logs

PROT="${IN}/maker_proteins.renamed.longest.fasta"
TRAN="${IN}/maker_transcripts.renamed.longest.fasta"

LINEAGE="brassicales_odb10"

# ------------------------------------------------------------
# Load BUSCO
# ------------------------------------------------------------
module load BUSCO/5.4.2-foss-2021a

echo "=== BUSCO QC started: $(date) ==="
echo "Using lineage: $LINEAGE"
echo "Protein file: $PROT"
echo "Transcript file: $TRAN"
echo "Output: $OUT"

cd "$OUT"

# ------------------------------------------------------------
# BUSCO on proteins
# ------------------------------------------------------------
echo "Running BUSCO on proteins..."
busco \
  -i "$PROT" \
  -l "$LINEAGE" \
  -o "BUSCO_protein_${LINEAGE}" \
  -m protein \
  --cpu ${SLURM_CPUS_PER_TASK}

# ------------------------------------------------------------
# BUSCO on transcripts
# ------------------------------------------------------------
echo "Running BUSCO on transcripts..."
busco \
  -i "$TRAN" \
  -l "$LINEAGE" \
  -o "BUSCO_transcript_${LINEAGE}" \
  -m transcriptome \
  --cpu ${SLURM_CPUS_PER_TASK}

# ------------------------------------------------------------
# Summaries
# ------------------------------------------------------------
echo "Protein summary:"
cat BUSCO_protein_${LINEAGE}/short_summary*.txt

echo "Transcript summary:"
cat BUSCO_transcript_${LINEAGE}/short_summary*.txt

cat BUSCO_protein_${LINEAGE}/short_summary*.txt \
    BUSCO_transcript_${LINEAGE}/short_summary*.txt \
    > BUSCO_summary_${LINEAGE}.txt

echo "=== BUSCO QC finished: $(date) ==="
echo "Summary written to BUSCO_summary_${LINEAGE}.txt"
