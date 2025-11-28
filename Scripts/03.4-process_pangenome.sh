#!/bin/bash
#SBATCH --job-name=ProcessPangenome
#SBATCH --partition=pibu_el8
#SBATCH --output=Logs/03.4-process_pangenome_%j.out
#SBATCH --error=Logs/03.4-process_pangenome_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

WORKDIR=/data/users/sschaerer/Eukaryote_Genome_Annotation
RSCRIPT=$WORKDIR/R-Scripts/03.4-process_pangenome.R

echo "Loading R modules..."
module add R/4.3.2-foss-2021a
module add R-bundle-CRAN/2023.11-foss-2021a
module add R-bundle-Bioconductor/3.18-foss-2021a-R-4.3.2

echo "Running pangenome processing..."
Rscript $RSCRIPT

echo "Done."
