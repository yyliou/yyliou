#!/usr/bin/env Rscript
# ---------------------------------------------------------------
# Render every research statement in this folder.  Open rs.Rproj in
# RStudio, then in the Terminal tab (working dir = this folder):
#
#   Rscript render.R           # all  (*.Rmd here)
#   Rscript render.R zh        # only files whose name matches "zh"
#
# From the R Console instead:  source("render.R"); render_rs()
#                              render_rs("zh")
# ---------------------------------------------------------------

.rs_dir <- local({
  a <- commandArgs(trailingOnly = FALSE)
  f <- sub("^--file=", "", a[grepl("^--file=", a)])
  if (length(f)) normalizePath(dirname(f)) else normalizePath(getwd())
})

render_rs <- function(...) {
  pats  <- unlist(list(...))
  files <- list.files(.rs_dir, pattern = "[.]Rmd$", full.names = TRUE)
  if (length(pats))
    files <- files[Reduce(`|`, lapply(pats, grepl, x = basename(files)))]

  if (!length(files)) { cat("No .Rmd matched. Nothing to do.\n"); return(invisible(FALSE)) }
  if (!requireNamespace("rmarkdown", quietly = TRUE))
    stop("Package 'rmarkdown' is not installed.  install.packages(\"rmarkdown\")")

  cat(sprintf("Rendering %d file(s)\n\n", length(files)))
  t0 <- Sys.time(); ok <- character(); bad <- character()

  for (f in files) {
    cat(sprintf("  %-32s ", basename(f))); flush.console()
    s <- Sys.time()
    res <- tryCatch({
      rmarkdown::render(f, output_dir = dirname(f), quiet = TRUE,
                        envir = new.env())
      TRUE
    }, error = function(e) structure(FALSE, msg = conditionMessage(e)))
    dt <- as.numeric(difftime(Sys.time(), s, units = "secs"))
    if (isTRUE(res)) {
      cat(sprintf("ok   %5.1fs\n", dt)); ok <- c(ok, basename(f))
    } else {
      cat(sprintf("FAIL %5.1fs\n", dt)); bad <- c(bad, basename(f))
      cat("      -> ", strsplit(attr(res, "msg"), "\n")[[1]][1], "\n", sep = "")
    }
  }

  cat(sprintf("\n%d ok, %d failed  (%.0fs total)\n", length(ok), length(bad),
              as.numeric(difftime(Sys.time(), t0, units = "secs"))))
  if (length(bad)) cat("Failed: ", paste(bad, collapse = ", "), "\n", sep = "")
  invisible(length(bad) == 0)
}

if (!interactive() && any(grepl("^--file=", commandArgs(trailingOnly = FALSE)))) {
  good <- render_rs(commandArgs(trailingOnly = TRUE))
  quit(status = if (isTRUE(good)) 0 else 1)
}
