##' Provides a utility function which prepares a response object.
##'
##' @param content  HTTP response payload.
##' @param status   HTTP response code.
##' @param mimetype Mime-type which will be used as the HTTP `Content-Type` header value.
##' @param headers  Additional HTTP headers.
##' @param ...      Additional key-value pairs to be injected into the response object.
##' @return A named-list as a response object (see `httpuv` documentation)
fw_response <- function(content, status = 200L, mimetype = "application/json", headers = list(), ...) {
  list(body = content, status = status, headers = c(c("Content-Type" = mimetype), headers), ...)
}

##' Consumes a handler registry and a request, tries to match the handler and return its result.
##'
##' If no match, returns `HTTP 404` error.
##'
##' @param handlers Handlers registry.
##' @param request Request object.
##' @return Response.
fw_dispatch <- function(handlers, request) {
  ## Get path segments:
  segments <- .get_path_segments(request)

  ## Iterate over handlers, attempt to match and dispatch:
  for (handler in handlers) {
    ## Does the method match?
    if (handler$method == request$REQUEST_METHOD) {
      ## Yes! Attempt to match path segments:
      rmatch <- .hmatch(.parse_path_specification(handler$path), segments, list())

      ## If matched, dispatch and return:
      if (!is.null(rmatch)) {
        return(do.call(handler$func, c(rmatch, list(request = request))))
      }
    }
  }

  ## We couldn't find any match. Return 404:
  fw_response("Not found.", status = 404, mimetype = "text/plain")
}

##' Provides a utility function to parse path segments for a given PATH_INFO.
##'
##' @param pathinfo PATH_INFO request attribute.
##' @return A character vector of path segments.
.parse_path_segments <- function(path) {
  Filter(function(x) x != "", unlist(strsplit(path, "/")))
}

##' Provides a utility function to check if given string is a path variable.
##'
##' Path pariables follow the reqular expression `^<.+>$`.
##'
##' @param x String to check.
##' @return `TRUE` if the string is a path variable, `FALSE` otherwise.
.is_path_variable <- function(x) {
  grepl("<.+>", x, perl = TRUE)
}

##' Provides a utility fuction to parse path specifications.
##'
##' @param spec The specification as in `/schools/<school_id>/students/<student_id>`
##' @return A list of path segments or ID symbols (if any).
.parse_path_specification <- function(spec) {
  sapply(.parse_path_segments(spec), function(x) ifelse(.is_path_variable(x), as.symbol(x), x))
}

##' Returns the path segments of the given request.
##'
##' @param request Request.
##' @return A character vector of path segments.
.get_path_segments <- function(request) {
  Filter(function(x) x != "", unlist(strsplit(request$PATH_INFO, "/")))
}

##' Tries to match the fiven path specification to given path segments and return path variables if matched.
##'
##' @param pathspec Path specification.
##' @param segments Path segments.
##' @param variables A named list of path variables.
##' @return A named list of path variables if match is successful, `NULL` otherwise.
.hmatch <- function(pathspec, segments, variables = list()) {
  if (length(pathspec) == 0 && length(segments) == 0) {
    ## We are done! Return:
    variables
  } else if (length(pathspec) == 0 || length(segments) == 0) {
    ## At best partial match! And we won't allow that:
    NULL
  } else if (is.symbol(pathspec[[1]])) {
    ## Add new path variable:
    variables[[sub("^<?(.+)>$", "\\1", as.character(pathspec[[1]]), perl = TRUE)]] <- segments[[1]]

    ## Recurse:
    .hmatch(pathspec[-1], segments[-1], variables)
  } else if (pathspec[1] == segments[1]) {
    ## Recurse:
    .hmatch(pathspec[-1], segments[-1], variables)
  } else {
    NULL
  }
}
