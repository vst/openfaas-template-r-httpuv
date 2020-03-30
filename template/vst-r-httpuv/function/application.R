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
    fw_response("Hello World!", mimetype = "text/plain")
  })
)
