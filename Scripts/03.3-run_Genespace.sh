#!/bin/bash
#SBATCH --job-name=GENESPACE
#SBATCH --partition=pibu_el8
#SBATCH --output=Logs/03.3-GENESPACE_%j.out
#SBATCH --error=Logs/03.3-GENESPACE_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=20
#SBATCH --time=2-00:00:00
#SBATCH --mem=120G

WORKDIR=/data/users/sschaerer/Eukaryote_Genome_Annotation
INPUTDIR=$WORKDIR/Results/Part_3/02-GENESPACE_inputs
OUTPUTDIR=$WORKDIR/Results/Part_3/03-GENESPACE_results
COURSEDIR=/data/courses/assembly-annotation-course/CDS_annotation
SCRIPT=$WORKDIR/R-Scripts/03.3-run_genespace.R
CONTAINER=$COURSEDIR/containers/genespace_latest.sif

echo "Preparing GENESPACE working directory"

rm -rf $OUTPUTDIR
mkdir -p $OUTPUTDIR/bed
mkdir -p $OUTPUTDIR/peptide

# Copy only the selected species
for sp in MR_0 TAIR10 Est_0 Ice_1 Are_6; do
    cp $INPUTDIR/bed/${sp}.bed      $OUTPUTDIR/bed/
    cp $INPUTDIR/peptide/${sp}.fa   $OUTPUTDIR/peptide/
done

echo "Running GENESPACE"

apptainer exec --cleanenv --no-home \
    --bind $WORKDIR \
    --bind $COURSEDIR \
    $CONTAINER \
    Rscript $SCRIPT $OUTPUTDIR
