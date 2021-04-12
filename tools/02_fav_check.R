


source("utils.R")



# Load Wikifolio Table and Prices -----------------------------------------

wf_table <- readRDS("./data/wf_table_filt_stats.rds")
wf_prices <- readRDS("./data/wf_prices_filt.rds")



# Lookup Top Ten Trader and Bestseller ------------------------------------

source("./utils_startRS.R")

#lookup wikifolio top ten trader
wiki_url <- paste0("https://www.wikifolio.com/de/de/alle-wikifolios/suche#/",
                   "?tags=top-ten-t,aktde,akteur,aktusa,akthot,aktint,etf,",
                   "fonds,anlagezert,hebel&private=true&super=true&media=true",
                   "&assetmanager=true&theme=true&WithoutLeverageProductsOnly=true",
                   "&languageOnly=true&ISIN=")
remDr$navigate(wiki_url)
Sys.sleep(20)

html_txt <- remDr$getPageSource()                       #scrape page
favs_top10 <- stringr::str_extract_all(html_txt, "DE000LS9[:alnum:]{4}") %>%
    unlist() %>% unique()

#lookup wikifolio bestseller
wiki_url <- paste0("https://www.wikifolio.com/de/de/alle-wikifolios/suche#/",
                   "?tags=bestseller,aktde,akteur,aktusa,akthot,aktint,etf,", 
                   "fonds,anlagezert,hebel&private=true&super=true&media=true", 
                   "&assetmanager=true&theme=true&WithoutLeverageProductsOnly=true", 
                   "&languageOnly=true&ISIN=")
remDr$navigate(wiki_url)
Sys.sleep(5)

webElem <- remDr$findElement("css", "body")             #scroll down
webElem$sendKeysToElement(list(key = "down_arrow"))
Sys.sleep(5)
webElem <- remDr$findElement(using = 'css selector',    #disclaimer
                             "div.c-button.c-button--bold.c-button--cursor-pointer.js-disclaimer__change")
webElem$clickElement()
Sys.sleep(3)

tryCatch({
    webElem <- remDr$findElement(using = 'css selector',    #load more entries
                                 "button.c-button.js-search-load-more.gtm-wf-search__load-more")
    webElem$clickElement()
}, error = function (e) {})
Sys.sleep(5)

html_txt <- remDr$getPageSource()                       #scrape page
favs_bestseller <- stringr::str_extract_all(html_txt, "DE000LS9[:alnum:]{4}") %>%
    unlist() %>% unique()

rD$server$stop(); rm(rD); rm(remDr); gc()


# Save current favourites -------------------------------------------------

saveRDS(favs_selection, 
        paste0("./data/favs/", 
               date_seq_frame[date_seq_frame <= Sys.Date()] %>% last(),
               "_favs_selection.rds"))
saveRDS(favs_bestseller, 
        paste0("./data/favs/", 
               date_seq_frame[date_seq_frame <= Sys.Date()] %>% last(),
               "_favs_bestseller.rds"))
saveRDS(favs_top10, 
        paste0("./data/favs/",
               date_seq_frame[date_seq_frame <= Sys.Date()] %>% last(),
               "_favs_top10.rds"))




# Save Data ---------------------------------------------------------------

saveRDS(wf_fav_weights, 
        paste0("./data/stat_weights/wf_fav_weights_s05_", nframe, ".rds"))

rm(list=setdiff(ls(), c("messages", "date_seq", "date_seq_frame",  
                        "ni1", "ni3", "ni5", "ni7", "ni9", "nframe")))


