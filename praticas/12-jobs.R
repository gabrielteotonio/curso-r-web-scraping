# passo 1: listar os jobs -------------------------------------------------

u_jobs <- "https://realpython.github.io/fake-jobs/"
r_jobs <- httr::GET(u_jobs)

cards <- r_jobs |>
  xml2::read_html() |>
  xml2::xml_find_all("//div[@class='card-content']")

parse_card <- function(card) {

  xpaths <- c(
    titulo = ".//h2",
    subtitulo = ".//h3",
    local = ".//p[@class='location']",
    data = ".//time",
    learn = ".//a[contains(text(),'Learn')]",
    apply = ".//a[contains(text(),'Apply')]"
  )

  res <- purrr::map(xpaths, \(x) xml2::xml_find_all(card, x))

  # obs: uso avançado!
  purrr::map_if(
    res,
    \(x) xml2::xml_name(x) == "a",
    \(x) xml2::xml_attr(x, "href"),
    .else = \(x) xml2::xml_text(x)
  ) |>
    tibble::enframe() |>
    tidyr::unnest(value) |>
    dplyr::mutate(
      value = stringr::str_squish(value)
    ) |>
    tidyr::pivot_wider()

}

resultado <- purrr::map(cards, parse_card) |>
  # futuramente, recomenda-se
  # purrr::list_rbind()
  dplyr::bind_rows()

links <- resultado$apply

# passo 2: baixar os jobs -------------------------------------------------

caminhos <- paste0("output/jobs/", basename(links))

baixar_link <- function(link, caminho, prog = NULL) {
  # Sys.sleep(1) ## dorme um segundo
  if (!is.null(prog)) prog()
  talvez_get <- purrr::possibly(httr::GET, NULL)
  resultado <- talvez_get(link, httr::write_disk(caminho))
  resultado
}

progressr::with_progress({
  p <- progressr::progressor(length(links))
  purrr::walk2(links, caminhos, baixar_link, prog = p)
})


# passo 3: parse dos jobs -------------------------------------------------

arquivos <- fs::dir_ls("output/jobs")

arquivo <- arquivos[1]

parse_arquivo <- function(arquivo) {

  html_box <- arquivo |>
    xml2::read_html() |>
    xml2::xml_find_first("//div[@class='box']")

  xpaths <- c(
    titulo = ".//h1",
    subtitulo = ".//h2",
    descricao = ".//p[1]",
    location = ".//p[@id='location']",
    date = ".//p[@id='date']"
  )

  res <- purrr::map(
    xpaths,
    \(x) xml2::xml_find_all(html_box, x)
  ) |>
    purrr::map_chr(xml2::xml_text) |>
    tibble::enframe() |>
    dplyr::mutate(
      value = stringr::str_remove(value, "^(Location|Posted): ")
    ) |>
    tidyr::pivot_wider()

}

da_jobs_detalhes <- arquivos |>
  purrr::map(parse_arquivo) |>
  dplyr::bind_rows(.id = "file") |>
  dplyr::mutate(id = basename(file))

resultado_final <- resultado |>
  dplyr::mutate(id = basename(apply)) |>
  dplyr::left_join(da_jobs_detalhes, "id")

resultado_final
