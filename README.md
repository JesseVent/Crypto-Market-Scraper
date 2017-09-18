# Closing market rate for every crypto currency
## Features
- 1,111 Crypto currencies/tokens
- Every day of tokens life
- 509,000 glorious rows
- 11 variables
- Full and regulary updated dataset available on Kaggle

## Description
After not easily being able to find crypto market datasets I figured I'd do my part for the community and scrape my own.

This script provides a huge dataset contains all the daily details of the crypto-markets as they close for over 878 different crypto currencies and tokens. If it is built off of the block chain it should be available in this set, no matter how new or old it is.

## My process
I collected this data by using R to extract the names of all the tokens from a CMC API, then use the token names to go scrape CMC's historical data tables for each token. I did a na.omit on all rows to clean the data because some of it was missing. This reduced row count from 487363 to 419671 rows.

I used the amazing doSnow and doParallel packages which allowed me to call 2 APIs, scrape lengthy HTML tables from 1060 pages, and return 487363 rows in only 5 minutes. I've included the link to the actual dataset that I have uploaded onto kaggle. Feel free to check it out <br/>

## Content
The earliest date available is 28/04/2013 up until 15/08/2017 which is the earliest period coinmarketcap displays for any coin. In addition to the standard fields I've added two derived columns for open and close prices in $AUD as well as the variance between open and close prices.

Some particularly interesting things I noticed were how much the alt-coins fall when bitcoin rises dramatically (people pulling out of alt-coins to invest in bitcoin) and the beginning and ends of every calendar month seems to be when the market as a whole seems to gain the most.

## Data Samples
$ date : Date "2017-08-14" "2017-08-13" "2017-08-12" "2017-08-11" <br/> 
$ open : num 4066 3880 3651 3374 3342<br/>
$ high : num 4325 4208 3950 3680 3453<br/>
$ low : num 3989 3858 3614 3372 3319<br/>
$ close : num 4325 4073 3885 3651 3381<br/>
$ volume : num 2.46e+09 3.16e+09 2.22e+09 2.02e+09 1.52e+09<br/>
$ market : num 6.71e+10 6.40e+10 6.02e+10 5.57e+10 5.51e+10<br/>
$ coin : Factor w/ 878 levels "020LondonCoin (020)",..: 85 85 85 85 85 85 85 85 85 85<br/>
$ aud_open : num 5165 4929 4637 4286 4245<br/>
$ aud_close: num 5494 5174 4935 4637 4295<br/>
$ variance : num 0.0599 0.0474 0.0603 0.0758 0.0117


## Closing Comments
Thanks to the team at <https://coinmarketcap.com> for the great work they do and to the team at CoinTelegraph where the images were sourced.

Please star this if you find it useful, and remember the crypto currency market is volatile by nature, please be responsible if trading.

If by chance you do manage to make your fortune through some game-changing model, I'd appreciate your consideration in the below :)

BTC: 1LPjH7KyH5aD65pTBhByXFCFXZNTUVdeRY <br/>
ETH: 0x375923Bf82F0b728d23A5704261a6e16341fd860
