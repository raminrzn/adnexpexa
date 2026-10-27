# Coefficients of the linear predictors z1 to z4 (borderline, stage I, stage
# II-IV and secondary metastatic, each versus benign). Rows follow the order of
# the published formulas.
#
# With CA-125: Van Calster et al., BMJ 2014;349:g5920, supplementary
#   appendix D; identical in Van Calster et al., BMJ 2020;370:m2614,
#   supplementary appendix 4.
# Without CA-125 (separately fitted model): BMJ 2020;370:m2614,
#   supplementary appendix 4.
.ad_terms <- c("intercept", "age", "log2_ca125", "log2_lesion", "pst", "pst2",
               "locules", "papillary", "shadows", "ascites", "oncology")

.ad_coef <- list(
  with_ca125 = rbind(
    borderline = c(-7.577663, 0.004506, 0.111642, 0.372046, 6.967853, -5.65588,
                   1.375079, 0.604238, -2.04157, 0.971061, 0.953043),
    stage_i = c(-12.276041, 0.017260, 0.197249, 0.873530, 9.583053, -5.83319,
                0.791873, 0.400369, -1.87763, 0.452731, 0.452484),
    stage_ii_iv = c(-14.915830, 0.051239, 0.765456, 0.430477, 10.37696,
                    -5.70975, 0.273692, 0.389874, -2.35516, 1.348408, 0.459021),
    metastatic = c(-11.909267, 0.033601, 0.276166, 0.449025, 6.644939,
                   -2.30330, 0.899980, 0.215645, -2.49845, 1.636407, 0.808887)),
  without_ca125 = rbind(
    borderline = c(-7.412534, 0.003489, 0, 0.430701, 7.117925, -5.74135,
                   1.343699, 0.607211, -2.11885, 1.167767, 0.983227),
    stage_i = c(-12.201607, 0.017607, 0, 0.98728, 10.07145, -6.17742,
                0.763081, 0.410449, -1.98073, 0.77054, 0.543677),
    stage_ii_iv = c(-12.826207, 0.045172, 0, 0.759002, 11.83296, -6.64336,
                    0.316444, 0.390959, -2.94082, 2.691276, 0.929483),
    metastatic = c(-11.424379, 0.033407, 0, 0.560396, 7.264105, -2.77392,
                   0.983394, 0.199164, -2.63702, 2.185574, 0.906249)))
.ad_coef <- lapply(.ad_coef, function(m) {
  colnames(m) <- .ad_terms
  m
})

#' ADNEX: probabilities of five types of adnexal tumour
#'
#' Published equations of the IOTA ADNEX model (Van Calster et al., BMJ 2014),
#' for a woman with an adnexal mass assessed by ultrasound before surgery.
#' Ultrasound variables follow the IOTA terms and definitions.
#'
#' @param age Age in years.
#' @param ca125 Serum CA-125 in U/mL. Leave out (or `NULL`) when not measured:
#'   the separately fitted model without CA-125 is then used.
#' @param lesion_diameter Maximum diameter of the lesion, mm.
#' @param solid_diameter Maximum diameter of the largest solid component, mm
#'   (0 if there is no solid tissue). Must not exceed `lesion_diameter`.
#' @param more_than_10_locules More than 10 cyst locules (yes/no).
#' @param papillary_projections Number of papillary projections, 0 to 3, or 4
#'   for more than three (larger counts are treated as 4).
#' @param acoustic_shadows Acoustic shadows (yes/no).
#' @param ascites Ascites, fluid outside the pouch of Douglas (yes/no).
#' @param oncology_centre Examined at a gynaecological oncology centre (yes/no).
#' @param model `"auto"` (with CA-125 when it is given), `"with_ca125"` or
#'   `"without_ca125"`.
#' @return A list with the model used, the five tumour-type probabilities and
#'   the total risk of malignancy (1 minus the probability of benign).
#' @export
adnex <- function(age, ca125 = NULL, lesion_diameter, solid_diameter,
                  more_than_10_locules, papillary_projections,
                  acoustic_shadows, ascites, oncology_centre,
                  model = c("auto", "with_ca125", "without_ca125")) {
  model <- match.arg(model)
  if (length(ca125) == 1L && is.na(ca125)) ca125 <- NULL
  if (model == "auto") model <- if (is.null(ca125)) "without_ca125" else "with_ca125"
  if (model == "with_ca125" && is.null(ca125)) {
    stop("`ca125` is required for the model with CA-125.", call. = FALSE)
  }
  age <- .ad_num(age, "age", 0, 120)
  lesion <- .ad_num(lesion_diameter, "lesion_diameter", 0, Inf)
  if (lesion <= 0) stop("`lesion_diameter` must be greater than 0.", call. = FALSE)
  solid <- .ad_num(solid_diameter, "solid_diameter", 0, Inf)
  if (solid > lesion) {
    stop("`solid_diameter` cannot exceed `lesion_diameter`.", call. = FALSE)
  }
  pp <- .ad_num(papillary_projections, "papillary_projections", 0, Inf)
  if (pp != round(pp)) {
    stop("`papillary_projections` must be a whole number.", call. = FALSE)
  }
  pst <- solid / lesion
  x <- c(intercept = 1, age = age, log2_ca125 = 0, log2_lesion = log2(lesion),
         pst = pst, pst2 = pst^2,
         locules = .ad_yesno(more_than_10_locules, "more_than_10_locules"),
         papillary = min(pp, 4),
         shadows = .ad_yesno(acoustic_shadows, "acoustic_shadows"),
         ascites = .ad_yesno(ascites, "ascites"),
         oncology = .ad_yesno(oncology_centre, "oncology_centre"))
  if (model == "with_ca125") {
    ca <- .ad_num(ca125, "ca125", 0, Inf)
    if (ca <= 0) stop("`ca125` must be greater than 0 U/mL.", call. = FALSE)
    x[["log2_ca125"]] <- log2(ca)
  }
  z <- as.vector(.ad_coef[[model]] %*% x)
  p <- c(1, exp(z)) / (1 + sum(exp(z)))
  list(model = if (model == "with_ca125") "ADNEX with CA-125" else "ADNEX without CA-125",
       risk_benign = p[1], risk_borderline = p[2], risk_stage_i = p[3],
       risk_stage_ii_iv = p[4], risk_metastatic = p[5],
       risk_malignant = 1 - p[1], proportion_solid = pst)
}
