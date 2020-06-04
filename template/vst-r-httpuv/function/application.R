## Load required source files:
source("framework.R")
source("library.R")

##' Defines request handlers registry.
handlers <- list(
  list(method = "GET", path = "/version", func = function(request, ...) {
    fw_response(jsonlite::toJSON(list(version = version), auto_unbox = TRUE))
  }),
  list(method = "GET", path = "/<name>", func = function(request, name, ...) {
    fw_response(sprintf("Hello %s!", name), mimetype = "text/plain")
  }),
  list(method = "GET", path = "/", func = function(request, ...) {
    ## Get query parameters:
    params <- fw_queryparams(request$QUERY_STRING)

    ## Get the salute:
    salute <- ifelse("salute" %in% names(params), params$salute, "Hello")

    ## Get the name:
    name <- ifelse("name" %in% names(params), params$name, "World")

    ## Compile the response and return:
    fw_response(sprintf("%s %s!", salute, name), mimetype = "text/plain")
  })
)
