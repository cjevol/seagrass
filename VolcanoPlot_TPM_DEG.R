
library(readxl)
library(ggplot2)
library(ggrepel)
library(dplyr)
library(tidyverse)
file_path <- "127ind_tpm_HabitatFreshwaterMarineDEG_allGenes2079.txt"
data <- read_tsv(file_path)
cat("fold arrange", range(data$fold, na.rm = TRUE), "\n")
cat("FDR arrange:", range(data$FDR, na.rm = TRUE), "\n")

if (!is.numeric(data$fold)) {data$fold <- as.numeric(data$fold)}
data <- data[!is.na(data$fold),]
if (!is.numeric(data$FDR)) {data$FDR <- as.numeric(data$FDR)}
data <- data[!is.na(data$FDR), ]
cat("nrow:", nrow(data), "\n")
cat("fold arrange:", range(data$fold, na.rm = TRUE), "\n")

data$log2_fold <- log2(data$fold)
cat("log2_fold arrange:", range(data$log2_fold, na.rm = TRUE), "\n")
inf1_og_list <- data$OG[data$log2_fold == -Inf]
print(inf1_og_list) 
inf2_og_list <- data$OG[data$log2_fold == Inf]
print(inf2_og_list) 
data <- data[!is.infinite(data$log2_fold), ]

data$neg_log10_FDR <- -log10(data$FDR)
cat("neg_log10_FDR arrange:", range(data$neg_log10_FDR, na.rm = TRUE), "\n")

FDR_threshold <- 0.05
log2_fold_threshold <- 1

data$Significance <- ifelse(data$FDR < FDR_threshold & abs(data$log2_fold) > log2_fold_threshold, 
                            ifelse(data$log2_fold > 0, "Marine", "Freshwater"), 
                            "Not significant")
og_to_gene <- data.frame(
  OG = c("OG0001052", "OG0000279", "OG0000027", "OG0000707", "OG0000338", "OG0000380","OG0001711", "OG0000746", "OG0000716","OG0002269", "OG0000171","OG0002176","OG0000639", "OG0000159","OG0001710","OG0000117","OG0000425","OG0001525"),  # 添加需要的 OG
  GeneName = c("PA200", "TOP1ALPHA", "CESA1", "CB5LP", "ABCG11", "HSL1", "XLG1", "TIFY10B", "GOX2","HHP4", "PGD2","GME","APR3", "PUB21","COR47","STP4","CAT2","RSR4")  # 对应的基因名称
)

data <- left_join(data, og_to_gene, by = "OG")

data$Label <- ifelse(!is.na(data$GeneName), data$GeneName, "")

windowsFonts()

p1 <- ggplot(data, aes(x = log2_fold, y = neg_log10_FDR, color = Significance)) +
  geom_point(alpha = 0.6, size = 8) +
  scale_color_manual(values = c("Marine" = "#0072b2", "Freshwater" = "#E69F00", "Not significant" = "gray")) +
  labs(x = "Log2(Marine/Freshwater FC)", y = "-Log10(FDR)") +
  theme_bw() + 
  theme(panel.grid.major = element_blank(),panel.grid.minor = element_blank()) + 
  #scale_x_continuous(limits = c(min(data$log2_fold), 40)) + 
  geom_hline(yintercept = -log10(0.05),lty=4,col="black",lwd=0.8) + 
  geom_vline(xintercept=c(-1,1),lty=4,col="black",lwd=0.8) + # 
  scale_y_continuous(limits = c(0, max(data$neg_log10_FDR))) + 
  guides(color = guide_legend(override.aes = list(size = 8))) +  
  theme(legend.title = element_text(family = "serif", size = 18,face = "bold"), 
        legend.text = element_text(family = "serif", size = 16)) + 
  theme(axis.text.x = element_text(size = 18,family = "serif", face = "bold"),
        axis.text.y = element_text(size = 18,family = "serif", face = "bold"))+ 
  theme(axis.title.x = element_text(size = 20,family = "serif", face = "bold"), 
        axis.title.y = element_text(size = 20,family = "serif", face = "bold")) +
geom_text_repel(aes(label = Label),family = "serif", size = 6,fontface = "bold",
                  box.padding = unit(1.8, "lines"),   
                  point.padding = unit(0.1, "lines"), 
                  segment.color = 'gray50',           
                  segment.size = 0.8,                 
                  max.overlaps = 5000,                 
                  seed = 123,                          
                  arrow = arrow(
                    angle = 20,                         
                    length = unit(0.15, "inches"),      
                    ends = "first",                     
                    type = "closed")) 

print(p1)

ggsave("VolcanoPlot_Habitat_TPM_DEG.png", width = 10, height = 8, dpi = 300, bg = "white")
ggsave("VolcanoPlot_Habitat_TPM_DEG.pdf",device = cairo_pdf,width =10, height =8, dpi = 300, bg = "white")

############################################################################################################################


