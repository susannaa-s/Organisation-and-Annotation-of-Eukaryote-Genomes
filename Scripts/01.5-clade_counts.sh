#!/bin/bash
#SBATCH --job-name=family_clade_counts
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:10:00
#SBATCH --output=./Logs/01.5_family_clade_counts_%j.out
#SBATCH --error=./Logs/01.5_family_clade_counts_%j.err

WORKDIR=/data/users/sschaerer/Eukaryote_Genome_Annotation_2
TE_SORTER_DIR=$WORKDIR/Results/Part_1/04-Refinement_TEsorter
OUTDIR=$WORKDIR/Results/Part_1/05-Clade_Counts_TEsorter
mkdir -p "$OUTDIR"

echo -e "Superfamily\tClade\tn_families" > $OUTDIR/Copia_Gypsy_family_clade_counts.tsv

# Copia
awk -F'\t' '
  NR>1 {cl[$4]++}
  END {for (c in cl) print "Copia\t" c "\t" cl[c]}
' $TE_SORTER_DIR/Copia/Copia_sequences.fa.rexdb-plant.cls.tsv \
>> $OUTDIR/Copia_Gypsy_family_clade_counts.tsv

# Gypsy
awk -F'\t' '
  NR>1 {cl[$4]++}
  END {for (c in cl) print "Gypsy\t" c "\t" cl[c]}
' $TE_SORTER_DIR/Gypsy/Gypsy_sequences.fa.rexdb-plant.cls.tsv \
>> $OUTDIR/Copia_Gypsy_family_clade_counts.tsv

echo "Done. Output written to:"
echo "$OUTDIR/Copia_Gypsy_family_clade_counts.tsv"



# ----------------------------------------------------------
# Step 5: Generate barplot with base R (no packages needed)
# ----------------------------------------------------------

Rscript - <<'EOF'

# Paths
WORKDIR <- "/data/users/sschaerer/Eukaryote_Genome_Annotation_2"
OUTDIR  <- file.path(WORKDIR, "Results/Part_1/05-Clade_Counts_TEsorter")
TABLE   <- file.path(OUTDIR, "Copia_Gypsy_family_clade_counts.tsv")

df <- read.table(TABLE, header = TRUE, sep = "\t", stringsAsFactors = FALSE)

# Split by superfamily
copia <- df[df$Superfamily == "Copia", ]
gypsy <- df[df$Superfamily == "Gypsy", ]

# Sort by abundance
copia <- copia[order(-copia$n_families), ]
gypsy <- gypsy[order(-gypsy$n_families), ]

# Output file
png(file.path(OUTDIR, "clade_barplot.png"), width = 1800, height = 800, res = 200)

# Layout: 1 row, 2 columns
par(mfrow = c(1,2), mar = c(8,5,4,2))

# ---- Copia ----
barplot(
  copia$n_families,
  names.arg = copia$Clade,
  las = 2, col = "steelblue",
  main = "Copia clade abundance",
  ylab = "Number of TE families"
)

# ---- Gypsy ----
barplot(
  gypsy$n_families,
  names.arg = gypsy$Clade,
  las = 2, col = "darkorange",
  main = "Gypsy clade abundance",
  ylab = "Number of TE families"
)

dev.off()

EOF

echo "Plot saved to: $OUTDIR/clade_barplot.png"
