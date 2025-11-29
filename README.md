# README 

This document provides the full workflow used to analyse the Arabidopsis thaliana MR-0 accession.
All scientific interpretation, figures, and discussion are kept in a separate document:
- `Eukaryote_Genome_Annotation/RESULTS.md``

All commands assume execution from the project root directory.

## Part 1. Transposable Element Annotation

This section documents the full workflow used to identify, classify, and explore transposable elements in the genome assembly, following the procedures outlined in Manual 1 (Transposable Element Annotation). 

It is split into four main parts : 

### 1.1 Running EDTA to generate a genome-wide TE annotation

EDTA (version 2.2) was used to annotate transposable elements in the assembly
- `/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif`

Along with the following  CDS file to avoid miss-classification of TEs 
- `/data/courses/assembly-annotation course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_up`

This is done by first creating the directory to store the results : 

```
mkdir -p Results/Part1/01-EDTA_annotation
```

And running the corresponding script : 
```
sbatch Scripts/01-run_EDTA.sh
```

The script runs EDTA through the Apptainer container with the following key options:

- `--species others`               : TE classification does not rely on species-specific presets.
- `--step all`                           : Runs the entire pipeline in one pass.
- `--sensitive 1`                     : Enables more sensitive structural searches, useful for compact genomes.
- `--cds <TAIR10 CDS file>`  : Prevents coding genes from being misclassified as repeats.
- `--anno 1`                               : Generates genome-wide TE annotations in GFF3 format.
- `--threads 20`                       : Matches the allocated SLURM CPU resources.
- `--force 1`                             : Allows EDTA to overwrite previous partial output if present.

The following files are created : 

- `*.mod.EDTA.TElib.fa`        : non-redundant TE library
- `*.mod.EDTA.TEanno.gff3`  : genome-wide TE annotation
- `*.mod.EDTA.intact.gff3`  : intact LTR-RTs only
- `*.mod.EDTA.TEanno.sum`    : summary of TE content by superfamily

### 1.2 Full-length LTR-RT clade classification and identity plot

Refining the classification of structurally intact LTR retrotransposons and visualising their percent identity across Copia and Gypsy clades. This also serves as an indicator of insertion age. 
TEsorter is used to assign clades based on protein domain homology, and an R script generates faceted histograms showing the identity distribution within each clade.

**Workflow**

1. Extract full-length LTR-RTs from EDTA output (`*.LTR.raw.fa` and `*.LTR.intact.raw.gff3`).
2. Classify LTR sequences into clades using TEsorter (`rexdb-plant` database).
3. Merge EDTA identities with TEsorter clade calls.
4. Generate the clade-level Copia and Gypsy identity plot.
    

The result were produced with the following command : 

```
sbatch ./Scripts/02-run_TEsorter_LTR.sh
```

**Output**

The final figures are written to:

```
Results/Part_1/02-TE_sorter/plots/01_LTR_Copia_Gypsy_cladelevel.png
```

A white-background version was created for cleaner presentation using ImageMagick:

```
convert 01_LTR_Copia_Gypsy_cladelevel.png \
    -background white \
    -alpha remove \
    -alpha off \
    01_LTR_Copia_Gypsy_cladelevel_white.png
