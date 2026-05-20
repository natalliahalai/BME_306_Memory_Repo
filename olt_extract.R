# Get all csv OLT files
files <- list.files(
  "~/data/OLT_Data/",
  pattern = "\\.csv$",
  full.names = TRUE,
  recursive = TRUE
)


library(readr)
library(dplyr)
library(stringr)

all_data <- lapply(files, function(f) {

  # get info
  parts <- str_split(f, .Platform$file.sep)[[1]]
  
  participant <- strsplit(parts[grepl("Participant_", parts)], "_")[[1]][2]
  timepoint   <- strsplit(parts[grepl("Session_", parts)], "_")[[1]][2]
  filename    <- tail(parts, 1)
  
  
  oltd <- read.csv(f)
  minrounds <- min(oltd$cued_recall_round,na.rm = T)
  olt_info <- oltd %>% 
    filter(cued_recall_round %in% minrounds) %>% 
    summarize(percent_correct = sum(answer)/length(answer),
              time_for_answer_correct = mean(time_for_answer[answer == 1]))
  
  olt_info$participant = participant
  olt_info$timepoint = timepoint
  olt_info$file = filename
  
  olt_info
})
all_data <- do.call(rbind, all_data)
write.csv(all_data,
          file = "~/data/all_olt_min.csv",
          row.names = FALSE)
