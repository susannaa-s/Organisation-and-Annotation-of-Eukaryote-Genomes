#!/bin/bash
#SBATCH --job-name=maker_rename
#SBATCH --partition=pibu_el8
#SBATCH --output=Logs/02.4.1_MAKER_rename_%j.out
#SBATCH --error=Logs/02.4.1_MAKER_rename_%j.err
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --mem=8G

set -euo pipefail

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
BASE="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2"
IN="${BASE}/03-MAKER_output_prep"
OUT="${BASE}/04-MAKER_output_refinement"

COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
MAKERBIN="${COURSEDIR}/softwares/Maker_v3.01.03/src/bin"

PREFIX="ATH"   # choose your 3–4 letter ID prefix

mkdir -p "$OUT"
cd "$OUT"

echo "[INFO] Copying MAKER outputs"

cp ${IN}/hifiasm_p_ctg.all.maker.noseq.gff \
   hifiasm_p_ctg.all.maker.noseq.renamed.gff

cp ${IN}/hifiasm_p_ctg.all.maker.transcripts.fasta \
   hifiasm_p_ctg.all.maker.transcripts.renamed.fasta

cp ${IN}/hifiasm_p_ctg.all.maker.proteins.fasta \
   hifiasm_p_ctg.all.maker.proteins.renamed.fasta


# ------------------------------------------------------------
# Step 6.1 – Generate ID map and rename GFF + FASTAs
# ------------------------------------------------------------
echo "[INFO] Generating ID map with prefix: $PREFIX"

$MAKERBIN/maker_map_ids \
    --prefix $PREFIX \
    --justify 7 \
    hifiasm_p_ctg.all.maker.noseq.renamed.gff \
    > id.map

echo "[INFO] Applying ID map to GFF"
$MAKERBIN/map_gff_ids id.map hifiasm_p_ctg.all.maker.noseq.renamed.gff

echo "[INFO] Applying ID map to protein FASTA"
$MAKERBIN/map_fasta_ids id.map hifiasm_p_ctg.all.maker.proteins.renamed.fasta

echo "[INFO] Applying ID map to transcript FASTA"
$MAKERBIN/map_fasta_ids id.map hifiasm_p_ctg.all.maker.transcripts.renamed.fasta


echo "[DONE] Renaming complete."
echo "Produced:"
echo "  - hifiasm_p_ctg.all.maker.noseq.renamed.gff"
echo "  - hifiasm_p_ctg.all.maker.proteins.renamed.fasta"
echo "  - hifiasm_p_ctg.all.maker.transcripts.renamed.fasta"
echo "These files are now ready for Step 6.2 (InterProScan)."
