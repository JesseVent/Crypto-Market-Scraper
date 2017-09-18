# This script will retrieve every cryptocurrency token and the closing market data for each day it has been active.
# Loading Packages
require(jsonlite)
require(dplyr)
require(doSNOW)
require(doParallel)
require(lubridate)

#Define parameters
file <- "~/Desktop/Crypto-Markets.csv"
cpucore <-
  as.numeric(detectCores(all.tests = FALSE, logical = TRUE))
today <- gsub("-", "", today())

# Get exchange rates
exchange_rate <- fromJSON("https://api.fixer.io/latest?base=USD")
AUD <- exchange_rate$rates$AUD
ptm <- proc.time()

# Retrieve listing of coin slugs to be used for searching.
# range <- 1:50 # uncomment this if you only was a specific number
json <-
  "https://files.coinmarketcap.com/generated/search/quick_search.json"
coins <- jsonlite::read_json(json, simplifyVector = TRUE)
length <- as.numeric(length(coins$slug))
range <- 1:length
coins <- head(arrange(coins, rank), n = range)
symbol <- coins$slug

# Setup population of URLS we will scrape the history for
url <-
  paste0(
    "https://coinmarketcap.com/currencies/",
    symbol,
    "/historical-data/?start=20130428&end=",
    today
  )
baseurl <- c(url)
urllist <- data.frame(url = baseurl, stringsAsFactors = FALSE)
attributes <- as.character(urllist$url)

# Start parallel processing
cluster = makeCluster(cpucore, type = "SOCK")
registerDoSNOW(cluster)

# Start scraping function to extract historical results table
abstracts <-
  function(attributes) {
    library(rvest)
    page <- read_html(attributes)
    names <-
      page %>% html_nodes(".col-sm-4 .text-large") %>% html_text(trim = TRUE) %>% replace(!nzchar(.), NA)
    nodes <-
      page %>% html_nodes("table") %>% .[1] %>% html_table(fill = TRUE)
    abstracts <- Reduce(rbind, nodes)
    abstracts$coinname = names
    names(abstracts) <-
      c("date",
        "open",
        "high",
        "low",
        "close",
        "volume",
        "market",
        "coin")
    return(abstracts)
  }

# Will combine data frames in parallel
results = foreach(i = range, .combine = rbind) %dopar% abstracts(attributes[i])

# Clean up
temp <- na.omit(results)
temp$volume <- as.numeric(gsub(",|-", "", temp$volume))
temp$market <- as.numeric(gsub(",|-", "", temp$market))
temp$date <- mdy(temp$date)
temp$volume <- as.numeric(temp$volume)
temp$market <- as.numeric(temp$market)
temp$open <- as.numeric(temp$open)
temp$close <- as.numeric(temp$close)
temp$high <- as.numeric(temp$high)
temp$low <- as.numeric(temp$low)
temp$coin <- as.factor(temp$coin)
marketdata <- temp

# Add columns with price in Australian dollars and open/close variance
marketdata$aud_open <- marketdata$open * AUD
marketdata$aud_close <- marketdata$close * AUD
marketdata$variance <-
  ((marketdata$aud_close - marketdata$aud_open) / marketdata$aud_close)
write.csv(marketdata, file)

# Stop the amazing parallel processing power
stopCluster(cluster)
print(proc.time() - ptm)
