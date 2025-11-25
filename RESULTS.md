
# Part 1 : Transposable Element Annotation and Classification


### Part 1.1 

From the EDTA annotation summary file we obtain the following information : 

```
Repeat Classes
==============
Total Sequences: 611
Total Length: 167017680 bp
Class                  Count        bpMasked    %masked
=====                  =====        ========     =======
LINE                   --           --           --   
    L1                 965          748678       0.45% 
LTR                    --           --           --   
    Copia              880          1220471      0.73% 
    Gypsy              1801         2483947      1.49% 
    unknown            7192         9545186      5.72% 
SINE                   --           --           --   
    tRNA               42           24051        0.01% 
TIR                    --           --           --   
    CACTA              1371         849402       0.51% 
    Mutator            2190         1574713      0.94% 
    PIF_Harbinger      950          412126       0.25% 
    Tc1_Mariner        62           61519        0.04% 
    hAT                1241         552956       0.33% 
nonTIR                 --           --           --   
    helitron           12377        5397860      3.23% 
repeat_fragment        1321         370622       0.22% 
                      ---------------------------------
    total interspersed 30392        23241531     13.92%

---------------------------------------------------------
Total                  30392        23241531     13.92%
```

#### Which TE superfamily is the most abundant in the genome?

Most abundant : Gypsy among the LTR retrotransposons
If we consider _all_ TE types  :  Helitrons (non-TIR DNA transposons) occupy an even larger fraction of the genome (3.23%).

Single largest category overall is : unknown repeats  (5.72%), 
- many TE-derived fragments could not be confidently assigned to a known superfamily.
- common in plant genomes because many TE lineages are old and highly degraded.

#### Are there any differences in TE content between the accessions?

Yes, TE content normally differs between accessions, but we can only confirm differences if we compare each accession’s EDTA summary file.  

### Part 1.2 

![Copia/Gypsy clade identity distribution](Graphs/01_LTR_Copia_Gypsy_cladelevel_white.png)


#### Are there differences in the number of full length LTR-RTs between the clades?

Yes. Some clades contain many full-length elements, while others contain only a few or none.  
For example:

- In Gypsy, clades like Tekay, Athila, and Retand show many full-length copies.
- In Copia, clades such as Ale, Ivana, and Ikeros are represented, but several clades (e.g. Alesia, Angela, Tork) have only one or very few elements.
    
$\Rightarrow$ proliferation of LTR-RTs is not uniform across clades 
$\Rightarrow$ some lineages have been much more active in this genome than others.


#### Are there any clades with High percent identity (e.g., 99-100%) or young insertions and Low percent identity (e.g., 80-90%) or old insertions?

Yes. Several clades (Tekay, Retand, Athila, Ale, Ivana) show many elements with identities close to 100 percent, indicating very recent insertions. Others (CRM, Angela, Bianca) contain elements with lower identities, consistent with older insertions.


### Part 1.3 
<img src="Graphs/TE_Gene_density_ORIGINAL.png" width="600">
#### Are there any regions with high TE density?

Yes. Several scaffolds show clear regional clustering of TEs, with higher densities toward specific ends or segments of the scaffold.

- ptg000006, ptg000009, ptg000021, and ptg000006l show distinct regions with high TE density, especially in the unknown (green) and Copia (orange) categories.
- we observe the expected anticorrelational pattern between gene density and TE density which is an encouraging result 
  
- The dense green peaks typically suggest older, fragmented TE accumulation, often associated with pericentromeric-like regions 
    
- Some scaffolds show long stretches with _very low_ TE density (e.g., ptg000011), indicating likely gene-rich regions

#### Do the distribution of Gypsy and Copia and other TIR DNA transposons overlap, are there any differences?

Yes, there is partial overlap between Gypsy and Copia, but their distributions are not identical.

- Gypsy elements tend to occur in more localised blocks, often forming short clusters.
- Copia elements show a broader and more dispersed distribution across scaffolds.
- Unknown/other TEs dominate the high-density regions and often overlap with both LTR families.
    
- There are areas where only Copia appears, areas where only Gypsy appears, and regions where both are absent — indicating superfamily-specific insertion preferences or different evolutionary histories

### Part 1.4 Refinement of TE sorter 

Using the final TEanno.gff3 file from EDTA and the clade classification of all TEs from TEsorter can you provide an estimate of the number of Copia and Gypsy elements in each clade? What are the most abundant clades in your genome?


```
Copia SIRE 2

Copia Ale 15

Copia Alesia 1

Copia Tork 8

Copia Bianca 6

Copia Angela 1

Copia Ivana 5

Gypsy CRM 4

Gypsy Reina 11

Gypsy Retand 11

Gypsy Tekay 1

Gypsy Athila 8
```

Copia families are dominated by the Ale (15 families) and Tork (8 families) clades, 
while smaller contributions come from Bianca, Ivana, SIRE, Alesia, and Angela.

Gypsy families are most abundant in the Reina and Retand clades (11 families each), 
followed by Athila (8), CRM (4), and Tekay (1).

### Part 1.7
<p align="center">
  <img src="Graphs/TE_age_landscape.png" width="500">
  <img src="Graphs/TE_divergence_landscape.png" width="500">
</p>


#### 1. Can you identify recent and ancient TE activity peaks?

Recent activity

You have no strong peak at very low divergence (K < 0.02) or age < ~3–5 MYA
This means:

- No evidence of recent bursts of TE activity.
- Only a very small amount of near-zero divergence material, mostly noise or highly conserved fragments.

This is exactly what you expect for _Arabidopsis thaliana_, which removes young TEs rapidly and has few active families.

Ancient activity

Two pronounced regions appear:

1. Mid divergence peak (K ≈ 0.10–0.20 → ~10–15 MYA)
    This is the main TE burst, shared across many Brassicaceae.
    
2. Older, broad tail (K > 0.25 → ~20–30 MYA)
	Represents highly degraded, ancient insertions, many of them TIR elements and older Gypsy families.

Note : The conversion from divergence to age is very inexact as it relies heavily on the average mutation rate in the conversion formula : insert formula. 

So:
- Major TE activity occurred very roughly 10–25 MYA
- No clear evidence of recent activation.

We also note that there has there have been divergences up to very recently without any sign of subsiding mesning that there are most lkely still mutations happening. 
    

2. #### Are there differences in TE dynamics between the accessions studied in the group?

As we have a large group of different accessions amongst the group, there are some differences depending on the accession. Over all the results for Mr-0 are fairly standart in comparison. There are no major discrepancies between this result and the average result form the group. 

#### 3. How do the TE dynamics differ between Copia and Gypsy elements?

Gypsy :
- Higher total Mbp across nearly all divergence bins.
- Broad, older distribution (more signal at K > 0.20).
- Indicates Gypsy has contributed most of the ancient TE load.

This is the expected pattern in Brassicaceae.

Copia :
- Present but significantly weaker than Gypsy.
- More signal in mid divergence (K ≈ 0.10–0.15).
- Fewer ancient fragments compared with Gypsy.
    
Interpretation
- Gypsy elements dominated past expansions, creating much of the old TE content.
- Copia elements were active but at lower magnitude, and less retention of ancient fragments is typical in Arabidopsis.
- Neither superfamily shows evidence of recent (<5 MYA) bursts.
    
