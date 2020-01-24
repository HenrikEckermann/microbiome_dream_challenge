    source(here("R/data_exploration.R"))

Outcomes from recent study and review:
======================================

1.  Gut microbiota composition and functional changes in inflammatory
    bowel disease and irritable bowel syndrome (Vich Vila et al. 2018)

-   high resolution shotgun sequencing of 1792 (355 IBD, 412 IBS, 1025
    controls)
-   of the 102 UC-associated bacterial taxa, 87 were also found to be
    associated with CD
-   15 UC-specific associations incl. *Bacteroides uniformis* and
    *Bifidobacterium bifidum*.
-   decrease in several butyrate producing bacteria incl.
    *Faecalibacterium Prausnitzt* (not significant for UC but trend was
    there in patients with active disease)
-   *Bacteroides* species only increased in patients with IBD but not
    IBS (*Bacteroides fragilis*, *Bacteroides vulgatus*)
-   Enterobacteriaceae only increased in CD *Escherichia/Shigella*
-   *Bifidobacterium longum* lower in CD
-   strain level diversity different (diversity of like pathogenic
    strain increased vs decreased diversity of beneficial microbes)
-   glmnet to differentiate IBS from IBD: mean AUC = 0.91 \[0.81 -
    0.99\] when using microbial compositon. Top20 taxa (highest effect
    size in prediction models led to similar accuracy (mean AUC 0.9)).
    adding fecal calprotectin led to highest accuracy.
-   175, 61 or 38 altered pathways, respectively, for CD, UC or IBS

1.  Differences in Gut Microbiota in Patients With vs Without
    Inflammatory Bowel Diseases: a Systematic Review (Pittayanon et
    al. 2019)

-   Phylum: Tenericutes, Lentisphaerae for UC ↓ (not )
-   Phylum: Actinobacteria, Firmicutes for CD ↓
-   Phylum: Proteobacteria ↑ but 5 studies didnt find this and one found
    decrease in UC
-   *Faecalibacterium prausnitzii* 6/11 and 4/10 studies of CD and
    UC,respectively ↓ (one study for each UC and CD found ↑ for colonic
    tissue samples, remaining studies show non-sig ↓)
-   Family: Coriobacteriaceae CD & UC ↓
-   Family: Christensenellacceae CD ↓
-   Genus: Akkermansia ↓
-   *Eubacterium rectale* UC ↓
-   *Escherischia Coli* ↑
-   Genus: Veillonella CD ↑  
-   alpha diversity either decreased or not different
-   half studies reported data for both active and inactive IBD whereas
    the rest reported either active or not active.

MEDIC DATA
==========

Keep in mind that I do not have the count data but only relative
abundances. So I could not use CLR transformed data for statistical
testing or DeSeq2.

IBD\_vs\_nonIBD
---------------

    feature_names <- c(names(taxa_by_level), "pathway")
    output <- map(feature_names, ~compare_groups(feature_name = .x, task = "IBD_vs_nonIBD"))

### Species

