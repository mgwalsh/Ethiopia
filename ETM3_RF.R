#' randomForest predictions of nutrient mass balance variables with spatial covariates
#' EthioSIS Mehlich-3 extractable P,K,S,Ca & Mg, from 255 Woredas
#' M. Walsh, December 2015

# Required packages
# install.packages(c("devtools","caret","randomForest","raster")), dependencies=TRUE)
require(devtools)
require(caret)
require(randomForest)
require(raster)

# Data setup --------------------------------------------------------------
# SourceURL <- "https://raw.githubusercontent.com/mgwalsh/Ethiopia/blob/master/ETM3_setup.R"
# source_url(SourceURL)

# Mehlich-3 nutrient mass balance variables
V0 <- etm3_cal$V0
V3 <- etm3_cal$V3
V4 <- etm3_cal$V4
V5 <- etm3_cal$V5
V6 <- etm3_cal$V6

# Gridded covariates
GRIDSc <- etm3_cal[c(18:45)] ## gridded covariates for model calibration from 204 Woredas
GRIDSv <- etm3_val[c(18:45)] ## same for 51 randomly selected validation Woredas

# Random Forest models ----------------------------------------------------
set.seed(1385321)

# Cross-validation setup
tc <- trainControl(method = "oob")

# V0 = ilr [P,K,S,Ca,Mg | Fv]
V0.rf <- train(GRIDSc, V0, method = "rf", trControl = tc)
print(V0.rf)

# V3 = ilr [P,K | K,Ca,Mg]
V3.rf <- train(GRIDSc, V3, method = "rf", trControl = tc)
print(V3.rf) 

# V4 = ilr [K | Ca,Mg]
V4.rf <- train(GRIDSc, V4, method = "rf", trControl = tc)
print(V4.rf)

# V5 = ilr [P | S]
V5.rf <- train(GRIDSc, V5, method = "rf", trControl = tc)
print(V5.rf)

# V6 = ilr [Ca | Mg]
V6.rf <- train(GRIDSc, V6, method = "rf", trControl = tc)
print(V6.rf)

# Test set predictions ----------------------------------------------------
V0_rf <- predict(V1.rf, GRIDSv)
V3_rf <- predict(V3.rf, GRIDSv)
V4_rf <- predict(V4.rf, GRIDSv)
V5_rf <- predict(V5.rf, GRIDSv)
V6_rf <- predict(V6.rf, GRIDSv)
pred <- cbind.data.frame(V0_rf,V3_rf,V4_rf,V5_rf,V6_rf)
test <- etm3_val[c("PID","V0","V3","V4","V5","V6")]
rf_eval <- cbind(test, pred)

# Gridded predictions -----------------------------------------------------
V0_rf <- predict(grids, V0.rf)
V3_rf <- predict(grids, V3.rf)
V4_rf <- predict(grids, V4.rf)
V5_rf <- predict(grids, V5.rf)
V6_rf <- predict(grids, V6.rf)
rf_pred <- stack(V0_rf,V3_rf,V4_rf,V5_rf,V6_rf)
names(rf_pred) <- c("V0_rf","V3_rf","V4_rf","V5_rf","V6_rf")
plot(rf_pred)

# Export Gtif's -----------------------------------------------------------
writeRaster(rf_pred, filename="rf_pred.tif", datatype="FLT4S", options="INTERLEAVE=BAND", overwrite=T)