```


Here is a **short, clean, R-Studio–friendly README subsection** you can paste directly into your project README under **2.2 Visualising TE Annotations**.  
No bold, no unnecessary wording, just concise documentation that fits your GitHub structure and the manual’s expectations.

### 1.3 Visualising TE Annotations (circlize)

To explore the spatial distribution of transposable elements across the genome, I generated a circos-style TE density plot using the R package circlize. 
- based on the EDTA whole-genome annotation file `hifiasm_p_ctg.fasta.mod.EDTA.TEanno.gff3` and
- scaffold lengths obtained from the corresponding `.fai` index of the assembly.

The script was run locally in RStudio and follows the steps required by the manual:

1. parsing the EDTA GFF3 and extracting TE superfamily information
2. identifying the most abundant TE superfamilies
3. building a custom ideogram using the ten longest scaffolds as pseudo-chromosomes
4. computing genomic TE density for each selected superfamily
5. drawing a circos plot with separate tracks for each category
    
To perform this step, the following files were  downloaded to a local machine and stored in the same directory : 

- `/data/users/sschaerer/Eukaryote_Genome_Annotation/Data/hifiasm_p_ctg.fasta.fai`

- `/data/users/sschaerer/Eukaryote_Genome_Annotation/Results/Part_1/01-EDTA_annotation/hifiasm_p_ctg.fasta.mod.EDTA.TEanno.gff3`

- `/data/users/sschaerer/Eukaryote_Genome_Annotation/R-Scripts/01.3-Cirlize.R`

The output file is then manually saved as:

- `/data/users/sschaerer/Eukaryote_Genome_Annotation/Graphs/01.3-TE_distribution_circlize_FINAL.png`


### 1.4 Step 2: Run TEsorter

This step refines the TE annotation provided by EDTA by classifying Copia and Gypsy LTR retrotransposons into evolutionary clades. TEsorter (rexdb-plant database) performs domain-based homology classification on TE families extracted from the EDTA TE library. This allows a more detailed characterisation of LTR-RT diversity beyond the superfamily level.

Clade-level classification was carried out separately for Copia and Gypsy families, as these two LTR-RT lineages have distinct protein domain architectures and are processed independently by TEsorter.

Workflow

1. Extract Copia and Gypsy sequences from the EDTA TE library (`*.mod.EDTA.TElib.fa`).
2. Run TEsorter with the rexdb-plant database on each superfamily.
3. Aggregate clade assignments for all identified Copia and Gypsy families.
4. Summarise the number of families per clade.
5. Generate a barplot showing clade abundances (base R).

The analysis was performed on the cluster using:

```
sbatch Scripts/02-run_TEsorter_Refinement.sh 

sbatch Scripts/01.5_family_clade_counts.sh
```

The second script computes clade counts and produces a simple barplot using base R to avoid package compatibility issues on the cluster.


Here is a **clean continuation** of your README in the same format, style, and level of detail.  
Concise, accurate, and consistent with the previous sections you showed.

Paste directly after section **1.5**.

### 1.6 Generating TE divergence tables with parseRM.pl (RepeatMasker landscape preparation)

To estimate TE insertion ages and visualise genome-wide TE dynamics, it is necessary to transform the raw RepeatMasker output produced by EDTA into divergence tables. These tables contain, for each TE family, the proportion of the genome assigned to different bins of sequence divergence from their consensus sequence.

The parsing step was performed on the cluster using the script:

```
sbatch Scripts/01.6-TE_dynamics.sh
```

This script executes the RepeatMasker parser `parseRM.pl` with the recommended parameters from Manual 1:
- input:  
    `Results/Part_1/01-EDTA_annotation/hifiasm_p_ctg.fasta.mod.out`
- binning scheme: `max_bin = 50`, `bin_len = 1`
- output:  
    divergence tables grouped by Rname, Rclass, and Rfam
    

The parser produces the following files in the EDTA annotation directory:

- `*.landscape.Div.Rname.tab`
- `*.landscape.Div.Rclass.tab`
- `*.landscape.Div.Rfam.tab`
    

For the downstream TE dynamics analysis, only the Rname-based table is required.  
A copy of the relevant file was placed into:

```
Results/Part_1/07-TE_dynamics/hifiasm_p_ctg.fasta.mod.out.landscape.Div.Rname.tab
```

### 1.7 Estimating TE insertion ages and generating TE dynamics plots

Insertion age estimation and TE dynamics visualisation were performed locally in RStudio due to package version constraints on the cluster. The analysis follows the workflow outlined in Manual 1:

1. Load the parsed RepeatMasker divergence table (`Div.Rname.tab`).
2. Convert percent divergence into a continuous divergence metric.
3. Calculate TE insertion ages using the Brassicaceae substitution rate  
    (8.22 × 10⁻⁹ substitutions per site per year).
4. Aggregate TE sequence abundance (in Mbp) across divergence bins.
5. Visualise TE dynamics by superfamily.
    

The R script was adjusted used on local Rstudio where the resulting file from the previous section was stored in the same directory. The script is stored under : 

```
R-Scripts/01.7_TE_dynamics.R
```

This script generates two landscape plots:

- TE_divergence_landscape.pdf 
    Displays the total TE sequence (Mbp) per divergence bin.
    
- TE_age_landscape.pdf 
    Converts divergence into approximate insertion age (million years).
    

Both plots were manually saved to:
```
/Graphs
```
and converted into .png files to be displayed in `RESULTS.md`

## Part 2: Annotation of Genes with the MAKER Pipeline

### 2.1 Preparing the MAKER annotation environment

All MAKER work was carried out in:

```
Results/Part_2/01-MAKER_annotation
```

The MAKER control files (`maker_opts.ctl`, `maker_bopts.ctl`, `maker_evm.ctl`, `maker_exe.ctl`) were generated using:
```
sbatch Scripts/02.1_setup_MAKER.sh
```

This script initialises the directory, loads the MAKER container, detects Apptainer/Singularity, and runs `maker -CTL`.

The main configuration file (`maker_opts.ctl`) was then edited according to Manual 2. Only required parameters were changed.

Evidence and settings provided:

* Genome assembly:
  `Data/hifiasm_p_ctg.fasta`
* RNA-seq evidence (Trinity):
  `Data/trinity_output.Trinity.fasta`
* Protein homology:
  TAIR10 representative proteins + UniProt Viridiplantae reviewed proteins
* Repeat masking:

  * `model_org=` (disable DFam)
  * `rmlib=` EDTA TE library
  * `repeat_protein=` PTREP20
* Gene prediction: AUGUSTUS *arabidopsis* model
* Evidence-based predictions: `est2genome=1`, `protein2genome=1`
* MPI behaviour: `cpus=1`, `TMP=$SCRATCH`

Final configuration block:

```
genome=.../Data/hifiasm_p_ctg.fasta
est=.../Data/trinity_output.Trinity.fasta
protein=/data/.../TAIR10_pep...,/data/.../uniprot_viridiplantae_reviewed.fa
model_org=
rmlib=.../01-EDTA_annotation/hifiasm_p_ctg.fasta.mod.EDTA.TElib.fa
repeat_protein=/data/.../PTREP20
AED_threshold=1
augustus_species=arabidopsis
est2genome=1
protein2genome=1
cpus=1
TMP=$SCRATCH
```

---

### 2.2 Running MAKER with MPI

MAKER was run with 50 MPI workers inside the container using:

```
sbatch Scripts/02.2_run_MAKER_mpi.sh
```

The script binds all required directories and executes:

```
maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl
```

**Output structure**

```
02-MAKER_annotation_results/
└── hifiasm_p_ctg.maker.output/
    ├── hifiasm_p_ctg_master_datastore_index.log
    ├── <contig>/<chunk>.maker.output/
    └── ...
