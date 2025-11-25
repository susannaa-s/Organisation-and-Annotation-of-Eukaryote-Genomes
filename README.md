# README 

The following document provides the basic Workflow to perform the Analysis or the Mr-0 accession of A. thaliana. The Results and discussions are kept separate documents : 

- Eukaryote_Genome_Annotation/RESULTS.md

Please keep in mind that all provided commands assume the initital position to be in the Project folder. 

## Part 1. Transposable Element Annotation

This section documents the full workflow used to identify, classify, and explore transposable elements in the genome assembly, following the procedures outlined in Manual 1 (Transposable Element Annotation). 

### 1.1 Running EDTA to generate a genome-wide TE annotation

EDTA (version 2.2) was used to annotate transposable elements in the assembly
- `/data/courses/assembly-annotation-course/CDS_annotation/containers/EDTA2.2.sif`

Along with the following  CDS file to avoid miss-classification of TEs 
- `/data/courses/assembly-annotation course/CDS_annotation/data/TAIR10_cds_20110103_representative_gene_model_up`

This is done by first creating the directory to store the results : 

```
mkdir -p Results/Part_1/01-EDTA_annotation
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
TEsorter is used to assign clades based on protein domain homology, and an R script generates faceted histograms showing the identity distribution within each clade. This R script was provided in the course directory on the University cluster. 
- `/data/courses/assembly-annotation-course/CDS_annotation/scripts/02-full_length_LTRs_identity.R`

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

### 1.3 Visualising TE Annotations (circlize)

To explore the spatial distribution of transposable elements across the genome, a circos-style TE density plot was generated using the R package circlize. 
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

The output file is then manually saved as:

- `/data/users/sschaerer/Eukaryote_Genome_Annotation/Graphs/01.3-TE_distribution_circlize_FINAL.png`

A copy of the R script can be found at :  `/R-Scripts/01.3-Cirlize.R`

An additional plot was created to display the TE distribution along with general gene density using the Circos package : 
```
- /Extra/circos_te_density.R
- /Extra/wrapper_circos_density.sh
```
The rsulting plot os stored in : `/Gaphs/TE_Gene_density_ORIGINAL.png` . 

### 1.4 Step 2: Run TEsorter

This step refines the TE annotation provided by EDTA by classifying Copia and Gypsy LTR retrotransposons into evolutionary clades. TEsorter (rexdb-plant database) performs domain-based homology classification on TE families extracted from the EDTA TE library. This allows a more detailed characterisation of LTR-RT diversity beyond the superfamily level.

Clade-level classification was carried out separately for Copia and Gypsy families, as these two LTR-RT lineages have distinct protein domain architectures and are processed independently by TEsorter.

Workflow

1. Extract Copia and Gypsy sequences from the EDTA TE library (`*.mod.EDTA.TElib.fa`).
2. Run TEsorter with the rexdb-plant database on each superfamily.
3. Aggregate clade assignments for all identified Copia and Gypsy families.
4. Summarise the number of families per clade.
5. Generate a barplot showing clade abundances (base R).

The analysis was performed on the cluster using the following two scripts :

```
sbatch Scripts/02-run_TEsorter_Refinement.sh 

sbatch Scripts/01.5_family_clade_counts.sh
```

The second script computes clade counts and produces a simple barplot using base R to avoid package compatibility issues on the cluster.


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

1. Loading the parsed RepeatMasker divergence table (`Div.Rname.tab`).
2. Converting percent divergence into a continuous divergence metric.
3. Calculating TE insertion ages using the Brassicaceae substitution rate  
    (8.22 × 10⁻⁹ substitutions per site per year).
4. Aggregating TE sequence abundance (in Mbp) across divergence bins.
5. Visualising TE dynamics by superfamily.
    
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
/data/users/sschaerer/Eukaryote_Genome_Annotation/Graphs
```
and converted into .png files to be displayed in `RESULTS.md`
