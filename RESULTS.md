# RESULTS.md
Project: Organisation and Annotation of Eukaryote Genomes  
Author: Susanna Schärer  
MSc Bioinformatics & Computational Biology, University of Bern / University of Fribourg  

---

## 0. Overview

This document summarises the main quantitative results and interpretations for the project *SBL.30004 Organisation and Annotation of Eukaryote Genomes*.  
Each section corresponds to one analytical stage of the pipeline, from raw data to functional annotation.


## 1. Transposable Element (TE) Annotation

### 1.1 Overview
TEs were annotated using **EDTA** and classified with **TEsorter** on the *Arabidopsis thaliana MR-0* assembly (Hifiasm).  
Outputs include GFF3 annotation files, TE libraries, and summary plots.

### 1.2 Quantitative Summary

| Family       | Count | % of total | Notes                                   |
| ------------ | ----- | ---------- | --------------------------------------- |
| Copia        | 88    | 12         | Includes several young, intact elements |
| Gypsy        | 110   | 15         | Broader age range, more degenerated     |
| Unclassified | 549   | 73         | Mostly fragmented or solo LTRs          |


### 1.3 Visual Summary

![[Eukaryote_Genome_Annotation/Images/01_LTR_Copia_Gypsy_cladelevel_white.png|600]]

(Results/01-EDTA_annotation/plots/01_LTR_Copia_Gypsy_cladelevel_white.png)

x- axis : shows how similar each copy is to its original sequence
- 1.0 : New element 
	- copy is identical to the consensus (no mutations), so it likely inserted very recently
- 0 : old element 
y-axis : how many copies exist at each similarity level

Observations :
- Copia families (Ale, Angela, Bianca) show tight clusters near 1.0, typical of young, active insertions.
- Gypsy families (Athila, Tekay, Retand) are more widely distributed around 0.85–0.9, consistent with older or more diverged copies.

### 1.4 Guiding Questions 

Answers Based on the TEsorter output 

1. Are there differences in the number of full-length LTR-RTs between the clades?

- Yes. There are 88 classified elements for Copia and 110 for Gypsy. Copia spans 9 clades, Gypsy spans 5.

2. Are there clades with high percent identity (e.g. 99–100%, young insertions) or low percent identity (e.g. 80–90%, old insertions)?

- Copia clades such as Ale, Angela, and Bianca show high sequence identity, indicating recent insertions.
- Gypsy clades such as Athila, Tekay, and Retand show broader peaks around 0.85–0.9, characteristic of older or more degenerated insertions.

Answers Based on the EDTA summary file : 

3. Which TE superfamily is the most abundant in the genome?




4. Are there any differences in TE content between the accessions?
