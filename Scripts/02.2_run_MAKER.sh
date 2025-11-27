#!/bin/bash
#SBATCH --job-name=maker_mpi
#SBATCH --partition=pibu_el8
#SBATCH --time=4-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=50
#SBATCH --mem=250G
#SBATCH --output=Logs/02.2_maker_mpi_%j.out
#SBATCH --error=Logs/02.2_maker_mpi_%j.err

# Directories
COURSEDIR="/data/courses/assembly-annotation-course/CDS_annotation"
SETUPDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_2/01-MAKER_annotation_setup"
WORKDIR="/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_2/02-MAKER_annotation_results"

REPEATMASKER_DIR="$COURSEDIR/softwares/RepeatMasker"

module load AUGUSTUS/3.4.0-foss-2021a
module load OpenMPI/4.1.1-GCC-10.3.0

export PATH="$PATH:$REPEATMASKER_DIR"

mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

cp "$SETUPDIR"/maker_opts.ctl .
cp "$SETUPDIR"/maker_bopts.ctl .
cp "$SETUPDIR"/maker_exe.ctl .
cp "$SETUPDIR"/maker_evm.ctl .

mpiexec --oversubscribe -n 50 apptainer exec \
    --bind $WORKDIR \
    --bind /data/users \
    --bind $SCRATCH:/TMP \
    --bind $COURSEDIR \
    --bind $AUGUSTUS_CONFIG_PATH \
    --bind $REPEATMASKER_DIR \
    $COURSEDIR/containers/MAKER_3.01.03.sif \
    maker -mpi --ignore_nfs_tmp -TMP /TMP \
    maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl
