#!/usr/bin/env Rscript

library(tidyverse)
library(readr)

# -----------------
# 0) Inputs
# -----------------

wd <- "/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_3/03-GENESPACE_results"
focal_genome <- "MR_0"

# NEW: output directory
outdir <- "/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_3/04-process_pangenome"
dir.create(outdir, showWarnings = FALSE, recursive = TRUE)

pangenome <- readRDS(file.path(wd, "pangenome_matrix.rds"))

# genome columns produced by query_pangenes()
genome_cols <- names(pangenome)[sapply(pangenome, is.list)]

# convert to tibble for tidyverse operations
pg <- as_tibble(pangenome)

# -----------------
# CLEAN-UP: remove out-of-synteny genes (*)
# -----------------

clean_gene_list <- function(v) {
  if (is.null(v) || length(v) == 0) return(character(0))
  v <- as.character(v)
  v <- v[!is.na(v)]
  v <- trimws(v)
  v <- v[!grepl("\\*$", v)]
  unique(v)
}

pg <- pg %>%
  mutate(across(all_of(genome_cols), ~ lapply(.x, clean_gene_list)))

pg <- pg %>%
  rowwise() %>%
  filter(sum(sapply(c_across(all_of(genome_cols)), length)) > 0) %>%
  ungroup()

# -----------------
# 1) Presence/absence matrix
# -----------------

presence_tbl <- pg %>%
  transmute(
    pgID,
    across(all_of(genome_cols), ~ lengths(.x) > 0, .names = "{.col}")
  )

# -----------------
# 2) Orthogroup category flags
# -----------------

n_genomes <- length(genome_cols)

pg_flags <- presence_tbl %>%
  mutate(
    n_present = select(., all_of(genome_cols)) %>% rowSums(),
    is_core_all = n_present == n_genomes,
    is_accessory = n_present < n_genomes,
    present_in_focal = .data[[focal_genome]],
    focal_specific = (present_in_focal & n_present == 1),
    lost_in_focal = (!present_in_focal & n_present > 0),
    lost_core_without_focal = (!present_in_focal & n_present == (n_genomes - 1)),
    lost_vs_TAIR10 = (!present_in_focal) & .data[["TAIR10"]],
    category = case_when(
      is_core_all ~ "core",
      n_present == 1 ~ "species_specific",
      TRUE ~ "accessory"
    )
  )

# -----------------
# 3) Gene counts per OG × genome
# -----------------

count_genes <- function(gene_list) {
  if (is.null(gene_list) || length(gene_list) == 0) return(0)
  length(unique(gene_list))
}

gene_counts_matrix <- pg %>%
  select(pgID, all_of(genome_cols)) %>%
  mutate(across(all_of(genome_cols), ~ sapply(.x, count_genes)))

# -----------------
# 4) Gene counts per genome and category
# -----------------

gene_counts_w_cat <- pg_flags %>%
  select(pgID, category) %>%
  left_join(gene_counts_matrix, by = "pgID")

gene_by_cat <- gene_counts_w_cat %>%
  pivot_longer(cols = all_of(genome_cols), names_to = "genome", values_to = "gene_count") %>%
  group_by(genome, category) %>%
  summarise(gene_count = sum(gene_count), .groups = "drop")

gene_totals <- gene_by_cat %>%
  group_by(genome) %>%
  summarise(gene_total = sum(gene_count), .groups = "drop")

gene_counts_per_genome <- gene_by_cat %>%
  pivot_wider(names_from = category, values_from = gene_count, values_fill = 0) %>%
  rename(
    gene_core = core,
    gene_accessory = accessory,
    gene_specific = species_specific
  ) %>%
  left_join(gene_totals, by = "genome") %>%
  mutate(
    percent_core = round(100 * gene_core / pmax(gene_total, 1), 2),
    percent_specific = round(100 * gene_specific / pmax(gene_total, 1), 2)
  )

# -----------------
# 5) Frequency plot
# -----------------

og_freq <- pg_flags %>%
  count(n_present, name = "count") %>%
  mutate(type = "Orthogroups")

all_genes_with_presence <- pg %>%
  select(pgID, all_of(genome_cols)) %>%
  pivot_longer(cols = all_of(genome_cols),
               names_to = "genome", values_to = "genes_list") %>%
  filter(!sapply(genes_list, is.null) & sapply(genes_list, length) > 0) %>%
  unnest_longer(genes_list) %>%
  rename(gene = genes_list) %>%
  filter(!is.na(gene)) %>%
  mutate(gene = as.character(gene)) %>%
  distinct(pgID, genome, gene) %>%
  left_join(select(pg_flags, pgID, n_present), by = "pgID")

gene_freq <- all_genes_with_presence %>%
  distinct(pgID, gene, n_present) %>%
  count(n_present, name = "count") %>%
  mutate(type = "Genes")

freq_data <- bind_rows(og_freq, gene_freq)

# plot
p <- ggplot(freq_data, aes(x = n_present, y = count, fill = type)) +
  geom_col(position = "dodge", alpha = 0.8, width = 0.7) +
  scale_x_continuous(breaks = 1:n_genomes) +
  scale_y_continuous(labels = scales::comma) +
  scale_fill_manual(values = c("Genes" = "#0072B2", "Orthogroups" = "#D55E00")) +
  labs(
    x = "Number of genomes",
    y = "Count",
    fill = NULL,
    title = "Pangenome composition: distribution across genomes",
    subtitle = paste("Total genomes:", n_genomes)
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    panel.grid.minor = element_blank()
  )

ggsave(file.path(outdir, "pangenome_frequency_plot.pdf"), width = 10, height = 6)

# -----------------
# Save output tables
# -----------------

write_csv(presence_tbl, file.path(outdir, "presence_absence_table.csv"))
write_csv(pg_flags, file.path(outdir, "orthogroup_flags.csv"))
write_csv(gene_counts_matrix, file.path(outdir, "gene_counts_matrix.csv"))
write_csv(gene_counts_per_genome, file.path(outdir, "gene_counts_per_genome.csv"))
write_csv(freq_data, file.path(outdir, "frequency_raw_counts.csv"))

freq_summary <- freq_data %>%
  pivot_wider(names_from = type, values_from = count, values_fill = 0) %>%
  mutate(
    label = case_when(
      n_present == n_genomes ~ "Core (all genomes)",
      n_present == 1 ~ "Species-specific (1 genome)",
      TRUE ~ paste0("Shared (", n_present, " genomes)")
    )
  ) %>%
  arrange(desc(n_present)) %>%
  select(n_present, label, Orthogroups, Genes)

write_csv(freq_summary, file.path(outdir, "frequency_summary_table.csv"))

cat("Processing complete. Results saved to:\n")
cat(outdir, "\n")
