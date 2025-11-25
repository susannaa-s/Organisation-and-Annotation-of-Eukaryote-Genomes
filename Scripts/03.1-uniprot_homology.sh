#!/bin/bash
#SBATCH --job-name=uniprot_homology
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=10
#SBATCH --mem=40G
#SBATCH --time=1-00:00:00
#SBATCH --output=Logs/03.1_uniprot_%j.out
#SBATCH --error=Logs/03.1_uniprot_%j.err

# ================================================================
# Sequence homology search against UniProt + TAIR10 (Manual 3)
# Using LONGEST ISOFORM proteins
# ================================================================

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# ---- INPUTS FROM PART 2 (refined outputs) ----
INPUTDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2/04-MAKER_output_refinement"

# CHANGED: use the longest isoform FASTA (40275 proteins)
QUERY="${INPUTDIR}/maker_proteins.longest.fasta"

# This GFF still contains all gene models and is correct
GFF_IN="${INPUTDIR}/filtered.genes.renamed.gff3"

# ---- OUTPUTS TO PART 3 ----
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_3/01-uniprot_homology"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

MAKERBIN="$COURSEDIR/softwares/Maker_v3.01.03/src/bin"

# ---- reference databases ----
UNIPROT_FA="$COURSEDIR/data/uniprot/uniprot_viridiplantae_reviewed.fa"
TAIR10_FA="$COURSEDIR/data/TAIR10_pep_20110103_representative_gene_model"

OUT_UNIPROT="$WORKDIR/blastp_uniprot.out"
OUT_TAIR="$WORKDIR/blastp_tair10.out"

module load BLAST+/2.15.0-gompi-2021a

# ================================================================
# Step 1 — UniProt blastp
# ================================================================
echo "Running blastp against UniProt..."

blastp \
    -query $QUERY \
    -db $UNIPROT_FA \
    -num_threads 10 \
    -outfmt 6 \
    -evalue 1e-5 \
    -max_target_seqs 10 \
    -out $OUT_UNIPROT

echo "Extracting best UniProt hit per protein..."
sort -k1,1 -k12,12g $OUT_UNIPROT | sort -u -k1,1 --merge > ${OUT_UNIPROT}.besthits

# ================================================================
# Step 2 — Map UniProt annotations
# ================================================================
echo "Mapping UniProt annotations onto FASTA..."
$MAKERBIN/maker_functional_fasta \
    $UNIPROT_FA \
    ${OUT_UNIPROT}.besthits \
    $QUERY \
    > ${WORKDIR}/maker_proteins.longest.fasta.Uniprot    # CHANGED (naming)

echo "Mapping UniProt annotations onto GFF..."
$MAKERBIN/maker_functional_gff \
    $UNIPROT_FA \
    ${OUT_UNIPROT}.besthits \
    $GFF_IN \
    > ${WORKDIR}/filtered.genes.renamed.gff3.Uniprot.gff3

# ================================================================
# Step 3 — TAIR10 blastp
# ================================================================
echo "Running blastp against TAIR10..."

blastp \
    -query $QUERY \
    -db $TAIR10_FA \
    -num_threads 10 \
    -outfmt 6 \
    -evalue 1e-5 \
    -max_target_seqs 10 \
    -out $OUT_TAIR

echo "Extracting best TAIR10 hit..."
sort -k1,1 -k12,12g $OUT_TAIR | sort -u -k1,1 --merge > ${OUT_TAIR}.besthits

echo "Done. Outputs in:"
echo "$WORKDIR"
