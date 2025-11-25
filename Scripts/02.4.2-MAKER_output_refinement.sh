#!/bin/bash
#SBATCH --job-name=maker_refinement_full
#SBATCH --partition=pibu_el8
#SBATCH --output=Logs/02.4.2_MAKER_refinement_full_%j.out
#SBATCH --error=Logs/02.4.2_MAKER_refinement_full_%j.err
#SBATCH --cpus-per-task=8
#SBATCH --time=36:00:00
#SBATCH --mem=120G

set -euo pipefail

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
BASE="/data/users/sschaerer/Eukaryote_Genome_Annotation_2/Results/Part_2"
WORKDIR="${BASE}/04-MAKER_output_refinement"
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

CONTAINER="${COURSEDIR}/containers/interproscan_latest.sif"
DATA_DIR="${COURSEDIR}/data/interproscan-5.70-102.0/data"
MAKERBIN="${COURSEDIR}/softwares/Maker_v3.01.03/src/bin"

cd "$WORKDIR"

# Input files (already renamed)
PROTEIN="hifiasm_p_ctg.all.maker.proteins.renamed.fasta"
TRANSCRIPT="hifiasm_p_ctg.all.maker.transcripts.renamed.fasta"
GFF="hifiasm_p_ctg.all.maker.noseq.renamed.gff"


echo "===== STEP 6.2: Running InterProScan (Pfam) ====="
apptainer exec \
  --bind ${DATA_DIR}:/opt/interproscan/data \
  --bind $WORKDIR \
  --bind $COURSEDIR \
  --bind $SCRATCH:/temp \
  $CONTAINER \
  /opt/interproscan/interproscan.sh \
  -i $PROTEIN \
  -appl pfam \
  --disable-precalc \
  -f TSV \
  --goterms --iprlookup \
  --seqtype p \
  -cpu ${SLURM_CPUS_PER_TASK:-8} \
  -o output.iprscan


echo "===== STEP 6.3: Updating GFF with InterProScan domains ====="
GFF_IPR="${GFF%.gff}.iprscan.gff"
$MAKERBIN/ipr_update_gff $GFF output.iprscan > $GFF_IPR


echo "===== STEP 6.4: Computing AED values ====="
perl $MAKERBIN/AED_cdf_generator.pl -b 0.025 \
  $GFF > ${GFF%.gff}.AED.txt


echo "===== STEP 6.5: Quality filtering (AED < 1 OR Pfam) ====="
GFF_QUAL="${GFF%.gff}_iprscan_quality_filtered.gff"
perl $MAKERBIN/quality_filter.pl \
  -s $GFF_IPR \
  > $GFF_QUAL


echo "===== STEP 6.6: Keeping only gene features ====="
grep -P \
  $'\tgene\t|\tmRNA\t|\texon\t|\tCDS\t|\tfive_prime_UTR\t|\tthree_prime_UTR\t' \
  $GFF_QUAL > filtered.genes.renamed.gff3


echo "===== STEP 6.7: Extracting mRNA IDs ====="
grep -P $'\tmRNA\t' filtered.genes.renamed.gff3 \
  | awk '{print $9}' \
  | cut -d ';' -f1 \
  | sed 's/ID=//g' \
  > list.txt


echo "===== Subsetting FASTA files ====="
module load seqtk/1.3-foss-2021a

seqtk subseq $TRANSCRIPT list.txt \
  > hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta

seqtk subseq $PROTEIN list.txt \
  > hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta


echo "===== FINAL COUNTS ====="
echo "Proteins:"
grep -c ">" hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta
echo "Transcripts:"
grep -c ">" hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta


echo "===== DONE ====="
echo "Final refined files:"
echo "  filtered.genes.renamed.gff3"
echo "  hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta"
echo "  hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta"
