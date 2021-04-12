


source("utils.R")



# Parameter ---------------------------------------------------------------

print("ROC:")
(par1 <- 160)

print("Positions:")
(par2a <- 140)
(par2b <- 40)

print("SMA:")
(n_roll <- 20)

print("Spread:")
(spread_buy <- -0.0085)
(spread_sell <- -0.001)


# Load Data ---------------------------------------------------------------

stock_table <- readRDS("./data/stock_table_filt_stats.rds")
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table %<>% dplyr::filter(!ISIN %in% isin_exclude)
stock_prices %<>% .[!names(stock_prices) %in% isin_exclude]

rank_weights_list <- readRDS("./data/weights/rank_weights_list.rds")

strategies <- readRDS("data/strategies.rds")


# Check Price Data Integrity ----------------------------------------------

if (dim(stock_table)[1] != length(stock_prices)) {
    txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

if (!compare_last_index(rank_weights_list, stock_prices)) {
    txt <- "Last index in 'rank_weights_list' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}


# Stock Returns -----------------------------------------------------------

stock_returns <- calc_returns(stock_prices, type = "opop", trim = 0.075) %>%
    .[period_oi]
stock_returns$CORR <- -1e-09


# Calculate Return Portfolios ---------------------------------------------

strategy_rps <- rank_weights_list %>% 
    parallel::mclapply(function (x) {
        x %<>%
            na.fill(fill = 0) %>%
            transform(., CORR = 1 - rowSums(.)) %>%
            xts(dateFormat = "Date")
    
        x %>% calc_return_portfolio(R = stock_returns, 
                                    weights = x,
                                    spread_buy = spread_buy, 
                                    spread_sell = spread_sell,
                                    wealth_index = TRUE)
}, mc.cores = 4)


# Strategy Rank -----------------------------------------------------------

# strategy portfolio prices
strategy_prices <- strategy_rps %>% 
    sapply("[[", "price_spread") %>%
    lapply(function (x) x %>% `colnames<-`("Close"))

# strategy ranks and weights
strategy_par1 <- lapply(strategy_prices,
                     function (x) {
                         TTR::ROC(Cl(x), n = par1)
                     }) %>%
    do.call(cbind.xts, .) %>%
    `colnames<-`(names(strategy_prices)) %>%
    na.locf(na.rm = FALSE) %>%
    na.fill(fill = min(as.matrix(.), na.rm = TRUE))

strategy_par1 %<>% rollmean(., k = n_roll, align = "right") %>%
    na.fill(fill = min(as.matrix(.), na.rm = TRUE))

strategy_par1 %>% last() %>% t() %>% plot()

# calculate strategy ranks 
strategy_par1_rank <- apply(strategy_par1, 1,
                            function (x) rank(x, ties.method = "min")
                            ) %>% t()

strategy_par1_rank %>% last()

# calculate strategy rank based weights
last_rank <- strategy_par1_rank %>% last() %>% t()
strategies %<>% dplyr::mutate(rank = last_rank)

idx1 <- (last_rank > (length(last_rank) - par2a))
idx2 <- (last_rank > (length(last_rank) - par2b))

rank_weights_list_filt1 <- rank_weights_list[idx1]
rank_weights_list_filt2 <- rank_weights_list[idx2]
rank_weights_list_filt <- c(rank_weights_list_filt1, rank_weights_list_filt2)


portfolio_master_latest <- rank_weights_list_filt %>% 
    Reduce("+", .) %>%
    na.locf() %>%
    sweep(., 1, (par2a + par2b), "/") %>%
    tradr::extend_xts(., n = 1, weekday = TRUE) %>%
    lag.xts(k = 1) %>%
    na.fill(fill = 0) %>%
    transform(., CORR = 1 - rowSums(.)) %>%
    xts(., dateFormat = "Date") 
    

# Save Results ------------------------------------------------------------


saveRDS(strategies, 
        paste0("./data/strategies.rds"))

saveRDS(strategy_rps, 
        paste0("./data/strategy_rps.rds"))

saveRDS(portfolio_master_latest,
        paste0("./data/weights/@history_master/",
               save_date, "_master_latest.rds"))


