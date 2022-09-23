u_login <- "https://app.glueup.com/account/login/iframe"

parametros <- list(
  "email" = Sys.getenv("GLUEUP_USER"),
  "password" = Sys.getenv("GLUEUP_PWD"),
  "rememberMe" = "on",
  "forgotPassword" = "{\"value\":\"Esqueceu+a+senha?\",\"url\":\"\\/account\\/forgot-password\"}",
  "stayOnPage" = "",
  "showFirstTimeModal" = "true"
)

r_login <- httr::POST(
  u_login, body = parametros,
  encode = "form"
)

httr::GET("https://app.glueup.com/my/home/",
          httr::write_disk("output/glueup.html"))
