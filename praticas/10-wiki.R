library(purrr)
library(xml2)

urls <- c(
  "https://en.wikipedia.org/wiki/R_language",
  "https://en.wikipedia.org/wiki/Python_(programming_language)"
)
urls |>
  map(read_html) |>
  map(xml_find_first, "//h1") |>
  map_chr(xml_text)

# purrr::map

purrr::map_chr(1:10, \(x) x)
purrr::map_dbl(1:10, \(x) x)
purrr::map_lgl(1:10, \(x) sample(c(TRUE, FALSE), 1))
purrr::map_int(1:10, \(x) x)
purrr::map_raw(1:10, \(x) as.raw(x)) # pouco usado
## futuramente aposentados
purrr::map_dfr(1:10, \(x) tibble::tibble(elemento = x))
purrr::map_dfc()


# antes do novo purrr
purrr::map(1:10, \(x) tibble::tibble(elemento = x)) |>
  dplyr::bind_rows()

# no novo purrr
# remotes::install_github("tidyverse/purrr")
purrr::map(1:10, \(x) tibble::tibble(elemento = x)) |>
  purrr::list_rbind()


# purrr::map2

purrr::map2_dbl(
  1:10, 21:30,
  \(x,y) x * y
)

purrr::map2_dbl(
  1:10, 21:30,
  ~.x * .y
)

# purrr::walk

purrr::walk(1:10, \(x) print(x))

# tratamento de erros -----------------------------------------------------

funcao <- function(x) {
  log(x)
}

talvez_log <- purrr::possibly(funcao, NA)
safe_log <- purrr::safely(funcao, NA)
quieto_log <- purrr::quietly(funcao)


purrr::map(list(0, -1, 3, "a"), talvez_log)

purrr::map(list(0, -1, 3, "a"), safe_log)

purrr::map(list(0, -1, 3, "a"), quieto_log)

purrr::map(list(0, -1, 3), quieto_log)

# exemplo -----------------------------------------------------------------


u_wiki <- "https://en.wikipedia.org/wiki/R_language"

r_wiki <- httr::GET(u_wiki)

links <- r_wiki |>
  xml2::read_html() |>
  xml2::xml_find_all("//*[@class='infobox vevent']//a") |>
  xml2::xml_attr("href")

links <- paste0("https://en.wikipedia.org", links)

head(links)

caminhos <- paste0("output/wiki/", seq_along(links), ".html")

baixar_link <- function(link, caminho) {
  # Sys.sleep(1) ## dorme um segundo
  httr::GET(link, httr::write_disk(caminho))
}

maybe_baixar_link <- purrr::possibly(baixar_link, "erro")

purrr::map2(links, caminhos, maybe_baixar_link)

itens_que_deram_erro <- fs::dir_ls("output/wiki") |>
  fs::file_info() |>
  dplyr::filter(size == 0) |>
  dplyr::pull(path) |>
  fs::path_ext_remove() |>
  fs::path_file()

#' cuidado 1: nem sempre o erro é culpa do servidor
#' as vezes o erro é no seu código
#' solução -> fazer alguns testes antes de rodar tudo
#'
#' cuidado 2: o erro pode ser do servidor, mas por conta
#' de bloqueio de IP
#' solução -> fazer requisições com um tempo maior entre as chamadas

## tratando erros dentro da função

baixar_link <- function(link, caminho) {
  # Sys.sleep(1) ## dorme um segundo

  talvez_get <- purrr::possibly(httr::GET, NULL)
  resultado <- talvez_get(link, httr::write_disk(caminho))
  if (is.null(resultado)) {
    print("putz")
  } else {
    print("legal")
  }
  resultado
}

tictoc::tic()
purrr::map2(links, caminhos, baixar_link)
tictoc::toc()

# requisições em paralelo

library(future)
availableCores()

# MULTICORE NÃO FUNCIONA EM WINDOWS
# MULTICORE NÃO FUNCIONA NO RSTUDIO
plan(multisession, workers = 4)

library(furrr)
tictoc::tic()
furrr::future_walk2(links, caminhos, baixar_link)
tictoc::toc()

# barras de progresso!!



baixar_link <- function(link, caminho, prog = NULL) {
  # Sys.sleep(1) ## dorme um segundo

  if (!is.null(prog)) prog()

  talvez_get <- purrr::possibly(httr::GET, NULL)
  resultado <- talvez_get(link, httr::write_disk(caminho))
  if (is.null(resultado)) {
    print("putz")
  } else {
    print("legal")
  }
  resultado
}


progressr::with_progress({

  p <- progressr::progressor(length(links))

  purrr::walk2(
    links, caminhos,
    baixar_link, prog = p
  )

})


library(progressr)
progressr::handlers(global = TRUE)

funcao_que_baixa_tudo <- function() {
  p <- progressr::progressor(length(links))
  purrr::walk2(
    links, caminhos,
    baixar_link, prog = p
  )
}

funcao_que_baixa_tudo()

# na versão mais recente do pacote purrr
# (versão de desenvolvimento), temos
# barras de progresso nativamente
# com o parâmetro .progress=TRUE

funcao_que_baixa_tudo <- function() {
  # p <- progressr::progressor(length(links))
  purrr::walk2(
    links, caminhos,
    baixar_link,
    .progress = TRUE # só na versão de desenvolvimento
  )
}

# não funciona com requisições em paralelo
funcao_que_baixa_tudo()
