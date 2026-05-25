library(ggplot2)
library(dplyr)

setwd("D:/tengxinyue/project/kaks/kaks_Summary/model1_freemodel//")
data <- read.table("FullName_25Sp_2079OG_FreeModel_dn_ds_dnds.tsv", header = TRUE, sep = "\t")

species_habitat <- c(
  'ZosteraMarina' = 'Marine', 'PhyllospadixIwatensis' = 'Marine', 'ZosteraMuelleri' = 'Marine',
  'PotamogetonDistinctus' = 'Freshwater', 'PotamogetonOxyphyllus' = 'Freshwater', 'RuppiaMaritima' = 'Marine',
  'CymodoceaRotundata' = 'Marine', 'PosidoniaAustralis' = 'Marine', 'AponogetonCrispus' = 'Freshwater',
  'EnhalusAcoroides' = 'Marine', 'ThalassiaHemprichii' = 'Marine', 'HalophilaBeccarii' = 'Marine',
  'HalophilaOvalis' = 'Marine', 'OtteliaCordata' = 'Freshwater', 'VallisneriaNatans' = 'Freshwater',
  'HydrocharisDubia' = 'Freshwater', 'HydrillaVerticillata' = 'Freshwater', 'NajasMinor' = 'Freshwater',
  'NajasMarina' = 'Freshwater', 'EgeriaDensa' = 'Freshwater', 'ButomusUmbellatus' = 'Freshwater',
  'HydrocleysNymphoides' = 'Freshwater', 'SagittariaTrifolia' = 'Freshwater', 'SpirodelaPolyrhiza' = 'Freshwater',
  'ColocasiaEsculenta' = 'Freshwater'
)

species_sex <- c(
  'ZosteraMarina' = 'Monoecy', 'PhyllospadixIwatensis' = 'Dioecy', 'ZosteraMuelleri' = 'Monoecy',
  'PotamogetonDistinctus' = 'Hermaphroditic', 'PotamogetonOxyphyllus' = 'Hermaphroditic', 'RuppiaMaritima' = 'Hermaphroditic',
  'CymodoceaRotundata' = 'Dioecy', 'PosidoniaAustralis' = 'Hermaphroditic', 'AponogetonCrispus' = 'Hermaphroditic',
  'EnhalusAcoroides' = 'Dioecy', 'ThalassiaHemprichii' = 'Dioecy', 'HalophilaBeccarii' = 'Monoecy',
  'HalophilaOvalis' = 'Dioecy', 'OtteliaCordata' = 'Dioecy', 'VallisneriaNatans' = 'Dioecy',
  'HydrocharisDubia' = 'Monoecy', 'HydrillaVerticillata' = 'Dioecy', 'NajasMinor' = 'Monoecy',
  'NajasMarina' = 'Dioecy', 'EgeriaDensa' = 'Dioecy', 'ButomusUmbellatus' = 'Hermaphroditic',
  'HydrocleysNymphoides' = 'Hermaphroditic', 'SagittariaTrifolia' = 'Monoecy', 'SpirodelaPolyrhiza' = 'Monoecy',
  'ColocasiaEsculenta' = 'Monoecy'
)

species_specie <- c(
  'ZosteraMarina' = 'Zostera marina', 'PhyllospadixIwatensis' = 'Phyllospadix iwatensis', 'ZosteraMuelleri' = 'Zostera muelleri',
  'PotamogetonDistinctus' = 'Potamogeton distinctus', 'PotamogetonOxyphyllus' = 'Potamogeton oxyphyllus', 'RuppiaMaritima' = 'Ruppia maritima',
  'CymodoceaRotundata' = 'Cymodocea rotundata', 'PosidoniaAustralis' = 'Posidonia australis', 'AponogetonCrispus' = 'Aponogeton crispus',
  'EnhalusAcoroides' = 'Enhalus acoroides', 'ThalassiaHemprichii' = 'Thalassia hemprichii', 'HalophilaBeccarii' = 'Halophila beccarii',
  'HalophilaOvalis' = 'Halophila ovalis', 'OtteliaCordata' = 'Ottelia cordata', 'VallisneriaNatans' = 'Vallisneria natans',
  'HydrocharisDubia' = 'Hydrocharis dubia', 'HydrillaVerticillata' = 'Hydrilla verticillata', 'NajasMinor' = 'Najas minor',
  'NajasMarina' = 'Najas marina', 'EgeriaDensa' = 'Elodea densa', 'ButomusUmbellatus' = 'Butomus umbellatus',
  'HydrocleysNymphoides' = 'Hydrocleys nymphoides', 'SagittariaTrifolia' = 'Sagittaria trifolia', 'SpirodelaPolyrhiza' = 'Spirodela polyrhiza',
  'ColocasiaEsculenta' = 'Colocasia esculenta'
)

data$Habitat <- species_habitat[as.character(data$Species)]
data$Sex <- species_sex[as.character(data$Species)]
data$Specie <- species_specie[as.character(data$Species)]
data_clean <- data %>%
  filter(dnds <= 5)
data_clean$log_dnds <- log10(data_clean$dnds)

