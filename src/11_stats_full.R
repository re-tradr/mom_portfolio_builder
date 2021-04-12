


source("utils.R")



# Load Data ---------------------------------------------------------------

stock_table <- readRDS(file = "./data/stock_table_filt.rds") 
stock_prices <- readRDS(file = "./data/stock_prices_filt.rds")


# Check Price Data Integrity ----------------------------------------------

if (dim(stock_table)[1] != length(stock_prices)) {
    txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}


# Calculate Price Statistics ----------------------------------------------

# stock returns
stock_returns <- lapply(stock_prices,
                     function (x) dailyReturn(Cl(x), leading = FALSE)) %>%
    do.call(cbind.xts, .) %>%
    `colnames<-`(names(stock_prices)) %>%
    na.fill(fill=0) %>%
    .["20120101::"]
stock_returns %<>% apply(., 2, function(x) ifelse(x > 0.055, 0.055, x)) %>%
    xts(., order.by = index(stock_returns))

# stock stats
stock_table$maxDD <- stock_returns %>% 
    PerformanceAnalytics::maxDrawdown(., na.rm=TRUE) %>% 
    t(.) %>% as.numeric() %>% round(., 2)*(-1)

stock_table$maxDailyDD <- stock_returns %>% 
    apply(., 2, function (x) min(x, na.rm=TRUE)) %>%
    round(., 2)

stock_table$annReturn <- stock_returns %>%
    apply(., 2, function (x) sum(x) / (sum(x != 0)/255)) %>%
    round(., 2)

stock_table %<>% dplyr::mutate(
    RiskRatio = round(annReturn/(-1*maxDD), 2)
    )
    
stock_table$Volatility <- lapply(stock_prices,
                                 function (x) {
                                     volatility(
                                         OHLC(x),
                                         n=120,
                                         N=255,
                                         mean0 = TRUE)
                                     }) %>%
    do.call(cbind.xts, .) %>%
    tail(., 1) %>%
    na.fill(., 0.20) %>%
    t() %>% as.numeric() %>% round(., 3)

for (i in seq_len(length(stock_prices))) {
    volatility(
        OHLC(stock_prices[[i]]),
        n=120,
        N=255,
        mean0 = TRUE)
}

# Crashes Anticipated ----------------------------------------------------- 

stock_table$n_crash <- stock_prices %>% lapply(., function (x) {
    sum(index(x)[1] < as.Date("2015-04-15"),
        index(x)[1] < as.Date("2018-01-23"),
        index(x)[1] < as.Date("2020-02-19")
    ) 
}) %>%
    do.call(rbind, .)


# Save Data ---------------------------------------------------------------

saveRDS(stock_table, file = "./data/stock_table_filt_stats.rds")


