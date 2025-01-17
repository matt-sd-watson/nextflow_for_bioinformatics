library(data.table)
library(dplyr)
library(optparse)


option_list = list(
  make_option(c("-i", "--input_lineage"), type="character", default=NULL, 
              help="Input lineage report CSV for PHO sequences", metavar="character"),
  make_option(c("-l", "--lineage_id"), type="character", default=NULL, 
              help="ID of the lineage to create subset", metavar="character"),
  make_option(c("-m", "--input_metadata"), type="character", default=NULL, 
              help="path to the master metadata sheet for Nextstrain", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# read the pangolin lineage report and get the WGS Ids with the lineage
pangolin_pho <- read.table(opt$input_lineage, header = TRUE, sep=',', fill = TRUE, quote = "")

subset_pho <- subset(pangolin_pho, lineage == opt$lineage_id)

# write the unique IDs only
unique_ids <- unique(subset_pho$taxon)

# read in metadata from the qc90 list
pho_data <- read.table(
  opt$input_metadata,
  header = T,
  sep = ',',
  fill = TRUE,
  quote = ""
)

pho_data_subset_lineage <- pho_data[pho_data$WGS_Id %in% unique_ids,]

setnames(pho_data_subset_lineage, "PHO.WGS.Id", "strain")
setnames(pho_data_subset_lineage, "Date", "date")

output_file <- paste(opt$lineage_id, ".csv", sep="") # replace with desired output directory
write.csv(pho_data_subset_lineage,
          output_file,
          row.names = F,
          quote = F)
