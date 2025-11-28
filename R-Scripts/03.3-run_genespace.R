#!/usr/bin/env Rscript

library(GENESPACE)

args <- commandArgs(trailingOnly = TRUE)
wd <- args[1]

cat("Running GENESPACE in:", wd, "\n")

# ------------------------------------------------------------
# Detect genome IDs
# ------------------------------------------------------------
bedDir <- file.path(wd, "bed")
bedFiles <- list.files(bedDir, pattern = "\\.bed$", full.names = TRUE)
genomes <- gsub("\\.bed$", "", basename(bedFiles))

cat("Detected genomes:\n")
print(genomes)

# Reference genome must be explicitly defined
refGenome <- "TAIR10"

# ------------------------------------------------------------
# Initialise GENESPACE
# ------------------------------------------------------------
gpar <- init_genespace(
  wd = wd,
  genomeIDs = genomes,
  path2mcscanx = "/usr/local/bin"
)

# ------------------------------------------------------------
# Run GENESPACE
# ------------------------------------------------------------
out <- run_genespace(gpar, overwrite = TRUE)

saveRDS(gpar, file.path(wd, "gpar.rds"))
saveRDS(out,  file.path(wd, "gs_out.rds"))

cat("GENESPACE core analysis finished.\n")

# ------------------------------------------------------------
# Build PANGENOME MATRIX (the missing part!)
# ------------------------------------------------------------
cat("Building pangenome matrix...\n")

pangenome <- query_pangenes(
  out,
  bed = NULL,
  refGenome = refGenome,
  transform = TRUE
)

saveRDS(pangenome, file.path(wd, "pangenome_matrix.rds"))
cat("Pangenome matrix saved.\n")

# ------------------------------------------------------------
# Riparian plot
# ------------------------------------------------------------
cat("Generating riparian plot...\n")

plot_riparian(
  gsParam = out,
  refGenome = refGenome
)

cat("Riparian plot complete.\n")

# ------------------------------------------------------------
# Pairwise dotplots
# ------------------------------------------------------------
plotDir <- file.path(wd, "dotplots_all")
dir.create(plotDir, showWarnings = FALSE)

for (i in seq_along(genomes)) {
  for (j in seq_along(genomes)) {
    if (i == j) next

    g1 <- genomes[i]
    g2 <- genomes[j]

    pdf(file.path(plotDir, paste0(g1, "_vs_", g2, ".rawHits.pdf")),
        width = 8, height = 8)
    try(plot_rawHits(gpar, out, g1, g2), silent = TRUE)
    dev.off()

    pdf(file.path(plotDir, paste0(g1, "_vs_", g2, ".syntenicHits.pdf")),
        width = 8, height = 8)
    try(plot_syntenicHits(gpar, out, g1, g2), silent = TRUE)
    dev.off()
  }
}

cat("All pairwise dotplots complete.\n")
cat("GENESPACE analysis COMPLETE.\n")