```

The datastore index tracks the status of each contig; each chunk directory contains GFF3s, logs, and intermediate outputs.


### 2.5 Output preparation and renaming

Per-contig outputs were merged into unified GFF and FASTA files, then renamed to assign consistent gene and transcript identifiers.

Renaming was performed with:

```
sbatch Results/Part_2/04-MAKER_output_refinement/06.1_rename_maker_outputs.sh
```

Outputs:

```
hifiasm_p_ctg.all.maker.noseq.renamed.gff
hifiasm_p_ctg.all.maker.proteins.renamed.fasta
hifiasm_p_ctg.all.maker.transcripts.renamed.fasta
```

### 2.6 Filtering and refining gene annotations

A complete refinement pipeline was run using:

```
sbatch Results/Part_2/04-MAKER_output_refinement/06_maker_refinement_full.sh
```

The script performs:

1. InterProScan domain annotation (Pfam).
2. Incorporation of domain information into the GFF.
3. AED calculation for all gene models.
4. Quality filtering (AED < 1 or at least one Pfam domain).
5. Retention of gene, mRNA, CDS, exon, and UTR features only.
6. Subsetting of protein and transcript FASTAs using `faSomeRecords`.

Final high-confidence outputs:

```
filtered.genes.renamed.gff3
hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta
hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta
hifiasm_p_ctg.all.maker.noseq.renamed.iprscan.gff
hifiasm_p_ctg.all.maker.noseq.renamed.AED.txt
hifiasm_p_ctg.all.maker.noseq.renamed_iprscan_quality_filtered.gff
output.iprscan
id.map
```
The filtered annotation contains 49,673 high-confidence mRNAs, matching the filtered FASTA files.

### 2.7 BUSCO quality assessment

Longest isoforms were extracted using:

```
sbatch Scripts/05.1-prepare_longest.sh
```

Outputs:

```
maker_proteins.renamed.longest.fasta
maker_transcripts.renamed.longest.fasta
```

BUSCO was run in protein and transcriptome modes:

```
sbatch Scripts/05.2-run_BUSCO.sh
```

Results stored in:

```
Results/Part_2/05-BUSCO/
```

### 2.8 AGAT annotation statistics

AGAT was used to generate structural annotation statistics:

Run:

```
sbatch Scripts/05.3-run_AGAT_stats.sh
```

Output:

```
Results/Part_2/06-AGAT_statistics/annotation.stat
```

This file summarises counts of gene models, exons, CDS, UTRs, isoforms, and feature lengths.



## Part 2. Gene Annotation with the MAKER Pipeline

### 2.1 Preparing the MAKER annotation environment

All MAKER configuration and output files were generated in:

```
Results/Part_2/01-MAKER_annotation
```

Control files (`maker_opts.ctl`, `maker_bopts.ctl`, `maker_evm.ctl`, `maker_exe.ctl`) were created with:

```
sbatch Scripts/02.1_setup_MAKER.sh
```

This script loads the MAKER Apptainer container, detects Apptainer/Singularity, and runs `maker -CTL`.

Key parameters edited in `maker_opts.ctl`:

- Genome assembly: `Data/hifiasm_p_ctg.fasta`
    
- EST evidence: `Data/trinity_output.Trinity.fasta`
    
- Protein evidence:  
    TAIR10 representative proteins + UniProt Viridiplantae reviewed
    
- Repeat masking:
    
    - `model_org=` (disable DFam)
        
    - `rmlib=` EDTA TE library
        
    - `repeat_protein=` PTREP20
        
- Gene prediction: AUGUSTUS _arabidopsis_ model
    
- Evidence alignment: `est2genome=1`, `protein2genome=1`
    
- MPI behaviour: `cpus=1`, `TMP=$SCRATCH`
    

The edited block:

```
genome=.../Data/hifiasm_p_ctg.fasta
est=.../Data/trinity_output.Trinity.fasta
protein=/data/.../TAIR10_pep,.../uniprot_viridiplantae_reviewed.fa
model_org=
rmlib=.../01-EDTA_annotation/hifiasm_p_ctg.fasta.mod.EDTA.TElib.fa
repeat_protein=/data/.../PTREP20
AED_threshold=1
augustus_species=arabidopsis
est2genome=1
protein2genome=1
cpus=1
TMP=$SCRATCH
```
### 2.2 Running MAKER with MPI

MAKER was launched using 50 MPI workers:

```
sbatch Scripts/02.2_run_MAKER_mpi.sh
```

The script binds all required directories and runs:

```
maker -mpi --ignore_nfs_tmp -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_evm.ctl maker_exe.ctl
```

Output structure:

```
02-MAKER_annotation_results/
└── hifiasm_p_ctg.maker.output/
    ├── hifiasm_p_ctg_master_datastore_index.log
    ├── <contig>/<chunk>.maker.output/
    └── ...
