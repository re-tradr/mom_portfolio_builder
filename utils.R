

library(magrittr)
library(quantmod)
library(PerformanceAnalytics)
library(ComplexHeatmap)
library(ggplot2)
library(tradr)


rm(list=ls())

options(warn = 0)
assign("last.warning", NULL, envir = baseenv())

Sys.setenv(TZ = "UTC")
Sys.setlocale(category = "LC_ALL", locale = "en_US.UTF-8")


period_oi <- "20140101::"
min_length <- 265

symbols_file <- "./tables/sp_table.csv"
cloud_dir <- "~/Library/Mobile Documents/com~apple~CloudDocs/$trading"
add_message(paste0(Sys.Date()))


# Exclude following entries -----------------------------------------------
                #  Cannabiswerte   E- Mobilitaet   E-Auto und dovon
isin_exclude <- NA #c("DE000LS9KC09", "DE000LS9MDY4", "DE000LS9PUL8")


# Determine Dates for Downloading Market Data -----------------------------

date_seq <- tradr::seq_date(as.Date("2014-01-01"), as.Date("2025-03-22"))

#nDays frames
ni1 <- seq(from = 1, to = length(date_seq), by = 10)
ni3 <- seq(from = 3, to = length(date_seq), by = 10)
ni5 <- seq(from = 5, to = length(date_seq), by = 10)
ni7 <- seq(from = 7, to = length(date_seq), by = 10)
ni9 <- seq(from = 9, to = length(date_seq), by = 10) 

date_seq_frame <- c(date_seq[ni1], date_seq[ni3], date_seq[ni5],
                    date_seq[ni7], date_seq[ni9]) %>% .[order(.)] 

save_date <- date_seq[date_seq <= Sys.Date()] %>% tail(1)

# NA xts
naxts <- matrix(c(NA,NA,NA,NA)) %>% t() %>%
    `colnames<-`(c("Open", "High", "Low", "Close"))
naxts %<>% xts(., order.by = Sys.Date()-50, dateFormat = "Date")

# if conditions for QC

check_price_file <- function () {
    !("stock_prices.rds" %in% list.files("./data"))
}

check_price_date <- function () {
    file.mtime("./data/stock_prices.rds") <
        (tradr::seq_date(Sys.Date()-6, Sys.Date()+6) %>%
        .[Sys.Date() >= tradr::seq_date(Sys.Date()-6, Sys.Date()+6)] %>% 
        last())
}

check_price_consistent <- function () {
        tryCatch({
            !all(
                (readRDS("./data/stock_prices.rds") %>% names()) ==
                    (read.csv(symbols_file,
                              stringsAsFactors = FALSE) %$% 
                         ISIN %>% unique())
                ) 
        }, error = function (e) {return(TRUE)})
}

check_price_missing <- function () {
    !all(sapply(readRDS("./data/stock_prices.rds"), dim)[1, ] != 0)
}


compare_last_index <- function (x, y) {
    
    indeces <- list(x, y) %>%
        lapply(function (z) {
            if (class(z)[1] == "list") {
                z %>% purrr::map(last) %>%
                    purrr::map(index) %>%
                    do.call(c, .) %>% table %>% 
                    sort(decreasing = TRUE) %>% .[1] %>%
                    names() %>% as.Date()
            } else {
                z %>% last() %>% index()
            }
            
        }) 
    indeces[[1]] == indeces[[2]]
}



# RSelenium utils

close_RSelenium <- function () {
    tryCatch({rD$server$stop()}, error = function (e) {NA})
    tryCatch({rm(rD); rm(remDr)}, error = function (e) {NA})
    tryCatch({gc()}, error = function (e) {NA})
}


# Plot heatmap

plot_heatmap <- function (x, col, ...) {
    
    if (col == "red") {
        color = colorRampPalette(rev(c('#931311', '#a5392b', '#b65646', 
                                       '#c67262', '#d48e7f', '#e1a99e', 
                                       '#ecc5bd', '#f6e2de', '#ffffff')))(100)
    }
    pheatmap::pheatmap(x, cluster_rows = FALSE, cluster_cols = FALSE,
                       color = color, ...)
}

plot_heatmap1 <- function (mat, limits, col = "red", main = NULL, probs = 0.75, ...) {
    
    mat <- as.matrix(mat)
    col_fun = circlize::colorRamp2(breaks = limits, c("white", col))
    Heatmap(mat, name = "mat",  col = col_fun, column_title = main,
            cluster_rows = FALSE, cluster_columns = FALSE,
            
            cell_fun = function(j, i, x, y, width, height, fill) {
                if(mat[i, j] >= (mat %>% quantile(probs = probs)))
                    grid.text(sprintf("%.2f", mat[i, j]), x, y, gp = gpar(fontsize = 8))
            })
}

plot_heatmap2 <- function (mat, limits, col = "red", main = NULL, ...) {
    mat <- as.matrix(mat)
    superheat::superheat(mat, 
                         title = main,
                         scale = FALSE,
                         heat.pal = c("white", col),  ##ff2a05
                         heat.lim = limits,
                         X.text = mat,
                         X.text.size = 3.5,
                         grid.hline = FALSE,
                         grid.vline = FALSE,
                         left.label.col = "white",
                         bottom.label.col = "white",
                         legend = FALSE,
                         column.title.size = 4,
                         row.title.size = 4,
                         ...)
}


