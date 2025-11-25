# =====================================================================
# Visualising TE distribution across the genome (Manual 1, Section 2.2)
# =====================================================================

library(circlize)
library(dplyr)
library(readr)
library(RColorBrewer)

# ---------------------------------------------------------------------
# 1. Input files
# ---------------------------------------------------------------------
gff_file <- "hifiasm_p_ctg.fasta.mod.EDTA.TEanno.gff3"
fasta_file <- "hifiasm_p_ctg.fasta"
fai_file <- paste0(fasta_file, ".fai")
output_file <- "TE_distribution_circlize_FINAL.png"

# ---------------------------------------------------------------------
# 2. Create .fai if missing
# ---------------------------------------------------------------------
if (!file.exists(fai_file)) {
  system(paste("samtools faidx", fasta_file))
}

# ---------------------------------------------------------------------
# 3. Read EDTA GFF3
# ---------------------------------------------------------------------
te_gff <- read_tsv(gff_file, comment = "#", col_names = FALSE, show_col_types = FALSE)
colnames(te_gff) <- c("seqid","source","type","start","end","score","strand","phase","attributes")

# Extract superfamily from attribute field
te_gff <- te_gff %>%
  mutate(superfamily = sub(".*classification=([^;]+).*", "\\1", attributes),
         superfamily = sub(".*/", "", superfamily))

# Keep only true TE features (EDTA uses many feature types)
te_filtered <- te_gff %>%
  filter(type %in% c("transposable_element",
                     "terminal_inverted_repeat_element",
                     "DNA_transposon",
                     "LTR_retrotransposon",
                     "non_LTR_retrotransposon",
                     "repeat_region"))

# ---------------------------------------------------------------------
# 4. Identify the most abundant TE superfamilies
# ---------------------------------------------------------------------
te_summary <- te_filtered %>%
  group_by(superfamily) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n))

# keep top 5 abundant groups
top_superfamilies <- head(te_summary$superfamily, 5)

te_top <- te_filtered %>% filter(superfamily %in% top_superfamilies)

# ---------------------------------------------------------------------
# 5. Build ideogram from top scaffolds
# ---------------------------------------------------------------------
fai <- read_tsv(fai_file,
                col_names = c("seqid","length","x1","x2","x3"),
                show_col_types = FALSE)

ideogram <- fai %>%
  arrange(desc(length)) %>%
  slice(1:10) %>%      # top 10 scaffolds
  mutate(start = 0, end = length) %>%
  select(seqid, start, end)

# Keep TE entries located on selected scaffolds
te_top <- te_top %>%
  semi_join(ideogram, by = "seqid") %>%
  select(seqid, start, end, superfamily)

# ---------------------------------------------------------------------
# 6. Colour palette for TE superfamilies
# ---------------------------------------------------------------------
cols <- setNames(brewer.pal(5, "Set2"), top_superfamilies)

# ---------------------------------------------------------------------
# 7. Plot
# ---------------------------------------------------------------------
png(output_file, width = 2400, height = 2400, res = 300)

circos.clear()
circos.par(start.degree = 90,
           gap.after = 2,
           track.margin = c(0.01, 0.01))

circos.genomicInitialize(ideogram)

# TE density tracks
for (sf in top_superfamilies) {
  data_sf <- te_top[te_top$superfamily == sf, c("seqid","start","end")]
  circos.genomicDensity(
    data_sf,
    col = cols[sf],
    track.height = 0.08,
    window.size = 5e4
  )
}

legend("topright",
       legend = top_superfamilies,
       fill = cols[top_superfamilies],
       bg = "white",
       cex = 1)

dev.off()

message("Final circlize TE distribution plot saved to: ", output_file)

