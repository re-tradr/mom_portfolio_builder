


source("utils.R")



# Parameter ---------------------------------------------------------------

print("Spread:")  
(spread_buy = -0.001)
(spread_sell = -0.001)


# Load Data ---------------------------------------------------------------

# load stock table and prices
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table <- read.csv("./tables/wf_table_long.csv",
                        sep = ",",
                        colClasses = c(rep("character", 4),
                                       "double",
                                       rep("logical", 2)
                        )
)
stock_table %<>% dplyr::distinct(ISIN, .keep_all = TRUE)


# Load Strategies ---------------------------------------------------------

strategies <- read.csv("./tables/trading_strategies_long.csv",
                       stringsAsFactors = FALSE) %>%
    dplyr::rename(id = X) 

print("Main Strategies:")
nrow(strategies)


# Stock Returns -----------------------------------------------------------

stock_returns <- tradr::calc_returns(stock_prices, type = "opop") %>%
    .[period_oi]
stock_returns$CORR <- -1e-09


# Calculate Return Portfolios ---------------------------------------------

rank_weights_list <- strategies %>% apply(1, function (x) {
    
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

}) %>%
    `names<-`(strategies$id)

rank_weights_list %>% lapply(function (x) zoo(x) %>% rowSums()) 


# Save Results ------------------------------------------------------------

saveRDS(rank_weights_list,
        "./data/weights/rank_weights_list_long.rds")


# Current Universe --------------------------------------------------------

rank_weights <- rank_weights_list %>% 
    Reduce("+", .) %>%
    na.locf() %>%
    sweep(., 1, length(rank_weights_list), "/") %>%
    na.fill(fill = 0) %>%
    xts(., dateFormat = "Date") 


rank_weights %>% last() %>% .[, .!=0] %>% 
    .[, order(., decreasing = TRUE)]  %>% t() %>% View()

rank_weights %>% last() %>% .[, .!=0] %>% 
    .[, order(., decreasing = TRUE)]  %>% t() %>%
    write.csv("tables/tmp.csv")


