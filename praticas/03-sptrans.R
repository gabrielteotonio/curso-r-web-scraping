
library(tidyverse)
library(httr)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint <- "/Posicao"

u_sptrans_busca <- paste0(u_sptrans, endpoint)

r_sptrans <- GET(u_sptrans_busca)

httr::content(r_sptrans)

api_key <- "4af5e3112da870ac5708c48b7a237b30206806f296e1d302e4cb611660e2e03f"

api_key <- Sys.getenv("API_OLHO_VIVO")

# como que faz para usar essa api_key???

endpoint_auth <- "/Login/Autenticar"
query_login <- list(token = api_key)

u_sptrans_login <- paste0(u_sptrans, endpoint_auth)

r_sptrans_login <- POST(
  u_sptrans_login,
  query = query_login
)

content(r_sptrans_login, "text")

# nessa parte, uma mágica aconteceu
# o httr trabalhou as sessoes e os cookies

r_sptrans <- GET(u_sptrans_busca)


# gerenciamento de chaves -------------------------------------------------

## usethis::edit_r_environ("project")
api_key <- Sys.getenv("API_OLHO_VIVO")

## avançado
chave <- httr2::secret_make_key()
encriptado <- httr2::secret_encrypt(api_key, chave)
httr2::secret_decrypt(encriptado, chave)
# login <- "julio"
# senha <- "minhasenha"

## alternativa
# pacote {sodium}


# alternativa httr2 -------------------------------------------------------

library(httr2)

u_sptrans <- "http://api.olhovivo.sptrans.com.br/v2.1"
endpoint_auth <- "/Login/Autenticar"
api_key <- Sys.getenv("API_OLHO_VIVO")

req_base <- u_sptrans |>
  request()

req_login <- req_base |>
  req_url_path_append(endpoint_auth) |>
  req_url_query(token = api_key) |>
  req_body_form(x = NULL)

resp_login <- req_login |>
  req_perform()

# ok!

resp_login |>
  resp_body_string()

endpoint <- "/Posicao"
req_busca <- req_base |>
  req_url_path_append(endpoint)

# não funciona! dá 401
resp_busca <- req_busca |>
  req_perform()

# passando o cookie manualmente
req_busca <- req_base |>
  req_url_path_append(endpoint) |>
  req_headers(
    Cookie = resp_login$headers$`Set-Cookie`
  )

resp_busca <- req_busca |>
  req_perform()


resultado <- resp_busca |>
  resp_body_json(simplifyDataFrame = TRUE)

resultado$l$vs |>
  dplyr::bind_rows() |>
  tibble::tibble() |>
  ggplot2::ggplot() +
  ggplot2::aes(px, py) +
  ggplot2::geom_point(alpha = .2) +
  ggplot2::coord_fixed()
