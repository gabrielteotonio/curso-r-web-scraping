library(tidyverse)
library(httr)

library(rtweet)

auth_setup_default()

trends <- get_trends()

# tuitar!!!

post_tweet(
  "Estou tuitando no curso de Web Scraping da @curso_r, usando o pacote {rtweet}! #rstats"
)

timeline <- get_timeline("hadleywickham")
pesquisa <- rtweet::search_tweets("federer")

da_users <- search_users("#rstats", n = 100)
