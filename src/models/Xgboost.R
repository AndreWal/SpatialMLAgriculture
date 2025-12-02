library(tidyverse)
library(tidymodels)

# Data

swdat = readRDS(paste0(getwd(), "/project/Data/processed/swdat.rds"))

# Prediction equation

predictors = colnames(swdat[c(5:length(swdat))])

response = "firsh"

formula <- as.formula(paste(
  response,
  "~",
  paste(predictors, collapse = " + ")
))


recipe <- recipes::recipe(formula, data = swdat)

# Xgboost

rf_model <- boost_tree(trees = 15) |>
  set_engine("xgboost") |>
  set_mode("regression")

# Create the workflow
workflow <- workflows::workflow() |>
  workflows::add_recipe(recipe) |>
  workflows::add_model(rf_model)

# Fit the model
xgb_fit <- parsnip::fit(workflow, data = swdat)

prediction_raster <- terra::predict(predictors, xgb_fit, na.rm = TRUE)
plot(prediction_raster)