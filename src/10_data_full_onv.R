


source("./utils.R")



# Download Historical Prices -----------------------------------------------

#open symbols table
stock_table <- read.csv(symbols_file,
                          sep = ",",
                          colClasses = c(rep("character", 4),
                                         "double",
                                         rep("logical", 2)
                          )
)
stock_table %<>% dplyr::distinct(ISIN, .keep_all = TRUE)


if (check_price_date() | check_price_file() | check_price_consistent()) {
    
    stock_prices <- lapply(stock_table$NotationId, 
                           function (x) get_prices(x, src = "onvista"))
    names(stock_prices) <- stock_table$ISIN
    stock_prices %<>% lapply(., tradr::fix_OHLC)
    
} else {
    stock_prices <- readRDS(file = "./data/stock_prices.rds")
}


# Remove Truncated Prices -------------------------------------------------

#identify sets with insufficient data
data_dim <- lapply(stock_prices, dim) %>%
    sapply(., function(x) x[1]) 
notwork <- names(data_dim[data_dim <= 185])

#identify deprecated certificates
stock_prices %>% 
    lapply(., Cl) %>%
    do.call(cbind.xts, .) %>%
    'colnames<-'(names(stock_prices)) %>%
    tail(., 5) %>%
    colSums() %>%
    .[is.na(.)] %>%
    names() %T>%
    write.csv(., "tables/deprecated.csv")


#remove price data with insufficient time points 
stock_table_filt <- stock_table %>% dplyr::filter(., !(ISIN %in% notwork))
stock_prices_filt <- stock_prices %>% .[!names(.) %in% notwork]


# Remove Unwanted Entries -------------------------------------------------

stock_table_filt %<>%
    dplyr::filter(is.na(Dach) & !isTRUE(Exclude)) %>%
    unique()
stock_prices_filt %<>% .[names(.) %in% stock_table_filt$ISIN]


# Warnings Report ---------------------------------------------------------

if (length(warnings()) > 0) {
    tradr::add_message(names(warnings()))
    saveRDS(messages, 
            file = paste0("./messages/", Sys.Date(), "_{10}_messages.rds"))
} 


# Save Data ---------------------------------------------------------------

#complete market data
saveRDS(stock_table, file = "./data/stock_table.rds")
saveRDS(stock_prices, file = "./data/stock_prices.rds")

#cleaned market data
saveRDS(stock_table_filt, file = "./data/stock_table_filt.rds")
saveRDS(stock_prices_filt, file = "./data/stock_prices_filt.rds")

