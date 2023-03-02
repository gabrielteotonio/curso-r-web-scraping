# 1. Escreva uma função que recebe uma data e retorna a tabela dos mananciais

library(httr2)
library(dplyr)
library(janitor)

get_sabesp_by_date <- function(date) {
  api_endpoint <- "http://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"

  request_result <- request(api_endpoint) |>
    req_url_path_append(date) |>
    req_options(ssl_verifypeer = 0) |>
    req_perform() |>
    resp_body_json(simplifyDataFrame = T)

  request_result$ReturnObj$sistemas |>
    clean_names() |>
    tibble() |>
    transmute(nome = as.factor(nome),
              volume = as.double(volume_porcentagem))
}

result <- get_sabesp_by_date("2022-09-01")
View(result)

# 2. Armazene no objeto tab_sabesp a tabela do dia `Sys.Date() - 1` (ontem)

tab_sabesp <- get_sabesp_by_date(Sys.Date() - 1)

# 3. [extra] Arrume os dados para que fique assim:

glimpse(tab_sabesp)

# Observations: 7
# Variables: 2
# $ nome   <fct> Cantareira, Alto Tietê, Guarapiranga, Cotia, Rio Grande, Rio Claro, São Lourenço
# $ volume <dbl> 63.25681, 90.35307, 84.25839, 102.28429, 93.66445, 99.85615, 97.33682
