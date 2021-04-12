


source("./utils.R")



# Download Historical Prices -----------------------------------------------

# open symbols table
stock_table <- read.csv(symbols_file,
                          sep = ",",
                          colClasses = c(rep("character", 4),
                                         "double",
                                         rep("logical", 2)
                                         )
                          )
stock_table %<>% dplyr::distinct(ISIN, .keep_all = TRUE)


# download historical price data
if (check_price_date() | check_price_file() | check_price_consistent()) {
    
    source("./utils_startRS.R")
    stock_prices <- lapply(stock_table$Symbol, get_prices_RS)
    #plyr::alply(stock_table$Symbol[1:3], get_prices_RS, .progress = TRUE, .inform=TRUE)
    rD$server$stop(); rm(rD); rm(remDr); gc()
    
    names(stock_prices) <- stock_table$ISIN
    stock_prices %<>% lapply(., tradr::fix_OHLC)
    
    } else {
        stock_prices <- readRDS(file = "./data/stock_prices.rds")
}


# Remove Truncated Prices -------------------------------------------------

# identify sets with insufficient data
data_dim <- lapply(stock_prices, dim) %>%
    sapply(., function(x) x[1]) 
notwork <- names(data_dim[data_dim <= data_min])

# extend entries with insufficient data
stock_table_filt <- stock_table
stock_prices_filt <- stock_prices

for (i in seq_along(notwork)) {
    isin <- notwork[i]
    date_extd <- tradr::seq_date(save_date - ceiling(min_length/5*8),
                                 stock_prices_filt[[isin]] %>% 
                                     index %>% last())
    date_extd %<>% .[!. %in% (stock_prices_filt[[isin]] %>% index)] %>%
        unique()
    price_extd <- as.xts(rep(100, length(date_extd)),
                         order.by = date_ext, dateFormat = "Date")
    price_extd %<>% cbind(., ., ., .) %>%
        `colnames<-`(colnames(stock_prices_filt[[isin]])) 
    price_corr <- rbind(price_extd, stock_prices_filt[[isin]])
    # price correction assigned to filtered stock prices list
    stock_prices_filt[[isin]] <- price_corr
}

# identify deprecated assets
stock_prices %>% 
    lapply(., Cl) %>%
    do.call(cbind.xts, .) %>%
    'colnames<-'(names(stock_prices)) %>%
    tail(., 5) %>%
    colSums() %>%
    .[is.na(.)] %>%
    names() %T>%
    write.csv(., "tables/deprecated.csv")


# Remove Unwanted Entries -------------------------------------------------

stock_table_filt %<>%
    dplyr::filter(is.na(Dach) & !isTRUE(Exclude)) %>%
    unique()
stock_prices_filt %<>% .[names(.) %in% stock_table_filt$ISIN]


# Warnings Report ---------------------------------------------------------

if (length(warnings()) > 0) {
    tradr::add_message(names(warnings()))
}

saveRDS(messages, 
        file = paste0("./messages/", save_date, "_{10}_messages.rds"))


# Save Data ---------------------------------------------------------------

#complete market data
saveRDS(stock_table, file = "./data/stock_table.rds")
saveRDS(stock_prices, file = "./data/stock_prices.rds")

#cleaned market data
saveRDS(stock_table_filt, file = "./data/stock_table_filt.rds")
saveRDS(stock_prices_filt, file = "./data/stock_prices_filt.rds")

