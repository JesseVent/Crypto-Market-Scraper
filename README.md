# Historical Cryptocurrency Prices (All Tokens) --DEPRECATED

## This version is now deprecated and I have now ported it over into a R package called crypto.
I've had to go over the code with a fine tooth comb to get it compatible with CRAN so there have been significant enhancements to how some of the field conversions have been undertaken and the data being cleaned. This should eliminate a few issues around number formatting or unexpected handling of scientific notations.

I hope you all find the package alot more intuitive and simpler to install and use. 

- [R Package: crypto](https://github.com/JesseVent/crypto) - Retrieve Cryptocurrency Prices from a R package.

### Quick and dirty install
```
devtools::install_github("jessevent/crypto")
library(crypto)
will_i_get_rich <- getCoins()
```

I regulary update the dataset at the following link: <br/>
<https://www.kaggle.com/jessevent/all-crypto-currencies>

## Features
- 1265 unique crypto currencies/tokens 
- 1,700 different days of market data
- 620000 glorious rows
- 12 variables
- Data current up until 7th November 2017

This script takes 380 seconds to run on my 2016 iMac, and has not been tested on a windows platform.

## Description
After not easily being able to find crypto market datasets I figured I'd do my part for the community and scrape my own.

This huge dataset contains all the daily details of the crypto-markets as they close for all the different crypto currencies and tokens listed on CoinMarketCaps historical tables. 

## My process
I used the amazing doSnow and doParallel packages which allowed me to call 2 APIs, scrape a ridiculous amount of lengthy HTML pages, all the data in around 5 minutes. I've included the link to the scraping script hosted on my GitHub repository below. Feel free to check it out <br/>
https://github.com/JesseVent/Crypto-Market-Scraper

## Content
The earliest date available is 28/04/2013 which is the earliest period coinmarketcap displays for any coin. In addition to the standard fields I've added two derived columns for open and close prices in $AUD as well as the variance between open and close prices.

Some particularly interesting things I noticed were how much the alt-coins fall when bitcoin rises dramatically (people pulling out of alt-coins to invest in bitcoin) and the beginning and ends of every calendar month seems to be when the market as a whole seems to gain the most.

    'data.frame':	620245 obs. of  12 variables:
     $ symbol    : chr  "$$$" "$$$" "$$$" "$$$" ...
     $ date      : chr  "2016-09-04" "2016-09-02" "2017-09-07" "2017-01-06" ...
     $ open      : num  0.000006 0.000011 0.001754 0.00003 0.001679 ...
     $ high      : num  0.000012 0.000011 0.001875 0.000037 0.001917 ...
     $ low       : num  0.000006 0.000006 0.001614 0.000027 0.001594 ...
     $ close     : num  1.20e+05 6.00e+06 1.67e-03 2.70e+05 1.76e-03 ...
     $ volume    : num  1 4 873 1 1467 ...
     $ market    : num  275 525 80499 1395 77047 ...
     $ name      : chr  "Money" "Money" "Money" "Money" ...
     $ ranknow   : num  814 814 814 814 814 814 814 814 814 814 ...
     $ variance  : num  1 1 -0.0503 1 0.0449 ...
     $ volatility: num  5.00e-11 8.33e-13 1.56e-01 3.70e-11 1.84e-01 ...

## Closing Comments
Thanks to the team at <https://coinmarketcap.com> for the great work they do and to the team at CoinTelegraph where the images were sourced.

Please star this if you find it useful, and remember the crypto currency market is volatile by nature, please be responsible if trading.

If by chance you do manage to make your fortune through some game-changing model, I'd appreciate your consideration in the below :)

BTC: 1LPjH7KyH5aD65pTBhByXFCFXZNTUVdeRY <br/>
ETH: 0x375923Bf82F0b728d23A5704261a6e16341fd860
