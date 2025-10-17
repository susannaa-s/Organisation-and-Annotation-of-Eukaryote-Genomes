#!/bin/bash
#SBATCH --job-name=TEsorter_LTR
#SBATCH --partition=pibu_el8
#SBATCH --output=./Logs/TEsorter_%j.out
#SBATCH --error=./Logs/TEsorter_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=04:00:00
#SBATCH --mem=16G

# Paths to directories
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation"
RESULTS="${WORKDIR}/Results/01-EDTA_annotation"
LOGS="${WORKDIR}/Logs"
# Ensure log directory exists
mkdir -p "${LOGS}"
cd "${RESULTS}"

# To keep track of progress
echo "[$(date)] Starting TEsorter classification and LTR identity analysis"

# Path to container and R script
TESORTER_CONTAINER="/data/courses/assembly-annotation-course/CDS_annotation/containers/TEsorter_1.3.0.sif"
R_SCRIPT_SOURCE="/data/courses/assembly-annotation-course/CDS_annotation/scripts/02-full_length_LTRs_identity.R"

# Generated inout file from EDTA
LTR_FASTA="hifiasm_p_ctg.fasta.mod.EDTA.raw/LTR/hifiasm_p_ctg.fasta.mod.LTR.raw.fa"

# Step 1 : Run TEsorter classification
if [ -f "${RESULTS}/${LTR_FASTA}" ]; then
    echo "[$(date)] LTR FASTA found: ${LTR_FASTA}"
    echo "[$(date)] Running TEsorter classification..."
    apptainer exec \
      --bind "${RESULTS}" \
      "${TESORTER_CONTAINER}" \
      TEsorter "${LTR_FASTA}" -db rexdb-plant
else
    echo "[$(date)] ERROR: ${LTR_FASTA} not found. Exiting."
    exit 1
fi

# Step 2 : Prepare and run R script for LTR identity analysis
echo "[$(date)] Preparing R analysis..."
cp "${R_SCRIPT_SOURCE}" "${RESULTS}/02-full_length_LTRs_identity.R"

# Replace GFF and classification paths correctly
sed -i "s|genomic.fna.mod.LTR.intact.raw.gff3|${RESULTS}/${LTR_FASTA%raw.fa}intact.raw.gff3|" "${RESULTS}/02-full_length_LTRs_identity.R"
sed -i "s|genomic.fna.mod.LTR.raw.fa.rexdb-plant.cls.tsv|${RESULTS}/hifiasm_p_ctg.fasta.mod.LTR.raw.fa.rexdb-plant.cls.tsv|" "${RESULTS}/02-full_length_LTRs_identity.R"

# Create plot output directory
mkdir -p "${RESULTS}/plots"

echo "[$(date)] Running R script using cluster module..."
# had to load R module since container 
module load R/4.3.2-foss-2021a
Rscript "${RESULTS}/02-full_length_LTRs_identity.R"

echo "[$(date)] TEsorter + LTR identity analysis completed successfully."

# Optional: Clean up R script after execution

rm "${RESULTS}/02-full_length_LTRs_identity.R"