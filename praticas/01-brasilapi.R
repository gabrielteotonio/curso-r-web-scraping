library(httr)
library(httr2)
library(jsonlite)

# cep ---------------------------------------------------------------------


u_base <- "https://brasilapi.com.br/api"
endpoint_cep <- "/cep/v2/"

# vamos consultar um cep!!!
cep <- "79621450"

u_cep <- paste0(u_base, endpoint_cep, cep)

r_cep <- GET(u_cep)
r_cep

# como extraímos informações desse r_cep??

dados_cep <- httr::content(r_cep)
dados_cep$location$coordinates$longitude

content(r_cep)
cat(content(r_cep, as = "text"))
content(r_cep, as = "text")
content(r_cep, as = "raw")
content(r_cep, as = "parsed")

## com o httr2

req <- u_cep |>
  request()

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_cep) |>
  req_url_path_append(cep)

resp <- req |>
  req_perform(verbosity = 3)

resp |>
  resp_body_json()

# agora vamos pesquisar na tabela FIPE

endpoint_fipe <- "/fipe/marcas/v1/"
tipo_veiculo <- "carros"

u_fipe <- paste0(u_base, endpoint_fipe, tipo_veiculo)
r_fipe <- GET(u_fipe)

content(r_fipe, simplifyDataFrame = TRUE)

# equivalentes
content(r_fipe, "text") |>
  jsonlite::fromJSON(simplifyDataFrame = TRUE)

# salvando em arquivo
r_fipe <- GET(u_fipe, write_disk("output/marcas.json", overwrite = TRUE))

endpoint_fipe_tabelas <- "/fipe/tabelas/v1"
r_fipe_tabelas <- GET(paste0(u_base, endpoint_fipe_tabelas))


tabelas <- r_fipe_tabelas |>
  content(simplifyDataFrame = TRUE) |>
  tibble::tibble()

tabelas

# vamos pesquisar um preço!!
codigo_fipe <- "011196-1"
endpoint_preco <- "/fipe/preco/v1/"

u_preco <- paste0(u_base, endpoint_preco, codigo_fipe)

r_preco <- GET(u_preco)

r_preco |>
  content(simplifyDataFrame = TRUE) |>
  tibble::tibble() |> View()

# passando com um parâmetro

r_preco_parm <- GET(u_preco, query = list(
  tabela_referencia = "249"
))

## alternativa
# GET("https://brasilapi.com.br/api/fipe/preco/v1/011196-1?tabela_referencia=283")

r_preco_parm |>
  content(simplifyDataFrame = TRUE) |>
  tibble::tibble() |>
  View("preco_2019")

## com httr2!!

req <- u_base |>
  request() |>
  req_url_path_append(endpoint_preco) |>
  req_url_path_append(codigo_fipe) |>
  req_url_query(tabela_referencia = "249")

## executa a requisicao
resp <- req |>
  req_perform()

resp |>
  resp_body_json(simplifyDataFrame = TRUE) |>
  tibble::tibble()
