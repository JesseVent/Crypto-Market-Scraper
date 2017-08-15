# This script will scrape all of the market close data each day for all the cryptocurrencies listed on CMC.
#Load dependencies.
require(jsonlite)
require(dplyr)
require(doSNOW)
require(doParallel)
require(lubridate)

# Define parameters.
file <- "~/Desktop/crypto-markets.csv"
range <-
  1:50  # If you dont want to get the entire lot change this to like 1:100.
cpu <-
  as.numeric(detectCores())  # I'm running 4 cores, but this should pick up your max-cores.
ptm <- proc.time()

# Get USD to AUD exchange rate.
rate <- fromJSON("https://api.fixer.io/latest?base=USD")
aud <- rate$rates$AUD

# Retrieve listing of top {RANGE} of coins and get slugs to be used for searching.
json <-
  "https://files.coinmarketcap.com/generated/search/quick_search.json"
coins <-
  jsonlite::read_json(json, simplifyVector = TRUE) %>% head(arrange(coins,
                                                                    rank), n = max(range))
symbol <- coins$slug

# Setup population of urls to scrape the historic tables.
url <-
  paste0(
    "https://coinmarketcap.com/currencies/",
    symbol,
    "/historical-data/?start=20130428&end=20170815"
  )
attr <- c(url)

# Start parallel processing!!!
cluster <- makeCluster(cpu, type = "SOCK")
registerDoSNOW(cluster)

# Start scraping function to extract historical results table.
abstracts <- function(attr) {
  library(rvest)
  page <- read_html(attr)
# Get coin name.
  names <-
    page %>% html_nodes(".col-sm-4 .text-large") %>% html_text(trim = TRUE) %>%
    replace(!nzchar(.), NA)
# Get historical data.
  nodes <-
    page %>% html_nodes("table") %>% .[1] %>% html_table(fill = TRUE)
# Combine the two and normalise names.
  abstracts <- Reduce(rbind, nodes)
  abstracts$coinname <- names
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
# This took me ages to work out how to do nicely, but will combine data frames in parallel.
results <-
  foreach(i = range, .combine = rbind) %dopar% abstracts(attr[i])

# Clean up on aisle temp
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
marketdata <- na.omit(temp)

# Add columns with price in Australian dollars and open/close variance
marketdata$aud_open <- marketdata$open * aud
marketdata$aud_close <- marketdata$close * aud
marketdata$variance <-
  ((marketdata$aud_close - marketdata$aud_open) / marketdata$aud_close)
write.csv(marketdata, file)

# Stop the amazing parallel processing power
stopCluster(cluster)
print(proc.time() - ptm)
