require(jsonlite)
require(dplyr)
require(doSNOW)
require(doParallel)
require(lubridate)

# Define parameters
file <- "~/Desktop/Crypto-Markets.csv"
cpucore <-
  as.numeric(detectCores(all.tests = FALSE, logical = TRUE))
today <- gsub("-", "", today())
exchange_rate <- fromJSON("https://api.fixer.io/latest?base=USD")
AUD <- exchange_rate$rates$AUD
ptm <- proc.time()
json <-
  "https://files.coinmarketcap.com/generated/search/quick_search.json"
coins <- jsonlite::read_json(json, simplifyVector = TRUE)
length <- as.numeric(length(coins$slug))
#length <- 50
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
cluster = makeCluster(cpucore, type = "SOCK", outfile = "")
registerDoSNOW(cluster)

# Display progress bar
pb <- txtProgressBar(min = 1, max = length, style = 3)

# Start scraping function
abstracts <- function(attributes) {
  library(rvest)
  page <- read_html(attributes)
  names <-
    page %>% html_nodes(css = ".col-sm-4 .text-large") %>% html_text(trim = TRUE) %>%
    replace(!nzchar(.), NA)
  nodes <-
    page %>% html_nodes(css = "table") %>% .[1] %>% html_table(fill = TRUE) %>%
    replace(!nzchar(.), NA)
  abstracts <- Reduce(rbind, nodes)
  
  # Splitting up the scraped names and cleaning them up nicely.
  abstracts$names <- gsub("\\(||\\n|\\)|\\s\\s", "", names)
  abstracts$coin <-
    as.character(strsplit(abstracts$names, " ")[[1]][1])
  namelength <- as.numeric(lengths(strsplit(abstracts$names, " ")))
  namearray <- strsplit(abstracts$names, " ")[[1]][2:namelength]
  abstracts$coinname <-
    paste(setdiff(namearray, abstracts$coin), collapse = " ")
  names(abstracts) <-
    c("date",
      "open",
      "high",
      "low",
      "close",
      "volume",
      "market",
      "symbol",
      "coin")
  return(abstracts)
}

# Bind parallel dataframes and transform into results.
results = foreach(i = range, .combine = rbind) %dopar%
{
  setTxtProgressBar(pb, i)
  abstracts(attributes[i])
}
close(pb)
stopCluster(cluster)
print(proc.time() - ptm)

# Clean up all the fields.
names(results) <-
  c("date",
    "open",
    "high",
    "low",
    "close",
    "volume",
    "market",
    "name",
    "symbol",
    "coin")
marketdata <- subset(results, select = -c(name))
marketdata$volume <- gsub("\\,", "", marketdata$volume)
marketdata$market <- gsub("\\,", "", marketdata$market)
marketdata$volume <- gsub("\\-", "0", marketdata$volume)
marketdata$market <- gsub("\\-", "0", marketdata$market)
marketdata$close <- gsub("\\-", "0", marketdata$close)
marketdata$date <-
  format(strptime(marketdata$date, format = "%b %d,%Y"), "%Y-%m-%d")
marketdata$open <- as.numeric(marketdata$open)
marketdata$close <- as.numeric(marketdata$close)
marketdata$high <- as.numeric(marketdata$high)
marketdata$low <- as.numeric(marketdata$low)
marketdata$volume <- as.numeric(marketdata$volume)
marketdata$market <- as.numeric(marketdata$market)

# Percent variance between open and close rates
marketdata$variance <-
  ((marketdata$close - marketdata$open) / marketdata$close)

# Market spread variance between days high, low and closing
marketdata$volatility <-
  ((marketdata$high - marketdata$low) / marketdata$close)

# Export dataset to CSV and finish timing
write.csv(marketdata, file)
print(proc.time() - ptm)