```

Each chunk directory contains GFF3s, logs, and intermediate files.

---

### 2.5 Merging Maker outputs and renaming gene models

Merged GFF and FASTA files were renamed to generate consistent gene and transcript IDs using:

```
sbatch Results/Part_2/04-MAKER_output_refinement/06.1_rename_maker_outputs.sh
```

Outputs:

```
hifiasm_p_ctg.all.maker.noseq.renamed.gff
hifiasm_p_ctg.all.maker.proteins.renamed.fasta
hifiasm_p_ctg.all.maker.transcripts.renamed.fasta
```

---

### 2.6 Filtering and refining gene annotations

The complete refinement pipeline was executed with:

```
sbatch Results/Part_2/04-MAKER_output_refinement/06_maker_refinement_full.sh
```

This performs:

1. InterProScan (Pfam-only) annotation
    
2. Updating GFF with domain information
    
3. AED calculation
    
4. Filtering (keep AED < 1 or genes with Pfam domains)
    
5. Retaining gene/mRNA/CDS/exon/UTR features
    
6. Subsetting protein and transcript FASTAs using `faSomeRecords`
    

Final high-confidence annotation files:

```
filtered.genes.renamed.gff3
hifiasm_p_ctg.all.maker.transcripts.renamed.filtered.fasta
hifiasm_p_ctg.all.maker.proteins.renamed.filtered.fasta
hifiasm_p_ctg.all.maker.noseq.renamed.iprscan.gff
hifiasm_p_ctg.all.maker.noseq.renamed.AED.txt
hifiasm_p_ctg.all.maker.noseq.renamed_iprscan_quality_filtered.gff
output.iprscan
id.map
```

The filtered gene set contains 49,673 mRNAs.

### 2.7 UniProt functional annotation

UniProt-based functional annotation was performed on the filtered protein FASTA using BLASTP against the reviewed Viridiplantae UniProt dataset:

```
sbatch Scripts/06.1-run_uniprot_annotation.sh
```

Pipeline steps:

1. BLASTP to UniProt reviewed proteins
    
2. Sorting to retain the best hit per query
    
3. Updating the protein FASTA with UniProt annotations
    
4. Updating the GFF3 with UniProt functional fields
    

Outputs:
```
maker_proteins.filtered.fasta.Uniprot
filtered.genes.renamed.gff3.Uniprot.gff3
<file>.besthits
```
These files contain putative functional assignments mapped to MR-0 gene models.

### 2.8 BUSCO quality assessment

Longest isoforms were extracted with:
```
sbatch Scripts/05.1-prepare_longest.sh
```

BUSCO (brassicales_odb10) was run in protein and transcript mode:
```
sbatch Scripts/05.2-run_BUSCO.sh
```

Results stored in:

```
Results/Part_2/05-BUSCO/
```
This provides completeness statistics for the final MAKER annotation.

### 2.9 AGAT structural annotation statistics

AGAT was used to summarise gene, mRNA, exon, intron, UTR, and isoform counts:
```
sbatch Scripts/05.3-run_AGAT_stats.sh
```

Output:
```
Results/Part_2/06-AGAT_statistics/annotation.stat
```

## Part 3: Comparative Genomics with GENESPACE

This part follows Manual 3 and uses GENESPACE to identify orthogroups, evaluate genome-wide synteny, and compare gene order among multiple *Arabidopsis thaliana* accessions. The workflow consists of:

1. Running UniProt homology on the final MAKER proteins
2. Preparing BED and peptide FASTA files for each genome
3. Creating the GENESPACE working directory
4. Running OrthoFinder and MCScanX via GENESPACE
5. Extracting pangenome matrices and orthogroup summaries
6. Generating synteny dotplots and multi-genome riparian plots

---

### 3.1 UniProt homology (pre-GENESPACE step)

Before preparing GENESPACE input files, UniProt homology was computed for MR-0 proteins to support functional comparison across accessions.

This was performed using:

```
sbatch Scripts/03.1-uniprot_homology.sh
```

The script:

* runs BLASTP against the UniProt Viridiplantae reviewed database
* sorts results to retain the best hit per gene
* produces UniProt-annotated FASTA and GFF files

Outputs:

```
01-uniprot_homology/
    blastp_uniprot.out
    blastp_uniprot.out.besthits
    maker_proteins.filtered.fasta.Uniprot
    filtered.genes.renamed.gff3.Uniprot.gff3
