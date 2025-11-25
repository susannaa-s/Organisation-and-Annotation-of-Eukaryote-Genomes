#!/bin/bash
#SBATCH --job-name=TEsorter_LTR
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/01.2_TEsorter_%j.out
#SBATCH --error=./Logs/01.2_TEsorter_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=04:00:00
#SBATCH --mem=16G

# Directories
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation_2"
EDTA_DIR="${WORKDIR}/Results/Part_1/01-EDTA_annotation"
RESULTS="${WORKDIR}/Results/Part_1/02-TE_sorter"
LOGS="${WORKDIR}/Logs"

TESORTER_CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"
R_SCRIPT_SOURCE="/data/courses/assembly-annotation-course/CDS_annotation/scripts/02-full_length_LTRs_identity.R"

mkdir -p "${RESULTS}" "${LOGS}"

# Correct EDTA output paths (FULL PATHS)
LTR_FASTA="${EDTA_DIR}/hifiasm_p_ctg.fasta.mod.EDTA.raw/hifiasm_p_ctg.fasta.mod.LTR.raw.fa"
INTACT_GFF="${EDTA_DIR}/hifiasm_p_ctg.fasta.mod.EDTA.raw/hifiasm_p_ctg.fasta.mod.LTR.intact.raw.gff3"
CLS_FILE="${RESULTS}/hifiasm_p_ctg.fasta.mod.LTR.raw.fa.rexdb-plant.cls.tsv"

# Check files exist
if [ ! -f "${LTR_FASTA}" ]; then
    echo "LTR FASTA not found: ${LTR_FASTA}"
    exit 1
fi
echo "LTR FASTA found: ${LTR_FASTA}"

# Move into RESULTS so TEsorter writes outputs there
cd "${RESULTS}"

echo "[$(date)] Running TEsorter..."
apptainer exec \
  --bind "${RESULTS}" \
  --bind "${EDTA_DIR}" \
  --bind "${WORKDIR}" \
  "${TESORTER_CONTAINER}" \
  TEsorter "${LTR_FASTA}" -db rexdb-plant

# Step 2: Prepare R script
cp "${R_SCRIPT_SOURCE}" "${RESULTS}/02-full_length_LTRs_identity.R"

# Correct paths inside R script
sed -i "s|genomic.fna.mod.LTR.intact.raw.gff3|${INTACT_GFF}|" "${RESULTS}/02-full_length_LTRs_identity.R"
sed -i "s|genomic.fna.mod.LTR.raw.fa.rexdb-plant.cls.tsv|${CLS_FILE}|" "${RESULTS}/02-full_length_LTRs_identity.R"

mkdir -p "${RESULTS}/plots"

echo "[$(date)] Running R script..."
module load R/4.3.2-foss-2021a
Rscript "${RESULTS}/02-full_length_LTRs_identity.R"

echo "[$(date)] TEsorter + LTR identity analysis completed successfully."

rm "${RESULTS}/02-full_length_LTRs_identity.R"
