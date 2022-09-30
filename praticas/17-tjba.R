u_tjba <- "http://esaj.tjba.jus.br/cpopg/open.do"

u_inicial <- httr::GET(u_tjba)

u_captcha <- "http://esaj.tjba.jus.br/cpopg/imagemCaptcha.do"
httr::GET(
  u_captcha,
  httr::write_disk("output/captcha.png", TRUE)
)

# remotes::install_github("decryptr/captcha")
modelo <- captcha::captcha_load_model("praticas/esaj.pt")

label <- captcha::decrypt("output/captcha.png", modelo)

captcha::read_captcha("output/captcha.png") |> plot()
label

# por enquanto vamos ver manualmente
# label <- "dxshc"

id_processo <- "05042786720178050004"

parametros <- list(
  "dadosConsulta.localPesquisa.cdLocal" = "-1",
  "cbPesquisa" = "NUMPROC",
  "dadosConsulta.tipoNuProcesso" = "UNIFICADO",
  "numeroDigitoAnoUnificado" = stringr::str_sub(id_processo, 1, 13),
  "foroNumeroUnificado" = stringr::str_sub(id_processo, -4, -1),
  "dadosConsulta.valorConsultaNuUnificado" = id_processo,
  "dadosConsulta.valorConsulta" = "",
  "vlCaptcha" = label
)

u_search <- "http://esaj.tjba.jus.br/cpopg/search.do"
httr::GET(
  u_search, query = parametros,
  httr::write_disk("output/busca_tjba.html", TRUE)
)
