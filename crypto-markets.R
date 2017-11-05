require(jsonlite)
require(dplyr)
require(doSNOW)
require(lubridate)
# Functions ---------------------------------------------------------------
# Retrieve Coin Listings -----
getCoins <- function() {
     library(plyr)
     today <- gsub("-", "", today())
     json <- "https://files.coinmarketcap.com/generated/search/quick_search.json"
     coins <- jsonlite::read_json(json, simplifyVector = TRUE)
     coins <- data_frame(symbol = coins$symbol, name = coins$name, slug = coins$slug,
          rank = coins$rank)
     length <- as.numeric(length(coins$slug))
     range <- 1:length
     url <- paste0("https://coinmarketcap.com/currencies/", coins$slug, "/historical-data/?start=20130428&end=",
          today)
     baseurl <- c(url)
     coins$slug <- as.character(baseurl)
     coins$rank <- as.numeric(coins$rank)
     return(coins)
}
# Scrape Historical Tables -----
abstracts <- function(attributes) {
     page <- read_html(attributes)
     names <- page %>% html_nodes(css = ".col-sm-4 .text-large") %>% html_text(trim = TRUE) %>%
          replace(!nzchar(.), NA)
     nodes <- page %>% html_nodes(css = "table") %>% .[1] %>% html_table(fill = TRUE) %>%
          replace(!nzchar(.), NA)
     abstracts <- Reduce(rbind, nodes)
     abstracts$symbol <- gsub("\\(||\\n|\\)|\\s\\s", "", names)
     abstracts$symbol <- as.character(strsplit(abstracts$symbol, " ")[[1]][1])
     return(abstracts)
}
# Cleanup results table -----
cleanUp <- function(results) {
     names(results) <- c("symbol", "name", "ranknow", "date", "open", "high", "low",
          "close", "volume", "market")
     marketdata <- results
     marketdata$volume <- gsub("\\,", "", marketdata$volume)
     marketdata$market <- gsub("\\,", "", marketdata$market)
     marketdata$volume <- gsub("\\-", "0", marketdata$volume)
     marketdata$market <- gsub("\\-", "0", marketdata$market)
     marketdata$close <- gsub("\\-", "0", marketdata$close)
     marketdata$date <- format(strptime(marketdata$date, format = "%b %d,%Y"), "%Y-%m-%d")
     marketdata$open <- as.numeric(marketdata$open)
     marketdata$close <- as.numeric(marketdata$close)
     marketdata$high <- as.numeric(marketdata$high)
     marketdata$low <- as.numeric(marketdata$low)
     marketdata$volume <- as.numeric(marketdata$volume)
     marketdata$market <- as.numeric(marketdata$market)
     # Percent variance between open and close rates
     marketdata$variance <- ((marketdata$close - marketdata$open)/marketdata$close)
     # spread variance between days high, low and closing
     marketdata$volatility <- ((marketdata$high - marketdata$low)/marketdata$close)
     return(marketdata)
}

# START CRYPTOCURRENCY SCRAPING SCRIPT ------------------------------------
# Crypto Scraping Setup ---------------------------------------------------
file <- "~/Desktop/Crypto-Markets.csv"
coins <- getCoins()
length <- as.numeric(length(coins$slug))
range <- 1:length
cpucore <- as.numeric(detectCores(all.tests = FALSE, logical = TRUE))
ptm <- proc.time()

# Parallel process scraping with progress bar -----------------------------
cluster = makeCluster(cpucore, type = "SOCK")
registerDoSNOW(cluster)
pb <- txtProgressBar(max = length, style = 3)
progress <- function(n) setTxtProgressBar(pb, n)
opts <- list(progress = progress)
attributes <- coins$slug

# Combine results and stop clusters ---------------------------------------
results = foreach(i = range, .options.snow = opts, .combine = rbind, .packages = "rvest") %dopar%
     abstracts(attributes[i])
close(pb)
stopCluster(cluster)

# Cleanup results and fix names -------------------------------------------
coinnames <- data_frame(symbol = coins$symbol, name = coins$name, rank = coins$rank)
results <- merge(results, coinnames)
marketdata <- cleanUp(results)
write.csv(marketdata, file, row.names = FALSE)
print(proc.time() - ptm)
