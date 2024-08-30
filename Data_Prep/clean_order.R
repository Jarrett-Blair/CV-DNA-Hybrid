# Initializes invert_cleanlab dataframe. This removes some junk groups like 'Arthropoda'
# It also removes underrepresented Orders while merging some orders with their respective Class
# or Phylum labels (e.g. Annelida)

library(stringr)
library(dplyr)


setwd("C:/Carabid_Data/CV-eDNA")

#Load data
invert = read.csv("TaxMorColWea4.1.csv")
edna = read.csv("eDNARaw.csv")

#Match invert$Event format to edna$event format
invert$Event = gsub('[_\\.]', '', invert$Event)

#Subset files based on matching data
ednamatch <- edna %>% 
  filter(event %in% invert$Event)
invertmatch<- invert %>% 
  filter(Event %in% ednamatch$event)

#Clean out low quality DNA observations
ednamatch$percent_sim = as.numeric(ednamatch$percent_sim)
ednamatch = ednamatch[-which(ednamatch$percent_sim > 0 & ednamatch$percent_sim < 97),]
ednamatch = ednamatch[-which(ednamatch$det_level == "phylum"),]


#Clean invert dataset by removing ignore and juveniles
#These shouldn't exist anymore regardless, but leaving the code here just in case
invertmatch = invertmatch[-which(grepl("\\bIgnore\\b", invertmatch$PON_Name, ignore.case = TRUE)),]
invertmatch = invertmatch[-which(grepl("\\bNo Clue\\b", invertmatch$PON_Name, ignore.case = TRUE)),]
invertmatch = invertmatch[-which(grepl("\\bLarva(e)?\\b", invertmatch$PON_Name, ignore.case = TRUE)),]
invertmatch = invertmatch[-which(grepl("\\bjuvenile\\b", invertmatch$PON_Name, ignore.case = TRUE)),]
invertmatch = invertmatch[-which(grepl("\\bNymph\\b(?![a-z])", invertmatch$PON_Name, ignore.case = TRUE, perl = TRUE)),]

#Continue cleaning by only keeping intact/complete observations
keep = c('complete',
         'Complete',
         'Fly',
         'intact')
invertmatch = invertmatch[invertmatch$damaged %in% keep,]
invertmatch = invertmatch[-which(invertmatch$detBy == "KMS"),]

#Capitalizing detection level column values
invertmatch$Det_Level = str_to_title(invertmatch$Det_Level)

#Create AllTaxa column, which represents the finest-grain 
#label for each specimen
AllTaxa = c()
for(i in 1:nrow(invertmatch)){
  if(invertmatch$Det_Level[i] == 'Species'){
    AllTaxa[i] = invertmatch$PON_Name[i]
  }
  else{
    AllTaxa[i] = invertmatch[i,invertmatch$Det_Level[i]]
  }
}

invertmatch$AllTaxa = AllTaxa

#Fixing a couple of labels
invertmatch = invertmatch %>%
  mutate(
    Det_Level = if_else(AllTaxa == "indet.", "Order", Det_Level),
    AllTaxa = if_else(AllTaxa == "indet.", "Amblypigi", AllTaxa)
  )

#Make a SpeciesName column for ednamatch
ednamatch$SpeciesName = NA
ednamatch$SpeciesName[ednamatch$det_level == "species"] = ednamatch$PON_Name[ednamatch$det_level == "species"]

#Removing duplicate DNA detections
#"ednaclean" used to be the result of select() using the columns in distinct()
edna_rmdup <- ednamatch %>%
  distinct(PON_Name,
           phylum,
           subphylum,
           class,
           subclass,
           superorder,
           oorder,
           suborder,
           infraorder,
           superfamily,
           family,
           subfamily,
           genus,
           species,
           det_level,
           event,
           SpeciesName,
           .keep_all = TRUE)


invertmatch <- invertmatch %>%
  #Filter out coarse, nested taxa
  filter(!AllTaxa %in% c("Arthropoda", "Arachnida", "Insecta")) %>%

  #Update detection levels
  mutate(
    Class = if_else(Subphylum == "Myriapoda", "Myriapoda", Class),
    # Det_Level = case_when(
    #   Class == "Gastropoda" ~ "Class",
    #   Phylum == "Annelida" ~ "Phylum",
    #   TRUE ~ Det_Level
    # )
  )

write.csv(invertmatch, "invertmatch.csv", row.names = F)
write.csv(edna_rmdup, "edna_rmdup.csv", row.names = F)

