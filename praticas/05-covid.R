library(tidyverse)
library(httr)

u_covid <- "https://covid.saude.gov.br/"
r <- httr::GET(u_covid,
               httr::write_disk("output/covid.html"))


u_rar <- "https://mobileapps.saude.gov.br/esus-vepi/files/unAFkcaNDeXajurGB7LChj8SgQYS2ptm/a1f358a1398a995f1e4d45b1803e91dd_HIST_PAINEL_COVIDBR_15set2022.rar"

GET(u_rar, httr::write_disk("output/dados_covid.rar"))


# automatizar a descoberta do link u_rar ----------------------------------

u_portal_geral <- "https://qd28tcd6b5.execute-api.sa-east-1.amazonaws.com/prod/PortalGeral"

r_portal_geral <- GET(
  u_portal_geral,
  httr::add_headers(
    "X-Parse-Application-Id" = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"
  )
  # httr::accept_json(),
  # httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:104.0) Gecko/20100101 Firefox/104.0")
)

r_portal_geral$headers

httr::user_agent()

link_rar <- content(r_portal_geral)$results[[1]]$arquivo$url

GET(link_rar, httr::write_disk("output/dados_covid.rar", overwrite = TRUE))


## coisas para olhar
# httr::accept_json()
# httr::user_agent()


# automatizar a coleta da chave -------------------------------------------


baixar_dados_do_dia <- function(arquivo = "output/dados_covid.rar") {
  js_com_chave <- "https://covid.saude.gov.br/main-es2015.js"
  r_javascript <- httr::GET(js_com_chave)
  chave <- r_javascript |>
    content("text", encoding = "UTF-8") |>
    stringr::str_extract("(?<=PARSE_APP_ID = ')[^']+")

  u_portal_geral <- "https://qd28tcd6b5.execute-api.sa-east-1.amazonaws.com/prod/PortalGeral"
  r_portal_geral <- GET(
    u_portal_geral,
    httr::add_headers("X-Parse-Application-Id" = chave)
  )
  link_rar <- content(r_portal_geral)$results[[1]]$arquivo$url
  GET(link_rar, httr::write_disk(arquivo, overwrite = TRUE))
}

resultado <- baixar_dados_do_dia()

if (resultado$status_code == 200) {
  ## faz alguma coisa
} else {
  ## faz outra coisa
}

## spoiler: modificando uma requisicao para tratar erros.
modificada <- purrr::safely(baixar_dados_do_dia)
modificada()

