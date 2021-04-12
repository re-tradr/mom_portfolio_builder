


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


# remove expired price files
idx <- list.files("./data/prices/", full.names = TRUE) %>% 
    lapply(function (x) file.info(x) %$% 
               mtime %>% as.Date() %>% 
               `<`(Sys.Date())) %>%
    do.call(c, .)
file.remove(list.files("./data/prices/", full.names = TRUE)[idx])


# download historical price data
yesterday <- paste0(
    strsplit(as.character(Sys.Date() - 1), "-")[[1]][3], ".",
    strsplit(as.character(Sys.Date() - 1), "-")[[1]][2], ".",
    strsplit(as.character(Sys.Date() - 1), "-")[[1]][1]
)

if (check_price_date() | check_price_file() | check_price_consistent()) {
    
    while (stock_table$Symbol %in% (list.files("./data/prices/", 
                                               full.names = TRUE) %>% 
                                    stringr::str_extract("WF........")) %>%
           all() %>% `!`) {
        
        symbol_ready <- list.files("./data/prices/", full.names = TRUE) %>% 
            stringr::str_extract("SP........") %>%
            unique() 
        
        symbol_missing <- stock_table$Symbol[!stock_table$Symbol %in% symbol_ready]
        
        close_RSelenium()
        source("./utils_startRS.R")
        for (i in seq_along(symbol_missing)) {
            
            symbol <- symbol_missing[i]
            url <- paste0(
                "https://www.notshown.com/download?type=daily&name=",
                symbol, "&dateFrom=01.01.2010&dateTo=", yesterday
            )
            remDr$navigate(url)
            Sys.sleep(18)
            
            file_n <- list.files("~/Downloads") %>%
                grep(., pattern = symbol, perl = FALSE) %>%
                tail(., 1)
            file_tmp <- paste0("~/Downloads/",
                               list.files("~/Downloads")[file_n])
            if (file.exists(file_tmp)) {
                file.copy(file_tmp, 
                          paste0("./data/prices/", 
                                 file_tmp %>% 
                                     stringr::str_remove("~/Downloads/")))
                file.remove(file_tmp)
            }
        } #for
    } #while
    close_RSelenium()
    
    price_files <- list.files("./data/prices/", full.names = TRUE,
                              pattern = (save_date %>% 
                                             stringr::str_remove_all("-"))
                              )
    stock_prices <- stock_table$Symbol %>% lapply(function (x) {
        
        prices <- read.csv2(price_files[grepl(x, price_files)],
                            fileEncoding = c("UCS-4-INTERNAL"),
                            skip = 5,
                            sep = ";",
                            col.names = c("Date", "Interval", 
                                          "Open", "Close", "High", "Low"),
                            allowEscapes = TRUE
        )
        prices$Date <- as.Date(
            as.POSIXct(lubridate::dmy_hms(prices$Date, tz = "UTC")
            ), tz = "UTC")
        prices <- prices[, -2]
        prices <- prices[, c("Date", "Open", "High", "Low", "Close")]
        prices <- as.xts(prices[, -1], order.by = prices[, 1])
        prices <- prices[!(weekdays(index(prices)) %in% c("Saturday", "Sunday")), ]
        
    })
    
    names(stock_prices) <- stock_table$ISIN
    stock_prices %<>% lapply(., tradr::fix_OHLC)
    
}


# Remove Truncated Prices -------------------------------------------------

# identify sets with insufficient data
data_dim <- lapply(stock_prices, dim) %>%
    sapply(., function(x) x[1]) 
notwork <- names(data_dim[data_dim <= min_length])

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
                         order.by = date_extd, dateFormat = "Date")
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



