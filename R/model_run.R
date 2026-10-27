.ad_vars <- c("age", "ca125", "lesion_diameter", "solid_diameter",
              "more_than_10_locules", "papillary_projections",
              "acoustic_shadows", "ascites", "oncology_centre", "model")
.ad_alias <- c(ca_125 = "ca125", max_lesion_diameter = "lesion_diameter",
               lesion = "lesion_diameter",
               max_solid_diameter = "solid_diameter", solid = "solid_diameter",
               locules = "more_than_10_locules",
               papillary = "papillary_projections",
               shadows = "acoustic_shadows", oncology = "oncology_centre",
               oncology_center = "oncology_centre")

#' ADNEX (ModelsCloud entry point)
#' @param model_input Named list of inputs; see [adnex()].
#' @param ... The same fields as named arguments.
#' @return See [adnex()].
#' @export
model_run <- function(model_input = NULL, ...) {
  args <- .ad_normalize(model_input, list(...), .ad_vars, .ad_alias)
  if (is.null(args) || length(args) == 0) args <- get_default_input()
  missing <- setdiff(setdiff(.ad_vars, c("ca125", "model")), names(args))
  if (length(missing) > 0) {
    stop("Missing required variable(s): ", paste(missing, collapse = ", "), ".",
         call. = FALSE)
  }
  do.call(adnex, args)
}

#' Example ADNEX inputs: the BMJ 2014 worked example with and without CA-125
#' @param n Optional number of rows.
#' @param ... Ignored.
#' @export
get_sample_input <- function(n = NULL, ...) {
  df <- data.frame(age = c(55, 55), ca125 = c(42, NA), lesion_diameter = 120,
                   solid_diameter = 20, more_than_10_locules = "yes",
                   papillary_projections = 0, acoustic_shadows = "no",
                   ascites = "yes", oncology_centre = "yes",
                   stringsAsFactors = FALSE)
  if (!is.null(n)) df <- utils::head(df, n)
  df
}

#' Default ADNEX input (the BMJ 2014 worked example, with CA-125)
#' @param ... Ignored.
#' @export
get_default_input <- function(...) {
  list(age = 55, ca125 = 42, lesion_diameter = 120, solid_diameter = 20,
       more_than_10_locules = "yes", papillary_projections = 0,
       acoustic_shadows = "no", ascites = "yes", oncology_centre = "yes")
}
