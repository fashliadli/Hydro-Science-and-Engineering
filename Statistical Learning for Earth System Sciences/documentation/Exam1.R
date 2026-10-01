library(leaps)  # best subset selection
library(glmnet)  # lasso regression
library(fields) # plot

set.seed(99)  # fix randomness so results repeat

setwd("E:/backup SSD/2025/TU Dresden/Hydro Science and Engineering/MHYWI05 Statitsitcal Learning/Exam")  # set working folder
load("E:/backup SSD/2025/TU Dresden/Hydro Science and Engineering/MHYWI05 Statitsitcal Learning/Exam/Iowa.RData")  # load Iowa data

attach(DATA)  # use column names directly

summary(DATA)  # quick overview of every column


#1a
pc <- prcomp(DATA[, !(names(DATA) %in% c("yield", "loc", "year"))], scale = TRUE)  # PCA on all columns, standardized, except yield, loc, year
pc_var <- pc$sdev^2  # variance of each component
pve <- pc_var / sum (pc_var)  # share of total variance per component
pve  # print those shares

par(mfrow = c(1, 2))  # two plots side by side
plot(pve, xlab = "Principal Component", ylab = "Prop. of Variance Explained", type = "o", col = "blue", pch = 19)  # variance explained per component
plot(cumsum(pve), xlab = "Principal Component", ylab = "Cum. Prop. of Variance Explained", type = "o", col = "blue", pch = 19)  # cumulative sum of variance explained
abline(h=0.8)  # line at 80%

#1b
acf(DATA$yield)  # autocorrelation of yield
plot(DATA$year,DATA$yield)  # yield vs year
plot(DATA$loc,DATA$yield)  # yield vs location

#identical distribution test between location --> not spatially identically distributed
anova <- aov(yield ~ as.factor(DATA$loc), data = DATA)  # mean yield difference by location
summary(anova)  # show result

#identical distribution test between year  --> not temporally identically distributed
anova2 <- aov(yield ~ as.factor(DATA$year), data = DATA)  # mean yield difference by year
summary(anova2)  # show  result

#ACF test to test year independency --> temporal independent
wide <- reshape(DATA[, c("year", "loc", "yield")], idvar = "year", timevar = "loc", direction = "wide")  # one row per year, one column per location
wide$year <- NULL  # drop the year column
wide <- wide[, order(as.numeric(gsub("yield.", "", names(wide))))]  # sort columns loc 1 to 25

par(mar = c(2, 2, 2, 2))  # smaller plot margins
for (i in 1:25) {  # go through each location
  acf(wide[, i], main = paste("Loc", i), lag.max = 5)  # autocorrelation for each location
}

#CORRELATION TEST to test spatial independency --> spatially dependent
cor_matrix <- cor(wide, use = "complete.obs")  # correlation between all location pairs

par(mfrow = c(1, 1))  # back to one plot
image.plot(cor_matrix, main = "Correlation between locations", axes = FALSE)  # heatmap of correlations
axis(1, at = seq(0, 1, length.out = 25), labels = 1:25, las = 2)  # bottom axis: location numbers
axis(2, at = seq(0, 1, length.out = 25), labels = 1:25, las = 2)  # left axis: location numbers

#1.c

df <- DATA  # copy the data
df <- na.omit(df)  # remove rows with missing values

set.seed(99)  # fix randomness again
n <- nrow(df)  # number of rows

## For even uneven, turn this on!
#train_data <- df[df$year %% 2 == 0, ]  # even years = train
#test_data <- df[df$year %% 2 != 0, ]  # odd years = test

## For random, turn this on!
train <- sample(1:n, n/2)  # randomly pick half the rows for training
test <- -train  # everything else = test
train_data <- df[train, ]  # training rows
test_data <- df[test, ]  # test rows

## Split train, test, full
x_train <- model.matrix(yield ~ . - loc - year, train_data)[, -1]  # training predictors as matrix
y_train <- train_data$yield  # training yield

x_test <- model.matrix(yield ~ . - loc - year, test_data)[, -1]  # test predictors as matrix
y_test <- test_data$yield  # test yield

x_full <- model.matrix(yield ~ . - loc - year, df)[, -1]  # all predictors as matrix
y_full <- df$yield  # all yield values

## Fit best subset on training data
regfit <- regsubsets(yield ~ . - loc - year, data = train_data, nvmax = ncol(x_train))  # best model of each size (from 1 to all variables)
reg_summary <- summary(regfit)  # stats for each model size

## Training metrics per number of variables
train_r2 <- reg_summary$rsq  # R2 per size
train_mse <- reg_summary$rss / nrow(train_data)  # MSE per size
train_adjr2 <- reg_summary$adjr2  # adjusted R2 per size
train_cp <- reg_summary$cp  # Cp per size
train_bic <- reg_summary$bic  # BIC per size

