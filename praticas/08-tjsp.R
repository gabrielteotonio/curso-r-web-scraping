# passo 1 - busca ---------------------------------------------------------

u_tjsp <- "https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do"

termo_busca <- "avell"

body <- list(
  "conversationId" = "",
  "dados.buscaInteiroTeor" = termo_busca,
  "dados.pesquisarComSinonimos" = "S",
  "dados.pesquisarComSinonimos" = "S",
  "dados.buscaEmenta" = "",
  "dados.nuProcOrigem" = "",
  "dados.nuRegistro" = "",
  "agenteSelectedEntitiesList" = "",
  "contadoragente" = "0",
  "contadorMaioragente" = "0",
  "codigoCr" = "",
  "codigoTr" = "",
  "nmAgente" = "",
  "juizProlatorSelectedEntitiesList" = "",
  "contadorjuizProlator" = "0",
  "contadorMaiorjuizProlator" = "0",
  "codigoJuizCr" = "",
  "codigoJuizTr" = "",
  "nmJuiz" = "",
  "classesTreeSelection.values" = "",
  "classesTreeSelection.text" = "",
  "assuntosTreeSelection.values" = "",
  "assuntosTreeSelection.text" = "",
  "comarcaSelectedEntitiesList" = "",
  "contadorcomarca" = "0",
  "contadorMaiorcomarca" = "0",
  "cdComarca" = "",
  "nmComarca" = "",
  "secoesTreeSelection.values" = "",
  "secoesTreeSelection.text" = "",
  "dados.dtJulgamentoInicio" = "",
  "dados.dtJulgamentoFim" = "",
  "dados.dtPublicacaoInicio" = "",
  "dados.dtPublicacaoFim" = "",
  "dados.origensSelecionadas" = "T",
  "tipoDecisaoSelecionados" = "A",
  "dados.ordenarPor" = "dtPublicacao"
)

## dica: se estiver no chrome, você pode usar abjutils::chrome_to_body()

r_tjsp <- httr::POST(
  u_tjsp, body = body, encode = "form",
  httr::write_disk("output/tjsp_busca.html", overwrite = TRUE)
)

# passo 2 - quantidade de paginas -----------------------------------------

## esse xpath não funciona porque o HTML está mal formado
xp <- "/html/body/table[4]/tbody/tr/td/div/div/div[1]/table/tbody/tr[1]/td[1]"

n_resultados <- r_tjsp |>
  httr::content() |>
  xml2::xml_find_first("//td[@bgcolor='#EEEEEE']") |>
  xml2::xml_text() |>
  stringr::str_squish() |>
  stringr::str_extract("[0-9]+$") |>
  as.numeric()

n_pags <- ceiling(n_resultados / 20)
## alternativa
# n_pags <- n_resultados %/% 20 + 1

# passo 3 - pegar uma pagina ----------------------------------------------

pag <- 2

baixar_pagina <- function(pag) {
  u_pag <- glue::glue("https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do?tipoDeDecisao=A&pagina={pag}&conversationId=")
  httr::GET(u_pag, httr::write_disk(
    glue::glue("output/paginas_tjsp/pagina_{pag}.html"),
    overwrite = TRUE
  ))
}

# passo 4 - pegar várias páginas ------------------------------------------
## TODO

vetor_paginas <- 1:n_pags

purrr::map(vetor_paginas, baixar_pagina)

# passo 5 - parsear uma página --------------------------------------------

parse_tabela <- function(tabela) {
  tabela_tudo <- tabela |>
    rvest::html_table() |>
    dplyr::select(X1) |>
    dplyr::mutate(X1 = stringr::str_squish(X1))

  numero_processo <- tabela_tudo$X1[1] |>
    stringr::str_extract("[0-9.-]+")

  tabela_tudo |>
    dplyr::slice(-1) |>
    tidyr::separate(
      X1, c("name", "value"),
      sep = ": ",
      extra = "merge"
    ) |>
    tidyr::pivot_wider() |>
    janitor::clean_names() |>
    dplyr::mutate(id_processo = numero_processo, .before = 1)
}

parse_pagina <- function(f_pag) {
  # f_pag <- "output/paginas_tjsp/pagina_2.html"

  tabelas <- xml2::read_html(f_pag, "UTF-8") |>
    xml2::xml_find_all("//tr[@class='fundocinza1']/td[2]/table")

  # tabela <- tabelas[[1]]

  tabelas |>
    purrr::map_dfr(parse_tabela) |>
    dplyr::mutate(dplyr::across(
      dplyr::starts_with("data"),
      lubridate::dmy
    ))

}

f_paginas <- fs::dir_ls("output/paginas_tjsp")

f_paginas[8] |>
  parse_pagina()

# passo 6 parsear várias páginas ------------------------------------------

dados_final <- f_paginas |>
  purrr::map_dfr(parse_pagina, .id = "arquivo")