```

These files provide functional labels used later when interpreting orthogroups.

### 3.2 Preparing GENESPACE input files

GENESPACE requires two files per accession:

* `peptide/<ACCESSION>.fa` — protein FASTA
* `bed/<ACCESSION>.bed` — genomic coordinates of each gene

The MR-0 BED and peptide files were generated from the final filtered GFF using:

```
sbatch Scripts/03.1_prepare_Genespace_inputs.sh
```

Accessions included:

* MR-0
* TAIR10
* Are-6
* Est-0
* Ice-1

Input files were stored in:

```
Results/Part_3/02-GENESPACE_inputs/bed/
Results/Part_3/02-GENESPACE_inputs/peptide/
```

Each BED file is 0-based and includes:
`chromosome  start  end  geneID`


### 3.3 Running GENESPACE

GENESPACE was run using a dedicated R script:

```
R-Scripts/03.3-run_genespace.R
```

and launched via the SLURM wrapper:

```
sbatch Scripts/03.3-run_Genespace.sh
```

The R script performs:

* initialisation of GENESPACE
* execution of OrthoFinder (DIAMOND)
* identification of orthogroups
* reconstruction of syntenic blocks with MCScanX
* generation of dotplots and riparian plots
* extraction of the pangenome matrix (`pangenome_matrix.rds`)

Outputs are stored in:

```
Results/Part_3/03-GENESPACE_results/
```

Key generated files:

```
pangenome_matrix.rds
orthogroups/
rawHits.pdf
syntenicHits.pdf
RiparianPlots/
```

### 3.4 Pangenome and synteny outputs

GENESPACE produces:

- pangenome matrix
  presence/absence of each orthogroup across all accessions
- core orthogroups
  present in all genomes
- accessory orthogroups
  present in a subset
- unique orthogroups
  specific to MR-0 or other accessions
- dotplots showing pairwise syntenic hits
- riparian plots showing multi-genome gene-order structure

The plots were converted to PNG for use in `RESULTS.md`.




