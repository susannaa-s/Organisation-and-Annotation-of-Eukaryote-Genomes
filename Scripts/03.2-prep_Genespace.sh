#!/bin/bash
#SBATCH --job-name=Prepare_GENESPACE_inputs
#SBATCH --partition=pibu_el8
#SBATCH --output=Logs/03.2-Prepare_GENESPACE_inputs_%j.out
#SBATCH --error=Logs/03.2-Prepare_GENESPACE_inputs_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=2
#SBATCH --mem=4G

# ============================================================
# Step 1 – Prepare BED and peptide FASTA files for GENESPACE
# ============================================================

WORKDIR=/data/users/sschaerer/Eukaryote_Genome_Annotation_2
RESULTSDIR=$WORKDIR/Results/Part_3/02-GENESPACE_inputs

REFINEDIR=$WORKDIR/Results/Part_3/01-uniprot_homology
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
LOGDIR=$WORKDIR/Logs

mkdir -p $RESULTSDIR/bed $RESULTSDIR/peptide $LOGDIR

echo "=============================================="
echo "Preparing MR_0, TAIR10 and selected Lian_et_al files..."
echo "Keeping only: Est_0, Ice_1, Are_6"
echo "=============================================="

# ============================================================
# NORMALISE NAME FUNCTION
# ============================================================
normalize_name () {
    echo "$1" | sed 's/-/_/g'
}

# ------------------------------------------------------------
# 1. MR_0 BED file
# ------------------------------------------------------------
echo "[1/5] Creating MR_0 BED..."
GFF=${REFINEDIR}/filtered.genes.renamed.gff3.Uniprot.gff3
BED=${RESULTSDIR}/bed/MR_0.bed

grep -P "\tgene\t" "$GFF" > ${RESULTSDIR}/temp_genes.gff3

awk 'BEGIN{OFS="\t"} {
    split($9,a,";");
    split(a[1],b,"=");
    print $1, $4-1, $5, b[2]
}' ${RESULTSDIR}/temp_genes.gff3 > "$BED"

rm ${RESULTSDIR}/temp_genes.gff3

# ------------------------------------------------------------
# 1b. Filter MR_0 to main nuclear contigs
# ------------------------------------------------------------
echo "[1b] Filtering MR_0 contigs..."

cat > ${RESULTSDIR}/MR0.keep_contigs.txt <<EOF
ptg000001l
ptg000002l
ptg000003l
ptg000004l
ptg000005l
ptg000006l
ptg000007l
ptg000009l
ptg000010l
ptg000011l
ptg000014l
ptg000016l
EOF

grep -F -f ${RESULTSDIR}/MR0.keep_contigs.txt $BED \
    > ${RESULTSDIR}/bed/MR_0.filtered.bed

mv ${RESULTSDIR}/bed/MR_0.filtered.bed $RESULTSDIR/bed/MR_0.bed

# ------------------------------------------------------------
# 2. MR_0 peptide FASTA
# ------------------------------------------------------------
echo "[2/5] Preparing MR_0 peptides..."

cp ${REFINEDIR}/maker_proteins.longest.fasta.Uniprot \
   ${RESULTSDIR}/peptide/MR_0.fa

sed -i -E 's/^>([A-Za-z0-9]+).*/>\1/' ${RESULTSDIR}/peptide/MR_0.fa

cut -f4 ${RESULTSDIR}/bed/MR_0.bed > ${RESULTSDIR}/MR0.keep_genes.txt

grep -F -A1 -f ${RESULTSDIR}/MR0.keep_genes.txt \
    ${RESULTSDIR}/peptide/MR_0.fa \
    | sed '/^--$/d' \
    > ${RESULTSDIR}/peptide/MR_0.filtered.fa

mv ${RESULTSDIR}/peptide/MR_0.filtered.fa ${RESULTSDIR}/peptide/MR_0.fa

# ------------------------------------------------------------
# 3. TAIR10 reference files
# ------------------------------------------------------------
echo "[3/5] Copying TAIR10 files..."

cp $COURSEDIR/data/TAIR10.bed $RESULTSDIR/bed/
cp $COURSEDIR/data/TAIR10.fa  $RESULTSDIR/peptide/

# ------------------------------------------------------------
# 4. Selected Lian_et_al GFF → BED (Est_0, Ice_1, Are_6)
# ------------------------------------------------------------
echo "[4/5] Converting Lian_et_al GFF for Est_0, Ice_1, Are_6..."

KEEP=("Est_0" "Ice_1" "Are_6")

for gff in $COURSEDIR/data/Lian_et_al/gene_gff/selected/*.gff; do
    base=$(basename "$gff")
    rawname=${base%.EVM.v3.5.ann.protein_coding_genes.gff}
    name=$(normalize_name "$rawname")

    # keep only selected species
    if [[ ! " ${KEEP[@]} " =~ " ${name} " ]]; then
        continue
    fi

    echo "  -> $name"

    grep -P "\tgene\t" "$gff" | \
    awk 'BEGIN{OFS="\t"} {
        split($9,a,";");
        split(a[1],b,"=");
        gene=b[2];
        sub(/\..*/,"",gene);
        print $1, $4-1, $5, gene
    }' > ${RESULTSDIR}/bed/${name}.bed
done

# ------------------------------------------------------------
# 5. Selected Lian_et_al peptides
# ------------------------------------------------------------
echo "[5/5] Preparing peptides for Est_0, Ice_1, Are_6..."

for faa in $COURSEDIR/data/Lian_et_al/protein/selected/*.protein.faa; do
    base=$(basename "$faa")
    rawname=${base%.protein.faa}
    name=$(normalize_name "$rawname")

    if [[ ! " ${KEEP[@]} " =~ " ${name} " ]]; then
        continue
    fi

    outfa=${RESULTSDIR}/peptide/${name}.fa
    cp "$faa" "$outfa"
    sed -i -E 's/^>([^ .]+).*/>\1/' "$outfa"
done

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
echo
echo "BED files prepared:"
ls -lh ${RESULTSDIR}/bed
echo
echo "Peptide FASTA files prepared:"
ls -lh ${RESULTSDIR}/peptide
echo
echo "Done – GENESPACE inputs ready."
