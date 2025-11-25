#!/usr/bin/env Rscript

# -----------------------------------------------------------
# Local TE dynamics script (no HPC dependencies)
# -----------------------------------------------------------

# --- USER INPUT ------------------------------------------------------

# Path to the parsed RepeatMasker table (.Div.Rname.tab)
tab_file <- "hifiasm_p_ctg.fasta.mod.out.landscape.Div.Rname.tab"

# Folder where you want to save the output
outdir <- "output_folder"

dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

# --- PACKAGES --------------------------------------------------------

library(data.table)
library(reshape2)
library(ggplot2)
library(cowplot)
library(RColorBrewer)

# --- LOAD DATA -------------------------------------------------------

rep_table <- fread(tab_file, header = FALSE, sep = "\t")

colnames(rep_table) <- c("Rname", "Rclass", "Rfam", 1:50)
rep_table <- rep_table[rep_table$Rfam != "unknown", ]
rep_table$fam <- paste(rep_table$Rclass, rep_table$Rfam, sep = "/")

# --- RESHAPE ---------------------------------------------------------

rep_table.m <- melt(rep_table)
rep_table.m <- rep_table.m[rep_table.m$variable != "1", ]

order_vec <- c(
  "LTR/Copia", "LTR/Gypsy",
  "DNA/DTA","DNA/DTC","DNA/DTH","DNA/DTM","DNA/DTT",
  "DNA/Helitron",
  "MITE/DTA","MITE/DTC","MITE/DTH","MITE/DTM"
)

rep_table.m$fam <- factor(rep_table.m$fam, levels = order_vec)

# --- DIVERGENCE / AGE ------------------------------------------------

rep_table.m$distance <- as.numeric(rep_table.m$variable) / 100

sub_rate <- 8.22e-9
rep_table.m$age_mya <- (rep_table.m$distance / (2 * sub_rate)) / 1e6

rep_table.m <- rep_table.m[rep_table.m$fam != "DNA/Helitron", ]
rep_table.m$weight_mbp <- rep_table.m$value / 1e6

# --- PLOTS -----------------------------------------------------------

p_div <- ggplot(rep_table.m, aes(x = distance, weight = weight_mbp, fill = fam)) +
  geom_bar() +
  scale_fill_brewer(palette = "Paired") +
  theme_cowplot() +
  xlab("Sequence divergence from consensus") +
  ylab("Total TE sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, size = 8))

ggsave(file.path(outdir, "TE_divergence_landscape.pdf"),
       p_div, width = 10, height = 5)

p_age <- ggplot(rep_table.m, aes(x = age_mya, weight = weight_mbp, fill = fam)) +
  geom_bar() +
  scale_fill_brewer(palette = "Paired") +
  theme_cowplot() +
  xlab("Estimated insertion age (million years)") +
  ylab("Total TE sequence (Mbp)") +
  theme(axis.text.x = element_text(angle = 90, size = 8))

ggsave(file.path(outdir, "TE_age_landscape.pdf"),
       p_age, width = 10, height = 5)

cat("Plots written to:", outdir, "\n")

