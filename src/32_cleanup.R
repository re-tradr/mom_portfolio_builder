


source("utils.R")



# Remove Expired Files ----------------------------------------------------

idx_old <- list.files("messages/", full.names = TRUE) %>%
  lapply(function (x) file.mtime(x) < (Sys.Date()-5)) %>% 
  do.call(rbind, .)

list.files("messages/", full.names = TRUE)[idx_old] %>%
  file.remove()


idx_old <- list.files("data/weights/", full.names = TRUE, recursive = TRUE) %>%
  .[!grepl("@history_master|@log_fav_weights", .)] %>%
  lapply(function (x) file.mtime(x) < (Sys.Date()-5)) %>% 
  do.call(rbind, .)

list.files("data/weights/", full.names = TRUE, recursive = TRUE) %>%
  .[!grepl("@history_master|@log_fav_weights", .)] %>% 
  .[idx_old] %>%
  file.remove()

list.files("~/Downloads/", 
           pattern = "WF........-daily-", 
           full.names = TRUE) %>%
  file.remove()



# Copy Portfolio Report ---------------------------------------------------

file.copy("./src/32_create_report.html", cloud_dir)
file.rename(paste0(cloud_dir, "/32_create_report.html"), 
            paste0(cloud_dir, "/", save_date, "_portfolio_report.html"))
file.remove("./src/32_create_report.html")

