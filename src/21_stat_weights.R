


source("utils.R")



# Parameter ---------------------------------------------------------------

# rolling stats filter
print("Annual Return Percentile Filter:")
(perf_perc_larger <- 0.8)
print("Annual Return Filter:")
(ann_return_filter <- 0.05)
print("N-Crash Filter:")
n_crash_filter <- 1


# Load Data ---------------------------------------------------------------

# load stock table and prices
stock_table <- readRDS("./data/stock_table_filt_stats.rds")
stock_prices <- readRDS("./data/stock_prices_filt.rds")

stock_table %<>% dplyr::filter(!ISIN %in% isin_exclude)
stock_prices %<>% .[!names(stock_prices) %in% isin_exclude]


# Check Price Data Integrity ----------------------------------------------

if (dim(stock_table)[1] != length(stock_prices)) {
    txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}
tradr::add_message(paste0(
    dim(stock_table)[1],
    " entries used for statistics based weights calculation."
))


# Calculate Rolling Stats -------------------------------------------------

stock_stats <- lapply(stock_prices, function (x) {
    x_data <- dailyReturn(Cl(x)) %>%
        na.fill(fill = 0)
    x_data$cum_dd <- x_data$daily.returns %>% PerformanceAnalytics::Drawdowns() %>%
        cummin()
    x_data$cum_returns <- x_data$daily.returns %>% cumsum()
    x_data$one <- 1
    x_data$years <- x_data$one %>% cumsum()/255
    x_data$ann_return_k150 <- (x_data$cum_returns / x_data$years) %>% 
        rollmean(., k=150, align="right") %>% 
        na.fill(fill = 0)
    x_data$ann_return_k200 <- (x_data$cum_returns / x_data$years) %>% 
        rollmean(., k=200, align="right") %>% 
        na.fill(fill = 0)
    x_data$ann_return_k250 <- (x_data$cum_returns / x_data$years) %>% 
        rollmean(., k=250, align="right") %>% 
        na.fill(fill = 0)
    x_data$n_crash <- cbind(sum(index(x) < as.Date("2015-04-15")) > 0 &
                                !(index(x) < as.Date("2016-08-15")),
                            sum(index(x) < as.Date("2018-01-23")) > 0 &
                                !(index(x) < as.Date("2019-04-16")),
                            sum(index(x) < as.Date("2020-02-19")) > 0 &
                                !(index(x) < as.Date("2020-05-25"))) %>%
        rowSums()
    x_data
})

tmp <- purrr::map(stock_stats, ~.x$ann_return_k150) %>%
    do.call(cbind.xts, .) %>%
    na.fill(fill = 0) %>%
    apply(., 1,
          function (x) {
              percentile <- x %>% as.numeric() %>% ecdf() 
              x %>% percentile()
          }) %>%
    t() %>% as.xts(dateFormat = "Date") %>%
    as.list() %>%
    lapply(., setNames, "perf_k150_percentile")
stock_stats %<>% purrr::map2(., tmp, cbind.xts)

tmp <- purrr::map(stock_stats, ~.x$ann_return_k200) %>%
    do.call(cbind.xts, .) %>%
    na.fill(fill = 0) %>%
    apply(., 1,
          function (x) {
              percentile <- x %>% as.numeric() %>% ecdf() 
              x %>% percentile()
          }) %>%
    t() %>% as.xts(dateFormat = "Date") %>%
    as.list() %>%
    lapply(., setNames, "perf_k200_percentile")
stock_stats %<>% purrr::map2(., tmp, cbind.xts)

tmp <- purrr::map(stock_stats, ~.x$ann_return_k250) %>%
    do.call(cbind.xts, .) %>%
    na.fill(fill = 0) %>%
    apply(., 1,
          function (x) {
              percentile <- x %>% as.numeric() %>% ecdf() 
              x %>% percentile()
          }) %>%
    t() %>% as.xts(dateFormat = "Date") %>%
    as.list() %>%
    lapply(., setNames, "perf_k250_percentile")
stock_stats %<>% purrr::map2(., tmp, cbind.xts)


# Statistics-based Weights ------------------------------------------------

stock_stat_weights <- lapply(stock_stats, function (x) {
    x_weights <- cbind.xts(
        cbind.xts(
            x$perf_k150_percentile >= perf_perc_larger,
            x$perf_k200_percentile >= perf_perc_larger,
            x$perf_k250_percentile >= perf_perc_larger
        ) %>% rowSums() %>% `>=`(1),
        x$ann_return_k200 >= ann_return_filter,
        x$n_crash >= n_crash_filter
    ) 
    x_weights$weights <- ifelse(rowSums(x_weights)/ncol(x_weights) < 1, 0, 1)
    l <- ifelse(length(x_weights$weights) < 185, length(x_weights$weights), 185)
    x_weights$weights[1:l] <- 0
    x_weights$weights
}) %>%
    do.call(cbind.xts, .) %>%
    'colnames<-'(names(stock_stats)) 

stock_stat_weights %<>% 
    na.locf(na.rm = FALSE) %>%
    na.fill(fill = 0) %>%
    .[period_oi]

stock_stat_weights %>% last() %>% .[, order(.)] 



# QC and Report -----------------------------------------------------------

if (!compare_last_index(stock_stat_weights, stock_prices)) {
    txt <- "Last index in 'stock_stat_weights' not as expected."
    writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
    stop(txt)
}

tradr::add_message(paste0(
    stock_stat_weights %>% last() %>% .[, .!=0] %>% length(),
    " entries in statistics based weights fraction."
))

if (length(warnings()) > 0) {
    tradr::add_message(names(warnings()))
}

saveRDS(messages, 
        file = paste0("./messages/", save_date, "_{21}_messages.rds"))

saveRDS(stock_stat_weights,
        paste0("./data/weights/@history_stat_weights/",
               save_date, "_stat_weights.rds"))


# Save Results ------------------------------------------------------------

saveRDS(stock_stat_weights, 
        paste0("./data/weights/stock_stat_weights.rds"))


