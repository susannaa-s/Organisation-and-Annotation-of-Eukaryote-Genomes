#!/bin/bash
#SBATCH --job-name=maker_output_prep
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --output=Logs/02.3_output_prep_%j.out
#SBATCH --error=Logs/02.3_output_prep_%j.err

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"

# MAKER results from the previous step
MAKER_RESULTS="/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_2/02-MAKER_annotation_results"
GENOME="hifiasm_p_ctg"

# Output directory for merged files
OUTDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_2/03-MAKER_output_prep"
mkdir -p "$OUTDIR"

# Path to datastore
DATASTORE="${MAKER_RESULTS}/${GENOME}.maker.output/${GENOME}_master_datastore_index.log"

# MAKER binaries (inside course directory)
MAKERBIN="${COURSEDIR}/softwares/Maker_v3.01.03/src/bin"

cd "$OUTDIR"

echo "Merging MAKER GFF files ..."
$MAKERBIN/gff3_merge \
    -s \
    -d "$DATASTORE" \
    > ${GENOME}.all.maker.gff

echo "Merging MAKER GFF (noseq) ..."
$MAKERBIN/gff3_merge \
    -n -s \
    -d "$DATASTORE" \
    > ${GENOME}.all.maker.noseq.gff

echo "Merging MAKER FASTA (proteins + transcripts) ..."
$MAKERBIN/fasta_merge \
    -d "$DATASTORE" \
    -o ${GENOME}

echo "Done."
