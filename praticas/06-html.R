library(xml2)

html <- read_html("output/exemplo.html")

# coletar todas as tags do tipo <p>

resultado <- html |>
  xml_find_all("//p")

resultado[[1]]

html |>
  xml_find_first("//p")

xml_find_all(html, "//head")

# extrair os textos

xml_text(resultado)
xml_text(html)

# extrair os atributos

xml_attrs(resultado)
xml_attr(resultado, "style")

