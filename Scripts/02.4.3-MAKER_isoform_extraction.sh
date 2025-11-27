#!/bin/bash
#SBATCH --job-name=longest_isoforms
#SBATCH --partition=pibu_el8
#SBATCH --time=02:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=1
#SBATCH --output=Logs/02.4.3_longest_isoforms_%j.out
#SBATCH --error=Logs/02.4.3_longest_isoforms_%j.err

# ============================================================
# Extract longest isoform per gene from MAKER protein output
# Input  : hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta
# Output : maker_proteins.longest.fasta (1 isoform per gene)
# ============================================================

set -e

# Move into directory where MAKER refinement output is stored
cd /data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_2/04-MAKER_output_refinement

INPUT="hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta"
LENGTHS="prot_lengths.txt"
LONGEST="longest_isoforms.txt"
OUTPUT="maker_proteins.longest.fasta"

mkdir -p logs

echo "Computing lengths of all protein isoforms..."
awk '
  /^>/ {
    if(seq!=""){print id, length(seq)}
    id=substr($0,2); seq=""
    next
  }
  {seq=seq $0}
  END{print id, length(seq)}
' $INPUT > $LENGTHS

echo "Selecting longest isoform per gene..."
awk '
  {
    split($1, arr, "-")
    gene = arr[1]
    len = $2
    if(len > max[gene]) {
      max[gene] = len
      best[gene] = $1
    }
  }
  END {
    for (g in best) print best[g]
  }
' $LENGTHS > $LONGEST

echo "Extracting FASTA sequences for longest isoforms..."
faSomeRecords $INPUT $LONGEST $OUTPUT

echo "Counting final number of genes:"
grep -c "^>" $OUTPUT

echo "Done. Output written to: $OUTPUT"
