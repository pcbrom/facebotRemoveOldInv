# remove old invitations


library(RSelenium)
library(rvest)
library(stringr)

user <- ''
pass <- ''


rD = rsDriver(browser = "firefox", check = F, verbose = F)
remDr = rD[["client"]]


# login

remDr$navigate('https://www.facebook.com/friends')
webElem <- remDr$findElement(using = 'xpath', "//input[@id='email']")
webElem$sendKeysToElement(list(user))

webElem <- remDr$findElement(using = 'xpath', "//input[@id='pass']")
webElem$sendKeysToElement(list(pass))

webElem <- remDr$findElement(using = 'xpath', "//button[@id='loginbutton']")
webElem$clickElement()


# delete invitations

Sys.sleep(5)
suppressWarnings({
  base <- remDr$getPageSource()[[1]] %>% 
    read_html()
  x <- base %>% 
    html_nodes("div span") %>% 
    str_subset('Ver solicita') %>% 
    str_extract('"\\s*(.*?)\\s*"') %>% 
    str_remove_all('\"') %>% 
    paste0("//span[@class='", ., "']")
})

webElem <- remDr$findElement(using = 'xpath', x)
webElem$clickElement()
Sys.sleep(2)


###############################################################################

# !!! manual step !!!

# sent requests
N <- 123

# first person listed, just copy and paste link
firt_person <- 'https://www.facebook.com/...'

###############################################################################


# going forward it's automatic

suppressWarnings({
  base <- remDr$getPageSource()[[1]] %>% 
    read_html()
  x <- base %>% 
    html_nodes("div a") %>% 
    html_attr('href') %>% 
    str_subset('https://www.facebook.com/')
})
x <- x[-(1:(grep(firt_person, x) - 1))]

countN <- 0
for (i in x) {
  
  print(paste0(round(100 * countN/length(x)), ' %'))
  countN <- countN + 1
  
  remDr$navigate(i)
  Sys.sleep(3)
  webElem <- remDr$findElement(using = 'xpath', x[i])
  
  suppressWarnings({
    base <- remDr$getPageSource()[[1]] %>% 
      read_html()
    y <- base %>% 
      html_nodes("div span") %>% 
      str_subset('Cancelar')
    y <- y[2] %>% 
      str_extract('"\\s*(.*?)\\s*"') %>% 
      str_remove_all('\"') %>% 
      paste0("//span[@class='", ., "']")
  })
  webElem <- remDr$findElement(using = 'xpath', "//div[@aria-label='Cancelar solicitação']")
  webElem$clickElement()
  Sys.sleep(3)
  
}


# close process

remDr$close()
rD[["server"]]$stop()
