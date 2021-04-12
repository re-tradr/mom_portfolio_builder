

library(RSelenium)


#start remote server
rD <- rsDriver(browser = "chrome", 
               chromever = "86.0.4240.22", #86.0.4240.198
               port = netstat::free_port())
remDr <- rD$client


#login to page
login_url <- NA
remDr$navigate(login_url)
login_user <- remDr$findElement(using = 'css selector', "#Username")
login_user$sendKeysToElement(list("user"))
login_pw <- remDr$findElement(using = 'css selector', "#Password")
login_pw$sendKeysToElement(list("password"))
login_button <- remDr$findElement(using = 'css selector', 
                                  "button.c-button.c-button--large.c-button--block.c-button--uppercase.c-button--bold")
login_button$clickElement()


