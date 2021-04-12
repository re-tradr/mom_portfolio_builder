


list.files("tables/", full.names = TRUE) %>%
    .[grepl("WFWIKIBOXX-account-statement", x=.)] %>%
    tail(1) %>%
    read.csv2(., header = TRUE, sep = ";", skip = 4,
              fileEncoding = "UCS-4-INTERNAL",
              stringsAsFactors = FALSE) %>%
    `<<-`("statement", .)


statement$Datum <- lubridate::dmy_hms(statement$Datum)
statement$day <- as.Date(statement$Datum)

wikifol_prices <- readRDS(file = "./data/wf_prices.rds")

#volume
statement$volume <- statement$`Änderung.Anzahl` * statement$Preis
volume_buy <- statement %>% dplyr::filter(volume > 0) 
volume_buy$volume %>% xts(., order.by=volume_buy$day) %>%
    apply.daily(sum) %>%
    plot()

#spread history
spread_list <- list()
for (i in 1:dim(statement)[1]) {
    op_price <- wikifol_prices[[statement[i, ]$ISIN]] %>% Op() %>%
        .[statement[i, ]$day]
    spread_list[[i]] <- statement[i, ]$Preis/op_price # %>% as.numeric()
}

spread_list %>% do.call(rbind, .) %>% hist(breaks=50)
spread_list %>% do.call(rbind, .) %>% colMeans()
spread_list %>% do.call(rbind, .) %>% apply.daily(., mean) %>% plot()


