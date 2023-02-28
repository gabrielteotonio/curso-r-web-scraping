library(httr2)
library(jsonlite)
library(dplyr)
library(stringr)

endpoint_base <- "https://brasilapi.com.br/api"

# 1. Acesse todos os bancos na API
# Dica: qual é o endpoint que devemos utilizar?

request(endpoint_base) |>
  req_url_path_append("/banks/v1") |>
  req_perform() |>
  resp_body_json(simplifyDataFrame = T) |>
  View("banks")


# 2. Pesquise o preço de um carro de interesse
# Dica: veja nos exemplos de aula uma forma de achar um código de carro
# Dica: qual endpoint devemos utilizar?

# Quero achar um Fiat Pulse
fipe_endpoint_base <- "https://parallelum.com.br/fipe/api"

fiat_code <- request(fipe_endpoint_base) |>
  req_url_path_append("/v1/carros/marcas") |>
  req_perform() |>
  resp_body_json(simplifyDataFrame = T) |>
  filter(str_detect(nome, regex("fiat", ignore_case = T))) |>
  pull(codigo)

fiat_models <- request(fipe_endpoint_base) |>
  req_url_path_append("/v1/carros/marcas") |>
  req_url_path_append(paste0("/", fiat_code, "/modelos")) |>
  req_perform() |>
  resp_body_json(simplifyDataFrame = T)

fiat_pulse_code <- fiat_models$modelos |>
  filter(str_detect(nome, regex("pulse", ignore_case = T))) |>
  filter(str_detect(nome, regex("drive", ignore_case = T))) |>
  filter(str_detect(nome, regex("1.0", ignore_case = T))) |>
  pull(codigo)

request(endpoint_base) |>
  req_url_path_append("/fipe/preco/v1") |>
  req_url_path_append(paste0("/", fiat_pulse_code)) |>
  req_perform() |>
  resp_body_json(simplifyDataFrame = T)

# 3. Pesquise o preço de um carro de interesse, mas na tabela de dez/2019
# você identificou alguma diferença?

# 4. Construa uma base de dados de todos os feriados nacionais entre 2000 e 2030
