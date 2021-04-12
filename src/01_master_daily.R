


source("utils.R")



# Download Data -----------------------------------------------------------



if (Sys.Date() %in% date_seq & 
    check_price_date() | 
    check_price_file() | 
    check_price_consistent()) {
    
    while(check_price_date() | check_price_file() | check_price_consistent()) {
        close_RSelenium()
        source("src/10_data_full.R")
    }

    if (check_price_missing()) {
        txt <- "'stock_prices' contains empty elements."
        writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
        stop(txt)
    }    
    if(check_price_consistent()) {
        txt <- "'stock_pices' length not multiple of entries in 'stock_table'."
        writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
        stop(txt)
    }

    source("src/11_stats_full.R") 
    
}


# Calculate Portfolio Weights ---------------------------------------------


source("utils.R")


if (Sys.Date() %in% date_seq) {
    
    if(file.mtime("./data/stock_prices_filt.rds") < Sys.Date()) {
        txt <- "'stock_prices_filt' not up to date."
        writeLines(txt, paste0("./messages/#", save_date, "_exit_error.txt"))
        stop(txt)
    }

    # Calculate filter weights --------------------------------------------
    source("src/21_stat_weights.R")
    source("src/22_fav_weights.R")
    source("src/23_rank_weights.R")
    source("src/24_strategy_weights.R")
    source("src/25_build_portfolio.R")
    
    rmarkdown::render("src/32_create_report.Rmd")
    source("src/33_cleanup.R")
    
} 

    

    
