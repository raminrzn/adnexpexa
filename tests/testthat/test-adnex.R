# Published probabilities are rounded to 0.1 percentage points.
# Absolute agreement within half of the published rounding unit.
near <- function(got, published) {
  expect_true(all(abs(unname(got) - published) <= 0.05 + 1e-9),
              label = paste(round(got, 3), collapse = " "))
}
pct <- function(r) 100 * unlist(r[c("risk_borderline", "risk_stage_i",
                                     "risk_stage_ii_iv", "risk_metastatic")])

test_that("BMJ 2014 worked example is reproduced with and without CA-125", {
  x <- get_default_input()
  r <- adnex(age = 55, ca125 = 42, lesion_diameter = 120, solid_diameter = 20,
             more_than_10_locules = "yes", papillary_projections = 0,
             acoustic_shadows = "no", ascites = "yes", oncology_centre = "yes")
  expect_equal(r$model, "ADNEX with CA-125")
  near(unname(pct(r)), c(37.4, 10.8, 8.4, 11.0))
  near(100 * r$risk_malignant, 67.6)
  x$ca125 <- NULL
  r0 <- model_run(x)
  expect_equal(r0$model, "ADNEX without CA-125")
  near(unname(pct(r0)), c(25.2, 8.3, 35.8, 11.5))
})

test_that("worked cases in Van Calster et al. 2015 (FVV in ObGyn) are reproduced", {
  c1 <- model_run(list(age = 59, ca125 = 153, lesion_diameter = 59,
                       solid_diameter = 59, more_than_10_locules = "no",
                       papillary_projections = 0, acoustic_shadows = "no",
                       ascites = "yes", oncology_centre = "yes"))
  near(unname(pct(c1)), c(1.6, 4.6, 67.9, 21.2))
  near(100 * c1$risk_malignant, 95.3)
  c2 <- model_run(list(age = 48, ca125 = 22, lesion_diameter = 66,
                       solid_diameter = 27, more_than_10_locules = "no",
                       papillary_projections = 1, acoustic_shadows = "no",
                       ascites = "no", oncology_centre = "yes"))
  near(unname(pct(c2)), c(18.7, 13.3, 5.9, 3.0))
  near(100 * c2$risk_malignant, 40.9)
})

test_that("probabilities sum to one and inputs are checked", {
  r <- model_run(get_default_input())
  expect_equal(r$risk_benign + r$risk_borderline + r$risk_stage_i +
                 r$risk_stage_ii_iv + r$risk_metastatic, 1)
  x <- get_default_input()
  x$papillary_projections <- 7
  y <- get_default_input()
  y$papillary_projections <- 4
  expect_equal(model_run(x), model_run(y))
  x$solid_diameter <- 130
  expect_error(model_run(x), "solid_diameter")
  z <- get_default_input()
  z$ca125 <- 0
  expect_error(model_run(z), "ca125")
  z$ca125 <- NULL
  z$model <- "with_ca125"
  expect_error(model_run(z), "ca125")
  w <- get_default_input()
  w$model <- "without_ca125"
  expect_equal(model_run(w)$model, "ADNEX without CA-125")
})

test_that("gateway returns full precision and treats JSON null CA-125 as missing", {
  x <- get_default_input()
  x$ca125 <- NULL
  js <- gateway(model_input = c(x, list(ca125 = NULL)), execution_id = "z")
  g <- jsonlite::fromJSON(js)
  expect_equal(g$risk_stage_ii_iv, model_run(x)$risk_stage_ii_iv, tolerance = 1e-12)
  expect_equal(g$model, "ADNEX without CA-125")
})