## Validation MSE per number of variables
val_mse <- rep(NA, ncol(x_train))  # empty box for validation MSE
val_r2 <- rep(NA, ncol(x_train))  # empty box for validation R2
for (i in 1:ncol(x_train)) {  # go through each model size
  coefi <- coef(regfit, i)  # coefficients of the best model with i variables
  pred <- cbind(1, x_test[, names(coefi)[-1]]) %*% coefi  # predict test data
  val_mse[i] <- mean((y_test - pred)^2)  # test MSE for this size
  val_r2[i] <- 1 - sum((y_test - pred)^2) / sum((y_test - mean(y_test))^2)  # test R2 
}

## Pick size with lowest validation MSE
best_size <- which.min(val_mse)  # size with the smallest test MSE

coefi_best <- coef(regfit, best_size)  # coefficients of the best-size model
pred_best <- cbind(1, x_test[, names(coefi_best)[-1]]) %*% coefi_best  # predict test data with that model

## Refit chosen model on full data
final_fit <- regsubsets(yield ~ . - loc - year, data = df, nvmax = ncol(x_train))  # best subset, on all data
final_coef <- coef(final_fit, best_size)  # coefficients for the chosen size

## Plot validation MSE vs number of variables
par(mfrow = c(1, 2))  # two plots side by side
plot(val_mse, xlab = "Number of Variables", ylab = "Validation MSE", type = "l")  # test MSE per size
points(best_size, val_mse[best_size], col = "red", pch = 19)  # mark the best size
plot(val_r2, xlab = "Number of Variables", ylab = "Validation R Square", type = "l")  # test R2 per size
points(best_size, val_r2[best_size], col = "red", pch = 19)  # mark the best size

## Plot Train MSE vs number of variables
par(mfrow = c(1, 2))  # two plots side by side
plot(train_mse, xlab = "Number of Variables", ylab = "Train MSE", type = "l")  # train MSE per size
plot(train_r2, xlab = "Number of Variables", ylab = "Train R Square", type = "l")  # train R2 per size

## Lasso with 5-fold CV on training data
cv_lasso <- cv.glmnet(x_train, y_train, alpha = 1, nfolds = 5)  # lasso, picks lambda by 5-fold cross-validation
best_lambda <- cv_lasso$lambda.min  # lambda with the lowest CV error

## Predict on test data
pred_test <- predict(cv_lasso, s = best_lambda, newx = x_test)  # lasso predictions for test data
cv_lasso$nzero[cv_lasso$index["min", ]]  # how many variables lasso kept

## Refit on full data using best lambda
final_fit_lasso <- glmnet(x_full, y_full, alpha = 1, lambda = best_lambda)  # lasso on all data with best lambda

## Plot lambda vs cross-validated MSE
par(mfrow = c(1, 1))  # back to one plot
plot(cv_lasso)  # CV error vs lambda

## pred VS test best fit
par(mfrow = c(1, 2))  # two plots side by side
plot(y_test, pred_best, xlab="Test Data", ylab="Predicted (Best Fit Regression)")  # predicted vs real
abline(a=0, b =1, col = "red")  # perfect-prediction line
plot(y_test, pred_test, xlab="Test Data", ylab="Predicted (Lasso Regression)")  # lasso predicted vs real
abline(a=0, b =1, col = "red")  # perfect-prediction line

## Best subset: train and test metrics at best size
train_mse_bs <- train_mse[best_size]  # train MSE at best size
train_r2_bs <- train_r2[best_size]  # train R2 at best size
test_mse_bs <- val_mse[best_size]  # test MSE at best size
test_r2_bs <- val_r2[best_size]  # test R2 at best size

## Lasso: train metrics from predictions on training data
pred_train_lasso <- predict(cv_lasso, s = best_lambda, newx = x_train)  # lasso predictions for training data
train_mse_lasso <- mean((y_train - pred_train_lasso)^2)  # lasso train MSE
train_r2_lasso <- 1 - sum((y_train - pred_train_lasso)^2) / sum((y_train - mean(y_train))^2)  # lasso train R2
test_mse_lasso <- mean((y_test - pred_test)^2)  # lasso test MSE
test_r2_lasso <- 1 - sum((y_test - pred_test)^2) / sum((y_test - mean(y_test))^2)  # lasso test R2

## Calling some values

dim(DATA) #Check dimension

#Best Subset Regression
train_mse_bs  
train_r2_bs
test_mse_bs
test_r2_bs

#Lasso
train_mse_lasso
train_r2_lasso
test_mse_lasso
test_r2_lasso

best_size
best_lambda

