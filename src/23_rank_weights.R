


source("utils.R")



# Parameter ---------------------------------------------------------------

print("Spread:")  
(spread_buy = -0.001)
(spread_sell = -0.001)


# Load Data ---------------------------------------------------------------

# load stock table and prices
stock_table <- readRDS("./data/stock_table_filt_stats.rds")
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table %<>% dplyr::filter(!ISIN %in% isin_exclude)
stock_prices %<>% .[!names(stock_prices) %in% isin_exclude]

# load statistics and favorites based weights
stock_fav_weights <- readRDS("./data/weights/stock_fav_weights.rds") %>% 
    .[period_oi]
stock_stat_weights <- readRDS("./data/weights/stock_stat_weights.rds") %>% 
    .[period_oi]


# Load Strategies ---------------------------------------------------------

strategies <- read.csv("./tables/trading_strategies.csv",
                       stringsAsFactors = FALSE) %>%
    dplyr::rename(id = X) %>%
    dplyr::filter(par1 >= 90, par1%%2 == 0) %>%
    dplyr::filter(par2 <= 20)

print("Main Strategies:")
nrow(strategies)


# Check Price Data Integrity ----------------------------------------------

if (dim(stock_table)[1] != length(stock_prices)) {
    txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

if (!compare_last_index(stock_stat_weights, stock_prices)) {
    txt <- "Last index in 'stock_stat_weights' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

if (!compare_last_index(stock_fav_weights, stock_prices)) {
    txt <- "Last index in 'stock_fav_weights' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}


# Stock Returns -----------------------------------------------------------

stock_returns <- tradr::calc_returns(stock_prices, type = "opop") %>%
    .[period_oi]
stock_returns$CORR <- -1e-09


# Calculate Return Portfolios ---------------------------------------------

rank_weights_list <- strategies %>% 
    split(., seq(nrow(.))) %>% 
    parallel::mclapply(function (x) {
    
    indicator <- x["indicator"] %>% as.character()
    filter <- x["filter"] %>% as.character()
    par1 <- x["par1"] %>% as.numeric()
    par2 <- x["par2"] %>% as.numeric()
    n_roll_type <- x["n_roll_type"] %>% as.character()
    n_roll <- x["n_roll"] %>% as.numeric()
    
    
    if (indicator == "MOM") {
        stock_par1 <- lapply(stock_prices,
                             function (x) TTR::momentum(Cl(x),
                                                        n = par1
                             )) %>%
            do.call(cbind.xts, .) %>%
            `colnames<-`(names(stock_prices)) %>%
            na.locf(na.rm = FALSE) %>%
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
    } 
    if (indicator == "ROC") {
        stock_par1 <- lapply(stock_prices,
                             function (x) TTR::ROC(Cl(x),
                                                   n = par1
                             )) %>%
            do.call(cbind.xts, .) %>%
            `colnames<-`(names(stock_prices)) %>%
            na.locf(na.rm = FALSE) %>%
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
    }
    if (indicator == "PERF") {
        stock_par1 <- lapply(stock_prices,
                             function (x) {
                                 Cl(x) %>% 
                                     dailyReturn() %>%
                                     runSum(n = par1)
                                 }) %>%
            do.call(cbind.xts, .) %>%
            `colnames<-`(names(stock_prices)) %>%
            na.locf(na.rm = FALSE) %>%
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
    }
    
    stock_par1 %<>% .[period_oi]
    
    if (n_roll_type == "SMA") {
        stock_par1 %<>% rollmean(., k = n_roll, align = "right") 
    }
    if (n_roll_type == "EMA") {
        stock_par1 %<>% 
            apply(2, function (x) TTR::EMA(x, n = n_roll)) %>%
            xts(., order.by = index(stock_par1), dateFormat = "Date") 
    }
    if (n_roll_type == "DEMA") {
        stock_par1 %<>% 
            apply(2, function (x) TTR::DEMA(x, n = n_roll)) %>%
            xts(., order.by = index(stock_par1), dateFormat = "Date")
    }
    
    # apply stats filter
    if (filter == "none") {
        stock_par1_filt <- stock_par1 %>% 
            na.locf(na.rm = FALSE) %>% 
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
    }
    if (filter == "statfilter") {
        stock_par1_filt <- tradr::align_xts(stock_par1, stock_stat_weights)
        stock_par1_filt[[2]] %<>% na.locf(na.rm = FALSE)   #extend stat_weights
        stock_par1_filt <- stock_par1_filt[[1]] * stock_par1_filt[[2]]
        stock_par1_filt %<>% na.locf(na.rm = FALSE) %>% 
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
        
    }
    if (filter == "favs") {
        stock_par1_filt <- tradr::align_xts(stock_par1, stock_fav_weights)
        stock_par1_filt[[2]] %<>% na.locf(na.rm = FALSE)   #extend stat_weights
        stock_par1_filt <- stock_par1_filt[[1]] * stock_par1_filt[[2]]
        stock_par1_filt %<>% na.locf(na.rm = FALSE) %>% 
            na.fill(fill = min(as.matrix(.), na.rm = TRUE))
    }
    
    # calculate ranks
    stock_par1_rank <- apply(stock_par1_filt, 1,
                             function (x) rank(x, 
                                               ties.method = "min", 
                                               na.last = "keep")) %>% t()
    
    stock_weights <- apply(stock_par1_rank, 2,
                           function(x) {
                               ifelse(x > dim(stock_par1_rank)[2]-par2,
                                      (100/par2/100), 0)
                           }) %>%
        sweep(., 1, apply(., 1, sum), "/")
    stock_weights[stock_weights > 1/par2] <- 1/par2
    
    stock_weights %<>% as.xts(., dateFormat="Date") %>%
        na.locf(na.rm = TRUE) %>%
        na.fill(fill = 0)

}, mc.cores = 2) %>%
    `names<-`(strategies$id)

rank_weights_list %>% lapply(function (x) zoo(x) %>% rowSums()) 


# QC and Report -----------------------------------------------------------

if (!compare_last_index(rank_weights_list, stock_prices)) {
    txt <- "Last index in 'rank_weights_list' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

if (length(warnings()) > 0) {
    tradr::add_message(names(warnings()))
}

saveRDS(messages, 
        file = paste0("./messages/", save_date, "_{23}_messages.rds"))

saveRDS(rank_weights_list,
        paste0("./data/weights/@history_rank_weights/",
               save_date, "_rank_weights_list.rds"))


# Save Results ------------------------------------------------------------

saveRDS(strategies, 
        paste0("./data/strategies.rds"))

saveRDS(rank_weights_list,
        "./data/weights/rank_weights_list.rds")