#### PCoA (Bray Curtis)

    output[[1]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-4-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-4-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[1]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">2.21093</td>
<td style="text-align: right;">2.2109303</td>
<td style="text-align: right;">10.19042</td>
<td style="text-align: right;">0.0571884</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">36.44954</td>
<td style="text-align: right;">0.2169615</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9428116</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">38.66047</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[1]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-5-1.png)

#### Differential abundance plots

    output[[1]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-6-15.png)

### Genus

#### PCoA (Bray Curtis)

    output[[2]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-7-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-7-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[2]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.781871</td>
<td style="text-align: right;">1.7818714</td>
<td style="text-align: right;">11.1358</td>
<td style="text-align: right;">0.062164</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">26.882166</td>
<td style="text-align: right;">0.1600129</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.937836</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">28.664038</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[2]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-8-1.png)

#### Differential abundance plots

    output[[2]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-9-15.png)

### Family

#### PCoA (Bray Curtis)

    output[[3]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-10-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-10-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[3]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.512065</td>
<td style="text-align: right;">1.5120648</td>
<td style="text-align: right;">10.80052</td>
<td style="text-align: right;">0.0604054</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">23.519872</td>
<td style="text-align: right;">0.1399992</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9395946</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">25.031937</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[3]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-11-1.png)

#### Differential abundance plots

    output[[3]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-12-15.png)

### Order

#### PCoA (Bray Curtis)

    output[[4]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-13-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-13-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[4]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.251295</td>
<td style="text-align: right;">1.2512946</td>
<td style="text-align: right;">10.95851</td>
<td style="text-align: right;">0.0612349</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">19.183039</td>
<td style="text-align: right;">0.1141848</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9387651</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">20.434334</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[4]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-14-1.png)

#### Differential abundance plots

    output[[4]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-15-15.png)

### Class

#### PCoA (Bray Curtis)

    output[[5]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-16-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-16-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[5]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.159538</td>
<td style="text-align: right;">1.159538</td>
<td style="text-align: right;">10.50859</td>
<td style="text-align: right;">0.0588688</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">18.537457</td>
<td style="text-align: right;">0.110342</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9411312</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">19.696995</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[5]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-17-1.png)

#### Differential abundance plots

    output[[5]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-18-15.png)

### Phylum

#### PCoA (Bray Curtis)

    output[[6]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-19-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-19-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[6]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.8556889</td>
<td style="text-align: right;">0.8556889</td>
<td style="text-align: right;">8.776536</td>
<td style="text-align: right;">0.0496476</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">16.3795521</td>
<td style="text-align: right;">0.0974973</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9503524</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">17.2352409</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[6]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-20-1.png)

#### Differential abundance plots

    output[[6]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-21-15.png)

### Superkingdom

#### PCoA (Bray Curtis)

    output[[7]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-22-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-22-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[7]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.0007876</td>
<td style="text-align: right;">0.0007876</td>
<td style="text-align: right;">0.2964472</td>
<td style="text-align: right;">0.0017615</td>
<td style="text-align: right;">0.63</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">0.4463359</td>
<td style="text-align: right;">0.0026568</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9982385</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">0.4471235</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[7]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-23-1.png)

#### Differential abundance plots

    output[[7]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-24-15.png)

### Pathway

#### PCoA (Bray Curtis)

    output[[8]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-25-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-25-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[8]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.130252</td>
<td style="text-align: right;">1.1302521</td>
<td style="text-align: right;">8.356957</td>
<td style="text-align: right;">0.0473866</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">168</td>
<td style="text-align: right;">22.721470</td>
<td style="text-align: right;">0.1352468</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9526134</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">169</td>
<td style="text-align: right;">23.851722</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[8]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-26-1.png)

#### Differential abundance plots

    output[[8]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-27-15.png)

UC\_vs\_CD
----------

    feature_names <- c(names(taxa_by_level), "pathway")
    output <- map(feature_names, ~compare_groups(feature_name = .x, task = "UC_vs_CD"))

### Species

#### PCoA (Bray Curtis)

    output[[1]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-29-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-29-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[1]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.7793996</td>
<td style="text-align: right;">0.7793996</td>
<td style="text-align: right;">3.045408</td>
<td style="text-align: right;">0.02927</td>
<td style="text-align: right;">0.006</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">25.8485455</td>
<td style="text-align: right;">0.2559262</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.97073</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">26.6279451</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.00000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[1]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-30-1.png)

#### Differential abundance plots

    output[[1]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-31-15.png)

### Genus

#### PCoA (Bray Curtis)

    output[[2]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-32-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-32-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[2]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.6634627</td>
<td style="text-align: right;">0.6634627</td>
<td style="text-align: right;">3.566518</td>
<td style="text-align: right;">0.0341076</td>
<td style="text-align: right;">0.007</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">18.7885614</td>
<td style="text-align: right;">0.1860254</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9658924</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">19.4520241</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[2]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-33-1.png)

#### Differential abundance plots

    output[[2]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-34-15.png)

### Family

#### PCoA (Bray Curtis)

    output[[3]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-35-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-35-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[3]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.611827</td>
<td style="text-align: right;">0.6118270</td>
<td style="text-align: right;">3.710184</td>
<td style="text-align: right;">0.0354329</td>
<td style="text-align: right;">0.016</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">16.655380</td>
<td style="text-align: right;">0.1649048</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9645671</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">17.267207</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[3]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-36-1.png)

#### Differential abundance plots

    output[[3]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-37-15.png)

### Order

#### PCoA (Bray Curtis)

    output[[4]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-38-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-38-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[4]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.529873</td>
<td style="text-align: right;">0.5298730</td>
<td style="text-align: right;">3.85127</td>
<td style="text-align: right;">0.0367308</td>
<td style="text-align: right;">0.017</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">13.895979</td>
<td style="text-align: right;">0.1375839</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9632692</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">14.425852</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[4]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-39-1.png)

#### Differential abundance plots

    output[[4]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-40-15.png)

### Class

#### PCoA (Bray Curtis)

    output[[5]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-41-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-41-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[5]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.5362505</td>
<td style="text-align: right;">0.5362505</td>
<td style="text-align: right;">4.076544</td>
<td style="text-align: right;">0.0387959</td>
<td style="text-align: right;">0.012</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">13.2860851</td>
<td style="text-align: right;">0.1315454</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9612041</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">13.8223356</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[5]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-42-1.png)

#### Differential abundance plots

    output[[5]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-43-15.png)

### Phylum

#### PCoA (Bray Curtis)

    output[[6]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-44-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-44-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[6]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.3936488</td>
<td style="text-align: right;">0.3936488</td>
<td style="text-align: right;">3.374994</td>
<td style="text-align: right;">0.0323353</td>
<td style="text-align: right;">0.041</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">11.7803265</td>
<td style="text-align: right;">0.1166369</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9676647</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">12.1739752</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[6]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-45-1.png)

#### Differential abundance plots

    output[[6]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-46-15.png)

### Superkingdom

#### PCoA (Bray Curtis)

    output[[7]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-47-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-47-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[7]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.0004578</td>
<td style="text-align: right;">0.0004578</td>
<td style="text-align: right;">0.2674747</td>
<td style="text-align: right;">0.0026413</td>
<td style="text-align: right;">0.66</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">0.1728831</td>
<td style="text-align: right;">0.0017117</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9973587</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">0.1733409</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[7]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-48-1.png)

#### Differential abundance plots

    output[[7]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-49-15.png)

### Pathway

#### PCoA (Bray Curtis)

    output[[8]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-50-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-50-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[8]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">2.599331</td>
<td style="text-align: right;">2.599331</td>
<td style="text-align: right;">17.87158</td>
<td style="text-align: right;">0.1503436</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">101</td>
<td style="text-align: right;">14.689943</td>
<td style="text-align: right;">0.145445</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.8496564</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">102</td>
<td style="text-align: right;">17.289274</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[8]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-51-1.png)

#### Differential abundance plots

    output[[8]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-52-15.png)

UC\_vs\_nonIBD
--------------

    feature_names <- c(names(taxa_by_level), "pathway")
    output <- map(feature_names, ~compare_groups(feature_name = .x, task = "UC_vs_nonIBD"))

### Species

#### PCoA (Bray Curtis)

    output[[1]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-54-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-54-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[1]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.436336</td>
<td style="text-align: right;">0.4363360</td>
<td style="text-align: right;">2.742821</td>
<td style="text-align: right;">0.0323664</td>
<td style="text-align: right;">0.007</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">13.044799</td>
<td style="text-align: right;">0.1590829</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9676336</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">13.481135</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[1]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-55-1.png)

#### Differential abundance plots

    output[[1]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-56-15.png)

### Genus

#### PCoA (Bray Curtis)

    output[[2]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-57-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-57-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[2]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.4187907</td>
<td style="text-align: right;">0.4187907</td>
<td style="text-align: right;">3.688728</td>
<td style="text-align: right;">0.043048</td>
<td style="text-align: right;">0.016</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">9.3096698</td>
<td style="text-align: right;">0.1135326</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.956952</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">9.7284605</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[2]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-58-1.png)

#### Differential abundance plots

    output[[2]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-59-15.png)

### Family

#### PCoA (Bray Curtis)

    output[[3]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-60-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-60-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[3]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.3806364</td>
<td style="text-align: right;">0.3806364</td>
<td style="text-align: right;">3.853292</td>
<td style="text-align: right;">0.0448823</td>
<td style="text-align: right;">0.014</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">8.1001358</td>
<td style="text-align: right;">0.0987821</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9551177</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">8.4807722</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[3]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-61-1.png)

#### Differential abundance plots

    output[[3]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-62-15.png)

### Order

#### PCoA (Bray Curtis)

    output[[4]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-63-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-63-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[4]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.2322927</td>
<td style="text-align: right;">0.2322927</td>
<td style="text-align: right;">3.096629</td>
<td style="text-align: right;">0.0363896</td>
<td style="text-align: right;">0.046</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">6.1512057</td>
<td style="text-align: right;">0.0750147</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9636104</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">6.3834984</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[4]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-64-1.png)

#### Differential abundance plots

    output[[4]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-65-15.png)

### Class

#### PCoA (Bray Curtis)

    output[[5]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-66-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-66-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[5]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.2397244</td>
<td style="text-align: right;">0.2397244</td>
<td style="text-align: right;">3.228211</td>
<td style="text-align: right;">0.0378773</td>
<td style="text-align: right;">0.053</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">6.0892552</td>
<td style="text-align: right;">0.0742592</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9621227</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">6.3289796</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[5]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-67-1.png)

#### Differential abundance plots

    output[[5]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-68-15.png)

### Phylum

#### PCoA (Bray Curtis)

    output[[6]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-69-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-69-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[6]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.2224174</td>
<td style="text-align: right;">0.2224174</td>
<td style="text-align: right;">3.287131</td>
<td style="text-align: right;">0.0385419</td>
<td style="text-align: right;">0.056</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">5.5483732</td>
<td style="text-align: right;">0.0676631</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9614581</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">5.7707906</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[6]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-70-1.png)

#### Differential abundance plots

    output[[6]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-71-15.png)

### Superkingdom

#### PCoA (Bray Curtis)

    output[[7]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-72-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-72-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[7]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.0008269</td>
<td style="text-align: right;">0.0008269</td>
<td style="text-align: right;">0.2393747</td>
<td style="text-align: right;">0.0029107</td>
<td style="text-align: right;">0.627</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">0.2832775</td>
<td style="text-align: right;">0.0034546</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9970893</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">0.2841045</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[7]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-73-1.png)

#### Differential abundance plots

    output[[7]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-74-15.png)

### Pathway

#### PCoA (Bray Curtis)

    output[[8]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-75-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-75-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[8]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">2.616105</td>
<td style="text-align: right;">2.6161053</td>
<td style="text-align: right;">29.89791</td>
<td style="text-align: right;">0.2671892</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">82</td>
<td style="text-align: right;">7.175105</td>
<td style="text-align: right;">0.0875013</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.7328108</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">83</td>
<td style="text-align: right;">9.791211</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[8]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-76-1.png)

#### Differential abundance plots

    output[[8]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-77-15.png)

CD\_vs\_nonIBD
--------------

    feature_names <- c(names(taxa_by_level), "pathway")
    output <- map(feature_names, ~compare_groups(feature_name = .x, task = "CD_vs_nonIBD"))

### Species

#### PCoA (Bray Curtis)

    output[[1]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-79-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-79-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[1]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">2.558338</td>
<td style="text-align: right;">2.5583379</td>
<td style="text-align: right;">11.90587</td>
<td style="text-align: right;">0.0730844</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">32.446935</td>
<td style="text-align: right;">0.2148804</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9269156</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">35.005273</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[1]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-80-1.png)

#### Differential abundance plots

    output[[1]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-81-15.png)

### Genus

#### PCoA (Bray Curtis)

    output[[2]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-82-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-82-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[2]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">2.040469</td>
<td style="text-align: right;">2.0404688</td>
<td style="text-align: right;">12.65905</td>
<td style="text-align: right;">0.0773501</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">24.339176</td>
<td style="text-align: right;">0.1611866</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9226499</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">26.379645</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[2]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-83-1.png)

#### Differential abundance plots

    output[[2]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-84-15.png)

### Family

#### PCoA (Bray Curtis)

    output[[3]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-85-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-85-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[3]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.739019</td>
<td style="text-align: right;">1.739019</td>
<td style="text-align: right;">12.46841</td>
<td style="text-align: right;">0.0762741</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">21.060574</td>
<td style="text-align: right;">0.139474</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9237259</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">22.799593</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[3]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-86-1.png)

#### Differential abundance plots

    output[[3]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-87-15.png)

### Order

#### PCoA (Bray Curtis)

    output[[4]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-88-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-88-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[4]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.49483</td>
<td style="text-align: right;">1.494830</td>
<td style="text-align: right;">13.07824</td>
<td style="text-align: right;">0.0797074</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">17.25915</td>
<td style="text-align: right;">0.114299</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9202926</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">18.75398</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[4]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-89-1.png)

#### Differential abundance plots

    output[[4]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-90-15.png)

### Class

#### PCoA (Bray Curtis)

    output[[5]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-91-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-91-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[5]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.391591</td>
<td style="text-align: right;">1.3915912</td>
<td style="text-align: right;">12.63784</td>
<td style="text-align: right;">0.0772305</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">16.627072</td>
<td style="text-align: right;">0.1101131</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9227695</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">18.018663</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[5]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-92-1.png)

#### Differential abundance plots

    output[[5]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-93-15.png)

### Phylum

#### PCoA (Bray Curtis)

    output[[6]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-94-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-94-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[6]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">1.001036</td>
<td style="text-align: right;">1.0010360</td>
<td style="text-align: right;">10.3227</td>
<td style="text-align: right;">0.0639879</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">14.643107</td>
<td style="text-align: right;">0.0969742</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9360121</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">15.644143</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[6]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-95-1.png)

#### Differential abundance plots

    output[[6]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-96-15.png)

### Superkingdom

#### PCoA (Bray Curtis)

    output[[7]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-97-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-97-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[7]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.0006216</td>
<td style="text-align: right;">0.0006216</td>
<td style="text-align: right;">0.2154728</td>
<td style="text-align: right;">0.0014249</td>
<td style="text-align: right;">0.667</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">0.4355955</td>
<td style="text-align: right;">0.0028847</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9985751</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">0.4362171</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[7]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-98-1.png)

#### Differential abundance plots

    output[[7]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-99-15.png)

### Pathway

#### PCoA (Bray Curtis)

    output[[8]][c(3, 4)]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-100-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-100-2.png)

#### PERMANOVA (Bray Curtis)

    kable(output[[8]][[5]])

<table>
<thead>
<tr class="header">
<th></th>
<th style="text-align: right;">Df</th>
<th style="text-align: right;">SumsOfSqs</th>
<th style="text-align: right;">MeanSqs</th>
<th style="text-align: right;">F.Model</th>
<th style="text-align: right;">R2</th>
<th style="text-align: right;">Pr(&gt;F)</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td>labels</td>
<td style="text-align: right;">1</td>
<td style="text-align: right;">0.9578118</td>
<td style="text-align: right;">0.9578118</td>
<td style="text-align: right;">7.869186</td>
<td style="text-align: right;">0.0495325</td>
<td style="text-align: right;">0.001</td>
</tr>
<tr class="even">
<td>Residuals</td>
<td style="text-align: right;">151</td>
<td style="text-align: right;">18.3792299</td>
<td style="text-align: right;">0.1217168</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">0.9504675</td>
<td style="text-align: right;">NA</td>
</tr>
<tr class="odd">
<td>Total</td>
<td style="text-align: right;">152</td>
<td style="text-align: right;">19.3370417</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">NA</td>
<td style="text-align: right;">1.0000000</td>
<td style="text-align: right;">NA</td>
</tr>
</tbody>
</table>

    output[[8]][[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-101-1.png)

#### Differential abundance plots

    output[[8]][[7]]

    ## [[1]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-1.png)

    ## 
    ## [[2]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-2.png)

    ## 
    ## [[3]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-3.png)

    ## 
    ## [[4]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-4.png)

    ## 
    ## [[5]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-5.png)

    ## 
    ## [[6]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-6.png)

    ## 
    ## [[7]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-7.png)

    ## 
    ## [[8]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-8.png)

    ## 
    ## [[9]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-9.png)

    ## 
    ## [[10]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-10.png)

    ## 
    ## [[11]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-11.png)

    ## 
    ## [[12]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-12.png)

    ## 
    ## [[13]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-13.png)

    ## 
    ## [[14]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-14.png)

    ## 
    ## [[15]]

![](CD_vs_nonIBD_files/figure-markdown_strict/unnamed-chunk-102-15.png)

Pittayanon, Rapat, Jennifer T. Lau, Grigorios I. Leontiadis, Frances
Tse, Yuhong Yuan, Michael Surette, and Paul Moayyedi. 2019. “Differences
in Gut Microbiota in Patients with Vs Without Inflammatory Bowel
Diseases: A Systematic Review.” *Gastroenterology*, December.
<https://doi.org/10.1053/j.gastro.2019.11.294>.

Vich Vila, Arnau, Floris Imhann, Valerie Collij, Soesma A.
Jankipersadsing, Thomas Gurry, Zlatan Mujagic, Alexander Kurilshikov, et
al. 2018. “Gut Microbiota Composition and Functional Changes in
Inflammatory Bowel Disease and Irritable Bowel Syndrome.” *Science
Translational Medicine* 10 (472): eaap8914.
<https://doi.org/10.1126/scitranslmed.aap8914>.
