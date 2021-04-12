


source("utils.R")



# Load Data ---------------------------------------------------------------

stock_table <- readRDS("./data/stock_table_filt_stats.rds")
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table %<>% dplyr::filter(!ISIN %in% isin_exclude)
stock_prices %<>% .[!names(stock_prices) %in% isin_exclude]

# favorites according to manually curated table
favs_selection <- read.csv("./tables/st_table_favs.csv",
                           sep = ",",
                           colClasses = c(rep("character", 4),
                                          "double",
                                          rep("logical", 2)
                           )
) %$% ISIN %>% unique()
favs_selection <- stock_table[stock_table$ISIN %in% favs_selection, ] %$% ISIN


# Check Price Data Integrity ----------------------------------------------

if (dim(stock_table)[1] != length(stock_prices)) {
    txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}
tradr::add_message(paste0(
    dim(stock_table)[1],
    " entries used for favorites based weights calculation."
))


# Save current favorites --------------------------------------------------

last_favs_selection <- list.files("./data/weights/@log_fav_weights", 
                                  pattern = "fav_weights.rds", full.names = TRUE) %>%
    tail(1) %>% readRDS()

if (!all(order(last_favs_selection) == order(favs_selection))) {
    saveRDS(favs_selection, 
            paste0("./data/weights/@log_fav_weights/",
                   save_date, "_fav_weights.rds"))
    tradr::add_message("Favorite weights changed; new log file created.")
}


# Create favorite weights -------------------------------------------------     

tmp_files <- list.files("./data/weights/@log_fav_weights", 
                        pattern = "fav_weights.rds",
                        full.names = TRUE)
tmp_date <- tmp_files %>% stringr::str_extract(., "20........") %>% as.Date()
tmp_content <- tmp_files %>% lapply(readRDS) %>%
    lapply(., function (x) {x[x %in% stock_table$ISIN]})
tmp_date <- tmp_date[tmp_content %>% lapply(length) != 0]
tmp_content <- tmp_content[tmp_content %>% lapply(length) != 0]
history_favorite <- suppressWarnings(
    do.call(rbind, tmp_content) %>% 
        as.xts(., order.by = tmp_date, dateFormat = "Date")
)
history_favorite %<>% .[unique(index(.)), ]

rm(tmp_files, tmp_content)

if (!all(index(history_favorite) %>% 
         unique() %in% date_seq)) {
    tradr::add_message("Index of 'history_favorite' not in 'date_seq'.")
}


# Create favorites-based filter -------------------------------------------

stock_fav_weights <- stock_prices %>% 
    lapply(., function (x) Cl(x)) %>% 
    do.call(cbind.xts, .) %>%
    `colnames<-`(names(stock_prices)) %>%
    na.fill(fill = NA) %>%
    .["2014-01-01::"] %>%
    sweep(., 2, NA, FUN = "*")

for (w in 1:dim(history_favorite)[1]) {
    for (v in 1:dim(history_favorite)[2]) {
        stock_fav_weights[index(history_favorite[w, ]), 
                       history_favorite[w, v]] <- 1
    }
}

idx1 <- stock_fav_weights %>% zoo() %>% rowSums(na.rm = TRUE) != 0 
stock_fav_weights[idx1, ] %<>% replace(is.na(.), 0)

stock_fav_weights %<>% 
    na.locf(na.rm = FALSE) %>%
    na.fill(fill = 0) %>% 
    .[period_oi]

stock_fav_weights %>% last() %>% .[, order(.)]


# QC and Report -----------------------------------------------------------

if (!compare_last_index(stock_fav_weights, stock_prices)) {
    txt <- "Last index in 'stock_fav_weights' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

tradr::add_message(paste0(
    stock_fav_weights %>% last() %>% .[, .!=0] %>% length(),
    " entries in favorites based weights fraction."
))

tmp <- history_favorite %>% tail(2) 
n_changed <- setdiff(unique(tmp[1,]), unique(tmp[2,]))
p_changed <- (length(n_changed)/length(unique(tmp[1,]))) %>%
    round(., 2) %>% `*`(100)
if(p_changed > 10) {
    tradr::add_message(
        paste0("Warning: ", p_changed,
               " % change in history_favorite positions detected.")
        )
}

if (length(warnings()) > 0) {
    tradr::add_message(names(warnings()))
}

saveRDS(messages, 
        file = paste0("./messages/", save_date, "_{22}_messages.rds"))

saveRDS(stock_fav_weights,
        paste0("./data/weights/@history_fav_weights/",
               save_date, "_fav_weights.rds"))


# Save Results ------------------------------------------------------------

saveRDS(stock_fav_weights, 
        paste0("./data/weights/stock_fav_weights.rds"))


