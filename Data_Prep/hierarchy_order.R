setwd("C:/Users/au761482/Git_Repos/CV-eDNA-Hybrid/Data/Clean_Data")

invertmatch = read.csv("invertmatch.csv")

ranks = c("Species", 
          "Genus", 
          "Subfamily", 
          "Family", 
          "Superfamily", 
          "Infraorder", 
          "Suborder", 
          "Order", 
          "Superorder", 
          "Subclass", 
          "Class", 
          "Subphylum", 
          "Phylum")

hierarchy = refhier(df = invertmatch, 
                    ranks = ranks, 
                    base_rank = "Fine_Name", 
                    det_level = "Det_Level")

write.csv(hierarchy, "hierarchy.csv", row.names = F)

