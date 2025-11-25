#!/bin/bash
#SBATCH --job-name=prepare_longest
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/02.5_prepare_longest_%j.out
#SBATCH --error=./Logs/02.5_prepare_longest_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:30:00
#SBATCH --mem=4G

set -euo pipefail

IN="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2/04-MAKER_output_refinement"
OUT="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2/05-BUSCO"
mkdir -p "$OUT"

module load SeqKit/2.6.1

extract_longest () {
    local in_fasta=$1
    local out_fasta=$2

    seqkit fx2tab "$in_fasta" \
      | awk -F'\t' '
        {
            split($1, t, "-R")
            gene = t[1]

            if (length($2) > len[gene]) {
                len[gene] = length($2)
                rec[gene] = $0
            }
        }
        END {for (g in rec) print rec[g]}
      ' \
      | seqkit tab2fx > "$out_fasta"
}

extract_longest \
    "${IN}/hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta" \
    "${OUT}/maker_proteins.renamed.longest.fasta"

extract_longest \
    "${IN}/hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta" \
    "${OUT}/maker_transcripts.renamed.longest.fasta"

grep -c ">" "${OUT}/maker_proteins.renamed.longest.fasta"
grep -c ">" "${OUT}/maker_transcripts.renamed.longest.fasta"

echo "Longest isoform FASTAs prepared in: $OUT"
