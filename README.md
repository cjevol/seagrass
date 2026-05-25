The R scripts used for analyses in paper titled with "The genetic diversity of seagrasses: environment, reproductive system and the nearly neutral theory" authored by Xinyue Teng, Pan Li, Xinjie Jin, Martin Lascoux and Jun Chen

The Rmd file can be knit by Rstudio. Precompiled PDF and html files are also provided. To compile the file by yourself, you need to download all files including the treefile containing the phylogenetic tree, the folder containing stairway plot summary files, supplementary excel tables (sheet 4) and change their paths in Rmd. 


1. main_dataProcess_protocols.sh: Linux commands used to de novo assemble transcriptomes (ISOseq and RNAseq),  annotate transcriptomes, create phylogenetic tree, and calculated Ka/Ks ratios.

2. CopyNumber_phyloglm.R: R script for the ortholog gene copy number comparison analysis.

3. ViolinPlot_Model1_kaks.R: R script used to plot violin plot for kaks distributions. 

4. VolcanoPlot_TPM_DEG.R  R script used to plot the volcano plot for gene expression differentiation.

5. 
