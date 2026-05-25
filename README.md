The R scripts used for analyses in paper titled with "The genetic diversity of seagrasses: environment, reproductive system and the nearly neutral theory" authored by Xinyue Teng, Pan Li, Xinjie Jin, Martin Lascoux and Jun Chen

The Rmd file can be knit by Rstudio. Precompiled PDF and html files are also provided. To compile the file by yourself, you need to download all files including the treefile containing the phylogenetic tree, the folder containing stairway plot summary files, supplementary excel tables (sheet 4) and change their paths in Rmd. 


1. main_dataProcess_protocols.sh: Linux commands used to de novo assemble transcriptomes (ISOseq and RNAseq),  annotate transcriptomes, create phylogenetic tree, and calculated Ka/Ks ratios.

2. cogent_fakegenome_fagff_protocols.zip: in-house perl scripts used to generate gff files for all transcriptomes 

3. CopyNumber_phyloglm.R: R script for the ortholog gene copy number comparison analysis.

4. get_model0model1_kaks_summary.py, get_model0model4a_kaks_summary.py, ViolinPlot_Model1_kaks.R: Scripts used to summarize kaks ratios based on different modes and plot violin plot for kaks distributions. 

5. VolcanoPlot_TPM_DEG.R:  R script used to plot the volcano plot for gene expression differentiation.

6. DFEpipeline.zip: in-house perl scripts used to estimate DFE (including extracting ortholog alignments, allele frequency polarization, and run polyDFE2.0)

7. seagrassDataAnalyses.Rmd: R markdown file used to do analyses of population genetics and phylogenetic regression
