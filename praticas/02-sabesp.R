
u_sabesp <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/2022-09-01"
r_sabesp <- httr::GET(u_sabesp)

resultado_sabesp <- r_sabesp |>
  httr::content(simplifyDataFrame = TRUE)

resultado_sabesp$ReturnObj$sistemas |>
  tibble::tibble() |>
  janitor::clean_names() |>
  View()

# outra data!


data <- "2022-09-01"

pegar_data <- function(data) {
  u_sabesp_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"

  u_sabesp <- paste0(u_sabesp_base, data)

  r_sabesp <- httr::GET(u_sabesp)

  resultado_sabesp <- r_sabesp |>
    httr::content(simplifyDataFrame = TRUE)

  resultado_sabesp$ReturnObj$sistemas |>
    tibble::tibble() |>
    janitor::clean_names()

}

datas <- seq(as.Date("2022-09-01"), as.Date("2022-09-12"), by = 1)

pegar_data("2022-09-02")

resultado_setembro <- datas |>
  purrr::set_names() |>
  purrr::map_dfr(pegar_data, .id = "data")

View(resultado_setembro)
