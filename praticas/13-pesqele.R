library(webdriver)

# carregar o pjs
pjs <- run_phantomjs()
ses <- Session$new(port = pjs$port)

# exemplo simples -- google -----------------------------------------------

ses$go("https://google.com")

ses$takeScreenshot("output/google.png")

barra_busca <- ses$findElement(xpath = "//input[@name='q']")
barra_busca$sendKeys("lady gaga")

ses$takeScreenshot()
buscar <- ses$findElement(xpath = "//input[@type='submit']")
buscar$click()

ses$takeScreenshot("output/ladygaga.png")


# exemplo mais rebuscado -- pesqele ---------------------------------------

u_pesqele <- "https://rseis.shinyapps.io/pesqEle/"
httr::GET(u_pesqele, httr::write_disk("output/pesqele.html"))

ses$go(u_pesqele)
ses$takeScreenshot()

elems <- ses$findElements(xpath = "//*[@class='info-box-content']")

## exemplo que fiz para testar e construir a função
# elem <- elems[[1]]
# elem$findElements(xpath = "./span") |>
#   purrr::map_chr(\(x) x$getText())

pegar_emento <- function(elem) {
  elem$findElements(xpath = "./span") |>
    purrr::map_chr(\(x) x$getText()) |>
    purrr::set_names("titulo", "valor")
}

elems |>
  purrr::map(pegar_emento) |>
  purrr::map(tibble::enframe) |>
  purrr::list_rbind(names_to = "id") |>
  tidyr::pivot_wider()


ses$takeScreenshot()

radio <- ses$findElement(xpath = "//input[@value='nacionais']")
radio$click()

ses$takeScreenshot()

elems <- ses$findElements(xpath = "//*[@class='info-box-content']")
elems |>
  purrr::map(pegar_emento) |>
  purrr::map(tibble::enframe) |>
  purrr::list_rbind(names_to = "id") |>
  tidyr::pivot_wider()

html <- ses$getSource()
readr::write_file(html, "output/pesqele_webdriver.html")

xml2::read_html("output/pesqele_webdriver.html") |>
  xml2::xml_find_all("//*[@class='info-box-content']") |>
  xml2::xml_text()

Sys.sleep(1)

ses$go(u_pesqele)

verifica_se_disponivel <- function() {
  ses$findElement(xpath = "//span[@class='info-box-text']")
}

safe_verifica_se_disponivel <- purrr::possibly(
  verifica_se_disponivel, NULL
)

# verificar se a página foi carregada
ses$go(u_pesqele)
nao_disponivel <- is.null(safe_verifica_se_disponivel())
while (nao_disponivel) {
  print("não está disponível!")
  Sys.sleep(1)
  nao_disponivel <- is.null(safe_verifica_se_disponivel())
}
safe_verifica_se_disponivel()


# baixar uma tabela -------------------------------------------------------

link <- ses$findElement(xpath = "//a[@href='#shiny-tab-empresas']")
link$click()
ses$takeScreenshot()

ultima_pagina <- "//a[@data-dt-idx='6']"
elem <- ses$findElement(xpath = ultima_pagina)
# elem$click()
qtd_paginas <- as.numeric(elem$getText())

## outra forma de pegar a quantidade de paginas
xp_pag <- "//*[@id='DataTables_Table_0_info']"
elem <- ses$findElement(xpath = xp_pag)
qtd_paginas <- elem$getText() |>
  stringr::str_extract("[0-9]+(?= entries)") |>
  as.numeric() |>
  magrittr::divide_by(5)

ses$takeScreenshot()

pagina_1 <- ses$getSource() |>
  xml2::read_html() |>
  xml2::xml_find_first(xpath = "//*[@id='DataTables_Table_0']") |>
  rvest::html_table() |>
  janitor::clean_names()

tabela_completa <- purrr::map(2:38, function(pag) {
  xp <- glue::glue("//*[@id='DataTables_Table_0_next']")
  ses$findElement(xpath = xp)$click()
  Sys.sleep(.5) ## COMPLICADO
  ses$getSource() |>
    xml2::read_html() |>
    xml2::xml_find_first(xpath = "//*[@id='DataTables_Table_0']") |>
    rvest::html_table() |>
    janitor::clean_names()
})

tabela_completa |>
  purrr::list_rbind() |>
  dplyr::bind_rows(pagina_1) |>
  View()