data$Habitat <- factor(data$Habitat, levels = c('Marine', 'Freshwater'))
data$Sex <- factor(data$Sex, levels = c( "Dioecy", "Monoecy","Hermaphroditic"))
data$Specie <- factor(
  data$Specie, 
  levels = unique(data$Specie[order(data$Habitat, data$Sex)])
)

desired_species_order <- c("Ottelia cordata", "Vallisneria natans", "Najas marina", "Hydrilla verticillata", "Elodea densa", 
                           "Sagittaria trifolia", "Najas minor", "Hydrocharis dubia", "Spirodela polyrhiza", "Colocasia esculenta", 
                           "Aponogeton crispus", "Potamogeton oxyphyllus", "Potamogeton distinctus", "Butomus umbellatus", "Hydrocleys nymphoides",
                           "Phyllospadix iwatensis", "Enhalus acoroides", "Thalassia hemprichii", "Cymodocea rotundata", "Halophila ovalis", 
                           "Zostera muelleri","Halophila beccarii", "Zostera marina", 
                           "Posidonia australis", "Ruppia maritima")

desired_species_order <- c("Ottelia cordata", "Vallisneria natans", "Najas marina", "Hydrilla verticillata", "Elodea densa",
                           "Phyllospadix iwatensis", "Enhalus acoroides", "Thalassia hemprichii", "Cymodocea rotundata", "Halophila ovalis",
                           "Sagittaria trifolia", "Najas minor", "Hydrocharis dubia", "Spirodela polyrhiza", "Colocasia esculenta",
                           "Zostera muelleri","Halophila beccarii", "Zostera marina",
                           "Aponogeton crispus", "Potamogeton oxyphyllus", "Potamogeton distinctus", "Butomus umbellatus", "Hydrocleys nymphoides",
                           "Posidonia australis", "Ruppia maritima")
median_values <- data_clean %>%
  group_by(Specie) %>%
  summarise(median_log_dnds = median(log_dnds, na.rm = TRUE))
print(median_values,n=25)


desired_species_order <- c("Elodea densa","Ottelia cordata","Hydrilla verticillata", "Najas marina","Vallisneria natans",
                           "Halophila ovalis","Cymodocea rotundata", "Thalassia hemprichii","Phyllospadix iwatensis","Enhalus acoroides", 
                           "Colocasia esculenta","Spirodela polyrhiza", "Hydrocharis dubia", "Sagittaria trifolia", "Najas minor",
                           "Halophila beccarii", "Zostera marina","Zostera muelleri",
                           "Aponogeton crispus","Hydrocleys nymphoides","Butomus umbellatus", "Potamogeton oxyphyllus", "Potamogeton distinctus", 
                           "Ruppia maritima","Posidonia australis")



data_clean$Specie <- factor(
  data_clean$Specie, 
  levels = desired_species_order
)


sex_colors <- c("Dioecy" = "#D55E00", "Monoecy" = "#F0E442", "Hermaphroditic" = "#0072B2")
sex_colors <- c("Dioecy" = "#B3CDE3", "Monoecy" = "#FBB4AE", "Hermaphroditic" = "#CCEBC5")
sex_colors <- c("Dioecy" = "#1874CD", "Monoecy" = "#FF6A6A", "Hermaphroditic" = "#b1d85c")
sex_colors <- c("Dioecy" = "#6495ED", "Monoecy" = "#FA8072", "Hermaphroditic" = "#66CDAA")

windowsFonts()

species_sex_df <- data.frame(
  Specie = levels(data_clean$Specie),
  Sex = data_clean$Sex[match(levels(data_clean$Specie), data_clean$Specie)])



ggplot(data_clean, aes(x = Specie, y = log_dnds, fill = Habitat)) +
  geom_jitter(aes(color = 'black'), width = 0, size = 0.5, alpha = 0.6) + 
  geom_violin(trim = FALSE) +
  geom_boxplot(color = 'black', width = 0.3, size = 0.3, fill = NA) +  
  scale_fill_manual(values = c('Marine' = '#0072b2', 'Freshwater' = '#E69F00')) +
  scale_color_manual(values = sex_colors) +  
  labs(
    x = 'Species', 
    y = 'log10 (ka/ks)', 
    title = 'Free Model ka/ks for Each Species of 2079 Genes'
  ) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),    
    panel.grid.minor = element_blank(),    
    panel.border = element_rect(
      color = "black",    
      fill = NA,          
      size = 0.8          
    ),
    text = element_text(family = "serif", face = "bold", size = 16, color = "black"),  
    axis.text.x = element_text(angle = 45, hjust = 1, color = "black", face = "bold.italic"),
    plot.margin = margin(10, 10, 10, 10)   
  ) +
  guides(
    fill = guide_legend(title = "Habitat", size = 6),
    color = guide_legend(override.aes = list(shape = 21, fill = sex_colors, color = "black", size = 6))
  )

ggsave("ViolinPlot_Model1_2079Gene_log_kaks_under5_EachSpecies_Habitat_Sex.png", width = 9, height = 9, dpi = 300, bg = "white")
ggsave("ViolinPlot_Model1_2079Gene_log_kaks_under5_EachSpecies_Habitat_Sex.pdf",device = cairo_pdf,width =9, height =9, dpi = 300, bg = "white")

