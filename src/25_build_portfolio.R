


source("utils.R")



# Load Data ---------------------------------------------------------------

# load stock table and prices
stock_table <- readRDS("./data/stock_table_filt_stats.rds")
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table %<>% dplyr::filter(!ISIN %in% isin_exclude)
stock_prices %<>% .[!names(stock_prices) %in% isin_exclude]


# Assemble Master Portfolio -----------------------------------------------

master_files <- list.files("./data/weights/@history_master/",
                           pattern = "latest.rds", full.names = TRUE)

# find and remove master files with incorrect index
idx <- master_files %>% lapply(function (x) {
    
    pattern <- paste0("[:digit:]{4}", "\\-", 
                      "[:digit:]{2}", "\\-", 
                      "[:digit:]{2}") %>% 
        stringr::regex()
    c(x %>% stringr::str_extract_all(., pattern) %>% unlist(),
      x %>% readRDS() %>% last() %>% index() %>% as.character())
    
}) %>% do.call(rbind, .)
idx <- (idx[, 1] == idx[, 2])

master_files %<>% .[idx]

# assemble latest dynamic files
f1 <- readRDS(master_files[1])
ff <- master_files[-1] %>% lapply(function (x) {
    x %>% readRDS() %>% last()
})

portfolio_master_df <- c(list(f1), ff) %>% 
    purrr::map(zoo::fortify.zoo) %>%
    dplyr::bind_rows() %>%
    dplyr::full_join(.,
                     as.data.frame(date_seq[date_seq < save_date]) %>% 
                         `colnames<-`(c("Index")),
                     by = "Index") %>%
    dplyr::arrange(Index) %>%
    dplyr::select(-CORR) 
    
portfolio_master <- portfolio_master_df %>% 
    tibble::column_to_rownames(var = "Index") %>%
    xts(order.by = as.Date(rownames(.)), dateFormat = "Date") 

portfolio_master %<>% na.locf(maxgap = 3) %>% #should fill only gaps w/o data
    na.fill(fill = 0) %>%
    transform(., CORR = 1 - rowSums(.)) %>%
    xts(., dateFormat = "Date")

# result summary
portfolio_master %>% tail() %>% t() %>% as.data.frame() %>% 
    tibble::rownames_to_column(var = "ISIN") %>%
    dplyr::left_join(stock_table %>% dplyr::select(ISIN, Name), ., by = "ISIN") %>%
    dplyr::arrange_at(ncol(.), dplyr::desc) 


# Apply Stop Loss ---------------------------------------------------------

stock_returns <- calc_returns(stock_prices, type = "opop", trim = 0.075) %>%
    .[period_oi]
stock_returns$CORR <- -1e-09

portfolio_master_latest <- readRDS(master_files[length(master_files)])
master_return_portfolio <- calc_return_portfolio(R = stock_returns,
                                                 weights = portfolio_master_latest,
                                                 spread_buy = -0.0085, 
                                                 spread_sell = -0.001,
                                                 wealth_index = TRUE)

sl_val_1 <- master_return_portfolio$price_spread %>%
    tradr::calculate_sl(n = 5, sl1 = -0.13, sl2 = -0.25, ma = c("DEMA")) 

sl_val_2 <- master_return_portfolio$price_spread %>%
    tradr::calculate_sl(n = 2, sl1 = -0.16, sl2 = -0.30, ma = c("EMA")) 

sl_val <- cbind.xts(sl_val_1, sl_val_2) %>% .[, 1]
sl_val$StopLoss <- cbind.xts(sl_val_1, sl_val_2) %>% rowMeans()
sl_val %<>% .[index(portfolio_master), ]

portfolio_master_sl_tmp <- cbind.xts(portfolio_master, sl_val) %>%
    na.locf() 

portfolio_master_sl <- portfolio_master_sl_tmp[, -which(colnames(portfolio_master_sl_tmp) %in% 
                                        c("CORR", "StopLoss"))] %>%
    sweep(., MARGIN = 1, STATS = portfolio_master_sl_tmp$StopLoss, FUN = "*") %>%
    transform(., CORR = 1 - rowSums(.)) %>%
    xts(., dateFormat = "Date")

# result summary
portfolio_master_sl %>% tail() %>% t() %>% as.data.frame() %>% 
    tibble::rownames_to_column(var = "ISIN") %>%
    dplyr::left_join(stock_table %>% dplyr::select(ISIN, Name), ., by = "ISIN") %>%
    dplyr::arrange_at(ncol(.), dplyr::desc) 


# Save Results ------------------------------------------------------------

saveRDS(portfolio_master,
        paste0("./data/weights/@history_master/",
               save_date, "_master.rds"))

saveRDS(portfolio_master_sl,
        paste0("./data/weights/@history_master/",
               save_date, "_master_sl.rds"))

saveRDS(portfolio_master_sl,
        paste0("./data/weights/portfolio_master_sl.rds"))


