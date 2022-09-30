
# jsonlite::read_json("output/parametros.json") |>
#   dput()


u_djt <- "https://dejt.jt.jus.br/dejt/f/n/diariocon"

r_inicial <- httr::GET(u_djt)

viewstate <- r_inicial |>
  xml2::read_html() |>
  xml2::xml_find_first("//*[@name='javax.faces.ViewState']") |>
  xml2::xml_attr("value")

body <- list(
  `corpo:formulario:dataIni` = "29/09/2022",
  `corpo:formulario:dataFim` = "29/09/2022",
  `corpo:formulario:tipoCaderno` = "",
  `corpo:formulario:tribunal` = "",
  `corpo:formulario:ordenacaoPlc` = "",
  navDe = "",
  detCorrPlc = "",
  tabCorrPlc = "",
  detCorrPlcPaginado = "",
  exibeEdDocPlc = "",
  indExcDetPlc = "",
  org.apache.myfaces.trinidad.faces.FORM = "corpo:formulario",
  `_noJavaScript` = "false",
  javax.faces.ViewState = viewstate,
  source = "corpo:formulario:botaoAcaoPesquisar"
)

r_djt <- httr::POST(
  u_djt,
  body = body,
  # encode = "form", # se safou mais uma vez, não precisa
  httr::write_disk("output/resultado_pesquisa_djt.html", TRUE)
)


# baixar pdf --------------------------------------------------------------

body_pdf <- list(
  `corpo:formulario:dataIni` = "29/09/2022",
  `corpo:formulario:dataFim` = "29/09/2022",
  `corpo:formulario:tipoCaderno` = "",
  `corpo:formulario:tribunal` = "",
  `corpo:formulario:ordenacaoPlc` = "",
  navDe = "1",
  detCorrPlc = "",
  tabCorrPlc = "",
  detCorrPlcPaginado = "",
  exibeEdDocPlc = "",
  indExcDetPlc = "",
  org.apache.myfaces.trinidad.faces.FORM = "corpo:formulario",
  `_noJavaScript` = "false",
  javax.faces.ViewState = viewstate,
  source = "corpo:formulario:botaoAcaoPesquisar"
)

pdf_ids <- r_djt |>
  xml2::read_html() |>
  xml2::xml_find_all("//button[@class='bt af_commandButton']") |>
  xml2::xml_attr("onclick") |>
  stringr::str_extract("(?<=source:')[^']+")

pdf_id <- pdf_ids[1]
body_pdf$source <- pdf_id

httr::POST(
  u_djt, body = body_pdf, encode = "form",
  httr::write_disk("output/diario_01.pdf", TRUE),
  httr::progress()
)

## exercício: iterar para baixar todos os pdf
## iterar para as duas páginas
## criar uma função que recebe a data e baixa tudo
