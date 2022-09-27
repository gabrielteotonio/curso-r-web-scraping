u_pbi <- "https://app.powerbi.com/view?r=eyJrIjoiZWU5ZjFiZDItMGM5Ny00ZTU2LWEzMTEtMzc1ZWMwMjkzMTFmIiwidCI6ImFkOTE5MGU2LWM0NWQtNDYwMC1iYzVjLWVjYTU1NGNjZjQ5NyIsImMiOjJ9&pageName=ReportSectionfa1fcf7b6d15b9e55814"

library(RSelenium)

drv <- rsDriver(browser = "firefox")

ses <- drv$client
ses$navigate(u_pbi)

cards <- ses$findElements("xpath", "//*[@class='card']")
resultados <- cards |>
  purrr::map(\(x) x$getElementText()) |>
  purrr::map_chr(1)


## Sempre dá para baixar a página de origem
html <- ses$getPageSource()
readr::write_file(html[[1]], "output/pbi_cnj.html")

xml2::read_html("output/pbi_cnj.html") |>
  xml2::xml_find_all("//*[@class='card']") |>
  xml2::xml_text()

xp_menu_grau <- "//div[@aria-label='Grau']"

elem <- ses$findElement("xpath", xp_menu_grau)
elem$clickElement()
xp_1grau <- "//*[@title='1º Grau']"
primeiro_grau <- ses$findElement("xpath", xp_1grau)
primeiro_grau$clickElement()
elem$clickElement()


cards <- ses$findElements("xpath", "//*[@class='card']")
resultados <- cards |>
  purrr::map(\(x) x$getElementText()) |>
  purrr::map_chr(1)


resultados

retangulos <- ses$findElements(
  "xpath",
  "//*[@class='series']/*[contains(@class, 'bar')]"
)
retangulos[[1]]$getElementAttribute

retangulos |>
  purrr::map(\(x) x$getElementAttribute("aria-label")) |>
  purrr::map_chr(1) |>
  as.numeric() |>
  tibble::enframe() |>
  ggplot2::ggplot(
    ggplot2::aes(x = value, y = factor(name))
  ) +
  ggplot2::geom_col()


# o selenium não encontra um elemento se
# ele está dentro de um iframe!!

link_iframe_download <- "https://painel-estatistica.stg.cloud.cnj.jus.br/downloads.html?tribunal=&municipio=&oj=&indicador=5PorcMaisAntigos&ambiente=_d"
ses$navigate(link_iframe_download)

elem <- ses$findElement("xpath", "//*[@name='tribunalCGJ']/parent::div")
elem$clickElement()

itens <- ses$findElements(
  "xpath",
  "//*[contains(@id, 'list-item-')]"
)

purrr::map(itens, \(x) x$getElementText()) |>
  purrr::map_chr(1)

lista <- ses$findElement(
  "xpath",
  "/html/body/div/div[1]/div[3]"
)

lista$executeScript(
  "arguments[0].scrollBy(0,1000);",
  list(lista)
)

itens <- ses$findElements(
  "xpath",
  "//*[contains(@id, 'list-item-')]"
)

tribunais <- purrr::map(itens, \(x) x$getElementText()) |>
  purrr::map_chr(1)

tribunal <- "TSE"

elem <- ses$findElement(
  "xpath",
  glue::glue("//*[contains(text(), '{tribunal}')]")
)

elem$clickElement()

botao <- ses$findElement(
  "xpath",
  "/html/body/div/div[1]/div[1]/div/div[3]/div[1]/div/div[2]/div[2]/button"
)
botao$clickElement()

