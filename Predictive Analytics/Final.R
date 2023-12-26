install.packages("forecast")
library(forecast)
library(fpp3)
library(dplyr)
library(AER)
library(urca)
library(fable)
library(ggplot2)
library(ggfortify)
library(openxlsx)
library(e1071)
library(strucchange)
library(gridExtra)

#### 1. Data preparation ####

# Load data
input_data <- read.xlsx("/Users/aaronwolf/Library/CloudStorage/OneDrive-Personal/Semester_2/PA/Exam/beds.xlsx")

# Transpose
df_beds <- data.frame(t(input_data))

# Name columns
colnames(df_beds) <- c("Time", "Beds")

# convert the format of "1992M01" to a date
df_beds$Time <- as.Date(paste0(df_beds$Time, "01"), format = "%YM%m%d")

# convert the full date to just year and month
df_beds$Time <- yearmonth(df_beds$Time, label = TRUE)  

# convert beds column to numeric
df_beds$Beds <-as.numeric(df_beds$Beds)

# convert to ts object
Beds_TS <- df_beds %>%
  as_tsibble(index = Time)

# initial statistics
summary(df_beds$Beds)
mean(df_beds$Beds)


##### 2. Data Analysis #####

# plot the time series
autoplot(Beds_TS) + labs(x = "Months")
gg_season(Beds_TS) +  labs(x = "Months")
gg_subseries(Beds_TS)

# autocorrelation 
Beds_TS %>%
  ACF() %>%
  autoplot()

# partial autocorrelation
Beds_TS %>%
  PACF() %>%
  autoplot()

# STL decomposition
Beds_TS %>%
  model(
    STL(Beds)
  ) %>%
  components() %>%
  autoplot() +
  labs(title = "STL Decomposition", x = "Months")

# Classical decomposition
#decomp <- decompose(ts(Beds_TS$Beds, frequency = 12))
#plot(decomp)


##### 3. Preprocessing #####

# Applying a box-cox transformation to the data?

Beds_TS %>%
  features(Beds, features = guerrero)

lambda <- 1.51

Beds_TS %>%
  model(
    STL(box_cox(Beds, 1.51))
  ) %>%
  components() %>%
  autoplot() +
  labs(title = "STL Decomposition after Box-Cox Transformation", x = "Months")

Beds_TS %>%
  autoplot(box_cox(Beds, 1.51)) +
  labs(title = "Time Series after Box-Cox Transformation", x = "Months")

# Plotting after BX and before together
plot2 <- Beds_TS %>%
  autoplot(box_cox(Beds, 1.51)) +
  labs(title = "Time Series after Box-Cox Transformation", x = "Months")

plot1 <- autoplot(Beds_TS) +
  labs(x = "Months", title = "Original Time Series")

# Arrange the plots side by side
grid.arrange(plot1, plot2, ncol = 2)
  
# Skewness
skewness(Beds_TS$Beds) # 0.6267333
skewness(BoxCox(Beds_TS$Beds, 1.51)) # 0.8731824
# less skew without transformation: no box cox and no log

# autocorrelation 
#Beds_TS %>%
#  ACF(box_cox(Beds, lambda)) %>%
#  autoplot()

# partial autocorrelation
#Beds_TS %>%
#  PACF(box_cox(Beds, lambda)) %>%
#  autoplot()

##### 4. Testing for stationarity ##### 

# KPSS: "tau" (including trend)
summary(ur.kpss(Beds_TS$Beds, type = "tau"))
# 0.735 -> the test statistic is larger than the critical value at significance level at 5% (0.146)
# therefore we can reject H0 (H0 = data is stationary)
# i.e. we do have an indication that the data is non-stationary

summary(ur.kpss(Beds_TS$Beds, type = "mu"))
# 5.7675  -> the test statistic is larger than the critical value at significance level at 5% (0.347)
# therefore we can reject H0 (H0 = data is stationary)
# i.e. we do have an indication that the data is non-stationary


# ADF:
## trend (including drift and trend)
# test accepts the null for γ and rejects the others --> have a unit root with drift and trend --> difference
summary(ur.df(Beds_TS$Beds, type = "trend", selectlags = c("AIC")))
# p-value of the intercept is below significance level = it is significant
# first test statistic value lower than critical value at tau3 (at all significance levels)
# --> Reject H0 (that there is a unit root) -> i.e. data seems to be stationary
# second test statistic value larger than critical level at 5%
# --> Reject H0 that there is a unit root with absent deterministic drift and trend 
# third test statistic value larger than critical level at 5%
# --> Reject H0 that there is a unit root with absent deterministic trend

# drift
summary(ur.df(Beds_TS$Beds, type = "drift", selectlags = c("AIC")))
# first: -1.716 is larger than -2.87 -> accept H0 that there is a unit root
# second: 1.8705 is smaller than 4.61 -> accept H0 = non stationarity (unit root) + absent drift 

# without drift and trend
summary(ur.df(Beds_TS$Beds, type = "none", selectlags = c("AIC")))
# 0.3812 larger than -1.95 confirms the previous test's results
# -> we have a unit root without trend and drift = data is non-stationary -> difference

# finding the optimal number of differences
Beds_TS %>%
  features(Beds, unitroot_ndiffs)
# the test suggest first order differencing of the time series

# applying first order differencing and redoing the tests that previously indicated non-stationarity
summary(ur.kpss(diff(Beds_TS$Beds), type = "tau"))
# 0.0327 below 0.463 at 5% -> data is stationary now

summary(ur.df(diff(Beds_TS$Beds), type = "trend", selectlags = c("AIC")))
# reject H0
# reject H0
# reject H0
summary(ur.df(diff(Beds_TS$Beds), type = "drift", selectlags = c("AIC")))
# first ts smaller than tau2 -> reject H0 of unit root -> data is stationary
# second ts larger than phi1 -> reject H0 of unit root with absent drift -> data now stationary 
summary(ur.df(diff(Beds_TS$Beds), type = "none", selectlags = c("AIC")))
# -10.0192 smaller than -1.95: reject H0 that there is a unit root -> data is now stationary
# --> tests now show that TS is stationary

# plot the now stationary timeseries
Beds_TS %>% autoplot((Beds) %>% difference()) + labs(title = "Differenced and Shortened Time Series", x = "Months", y = "Beds (1st order differenced)")
# it is clearly also visually stationary now

##### 4. Testing for structural breaks ##### 

# perform the structural change test using the mean
breaks <- breakpoints(ts(Beds_TS) ~ 1)

# print the summary of the test results
summary(breaks)

# plot the breaks
plot(breaks)

# Quandt Likelihood Ratio (if we don't know where the break is)
# Prepare the data
abcd <- Beds_TS %>%
  as_tsibble() %>%
  mutate(
    Lag0 = Beds,
    Lag1 = lag(Beds),
    Year = Time)

# Calculate Fstats over the whole time
qlr <- Fstats(Lag0 ~ Lag1, data = as.ts(abcd), from = 0.01)

# Test if there is a breakpoint
test <- sctest(qlr, type = "supF")
test
# p-value 0.03575 under significance level (0.05) -> there is at least one breakpoint

# Find breakpoint with highest F statistic
breakpoints(qlr, alpha = 0.1)
# at observation number 119 = 2001 Nov

# Plot the F statistics and the breakpoint
plot(qlr, alpha = 0.1)
lines(breakpoints(qlr))


#Check for second breakpoint
abcdef <- Beds_TS %>%
  filter_index("2000 Jan" ~ .) %>% 
  as_tsibble() %>%
  mutate(
    Lag0 = Beds,
    Lag1 = lag(Beds),
    Year = Time)

# Calculate Fstats over the whole time
qlr <- Fstats(Lag0 ~ Lag1, data = as.ts(abcdef), from = 0.015)

# Test if there is a breakpoint
test <- sctest(qlr, type = "supF")
test
# p-value 0.04894 under significance threshold (0.05) -> there seems to be another break

# Find breakpoint with highest F statistic
breakpoints(qlr, alpha = 0.1)
# at observation number 253 = 2021 Jan

# Plot the F statistics and the breakpoint
plot(qlr, alpha = 0.1)
title(main = "F Statistics of the QLR Test", adj = 0)
lines(breakpoints(qlr))


#Check if we need to differentiate the shortened series
Beds_TS_short <- Beds_TS %>% 
  filter_index("2000 Jan" ~ .)

# KPSS: "tau" (including trend)
summary(ur.kpss(Beds_TS_short$Beds, type = "tau"))
# 0.3407 -> the test statistic is larger than the critical value at significance level at 5% (0.146)
# therefore we can reject H0 (H0 = data is stationary)
# i.e. we do have an indication that the data is non-stationary

# ADF:
# trend (including drift and trend)
# test accepts the null for γ and rejects the others --> have a unit root with drift and trend --> difference
summary(ur.df(Beds_TS_short$Beds, type = "trend", selectlags = c("AIC")))
# p-value of the intercept is below significance level = it is significant
# first test statistic value lower than critical value at tau3 (at all significance levels)
# --> Reject H0 (that there is a unit root) -> i.e. data seems to be stationary
# second test statistic value larger than critical level at 5%
# --> Reject H0 that there is a unit root with absent deterministic drift and trend 
# third test statistic value larger than critical level at 5%
# --> Reject H0 that there is a unit root with absent deterministic trend

# drift
summary(ur.df(Beds_TS_short$Beds, type = "drift", selectlags = c("AIC")))
# first: -1.598 is larger than -2.87 -> accept H0 that there is a unit root
# second: 1.8906 is smaller than 4.61 -> accept H0 = non stationarity (unit root) + absent drift 

# finding the optimal number of differences
Beds_TS_short %>%
  features(Beds, unitroot_ndiffs)
# the test suggest first order differencing of the time series

# applying first order differencing and redoing the tests that previously indicated non-stationarity
summary(ur.kpss(diff(Beds_TS_short$Beds), type = "mu"))
# 0.0327 below 0.463 at 5% -> data is stationary now

summary(ur.df(diff(Beds_TS_short$Beds), type = "trend", selectlags = c("AIC")))
# reject H0
# reject H0
# reject H0
summary(ur.df(diff(Beds_TS_short$Beds), type = "drift", selectlags = c("AIC")))
# first ts smaller than tau2 -> reject H0 of unit root -> data is stationary
# second ts larger than phi1 -> reject H0 of unit root with absent drift -> data now stationary 
summary(ur.df(diff(Beds_TS_short$Beds), type = "none", selectlags = c("AIC")))
# -10.0192 smaller than -1.95: reject H0 that there is a unit root -> data is now stationary
# --> tests now show that TS is stationary

# plot the now stationary timeseries
Beds_TS_short %>% autoplot((Beds) %>% difference())
# it is clearly also visually stationary now

#### 4. Split into train and test set ##### 

train <- Beds_TS_short %>%
  filter_index(. ~ "2018 Dec")

test <- Beds_TS_short %>%
  filter_index("2019 Jan" ~ .)

# Check train/test split
length(test$Beds) / length(train$Beds)
1- length(test$Beds) / length(train$Beds)
# 77.63% / 22.37%


##### 5. Identifying a suitable ARIMA model ####

# remind yourself about the data we are talking about again
Beds_TS_short %>%
  autoplot((Beds) %>% difference())

# Looking at ACF of differenced data to find the correct model
plot1 <- Beds_TS_short %>%
  ACF(diff(Beds)) %>%
  autoplot()

# Looking at PACF of differenced data to find the correct model
plot2 <- Beds_TS_short %>%
  PACF(diff(Beds)) %>%
  autoplot()

# Arrange the plots side by side
grid.arrange(plot1, plot2, ncol = 2)

# Non-seasonal components:
# significant AC in PAC strongest in lag 12 - however, this is because of the seasonality - looking at the AC and PAC close to lag 0, we see that significant AC can be seen in lags 1 and 2, and PAC can be seen only in lag 1
# AR component (p) = 1 and Moving average component (q) = 1 
# Differencing component (d): first order differencing as we have seen before to reduce positive trend

# Seasonal components:
# PACF plot: showing significant PAC at lag 1 -> p = 1 
# ACF plot: also showing significant AC at lag 1 -> d = 1
# Strong seasonality seen here, and also in previous analysis --> choose first order seasonal differencing

# Outcome:
# Set our manual model as (1,1,1)(1,1,1) [12]
# We will compare this model against a model generated by the auto ARIMA function


##### 6. ARIMA Models ####

# fitting the models
fit <- train %>%
  model(
    manual = ARIMA(Beds ~ 0 + pdq(1,1,1) + PDQ(1,1,1)),
    auto = ARIMA(Beds)
    )

# analyzing their reports
fit %>%
  select(manual) %>%
  report()

fit %>%
  select(manual2) %>%
  report()
fit %>%
  select(auto) %>%
  report()
# ARIMA(1,0,1)(1,1,0)[12]

# Autoregressive order (1): current value of the time series depends on the previous model (with lag = 1 included)
# Differencing order (0): no differencing applied (meaning that it already is stationary or does not require differencing)
# Moving average order (1): current value of the time series depends on the past forecast error (with lag = 1 included)

# Seasonal autoregressive order (1): current value of the time series depends on the previous value from the same season (with lag = 1 included)
# Seasonal differencing order (1): seasonal differencing applied to the TS (seasonal period = 12 in our case)
# Seasonal moving average order (0): current value of the time series does not depend on the past forecast error from the same season

# Seasonal periodicity (12): seasonal pattern with a period of 12 months = pattern repeats every 12 months

# plotting the residuals of the better model
fit %>%
  select(manual) %>%
  gg_tsresiduals(type = "innovation") + labs(x = "Months")

# ljung-box test on the residuals 
fit %>%
  select(manual) %>%
  residuals()  %>%
  features(.resid, features = ljung_box, lag = 24, dof = 7)

# shapiro-wilk test 
shapiro.test(fit %>%
               select(manual) %>%
               residuals() %>%
               select(.resid) %>%
               as.ts())

# actually visually inspect the forecast of the auto arima model against the original data
plot.5 <- fit %>%
  select(auto) %>%
  forecast(test) %>%
  autoplot(Beds_TS) + 
  labs(title = "Forecasts from auto model")

plot.6 <- fit %>%
  select(manual) %>%
  forecast(test) %>%
  autoplot(Beds_TS) + 
  labs(title = "Forecasts from manual model")

print(plot.5)

print(plot.6)

# assess accuracy
fit %>%
  forecast(test) %>%
  fabletools::accuracy(., Beds_TS)
# also from the accuracy measures on the test set the manual model outperforms the auto model

##### 6. ETS models #####

# manual model definition:
# in section 2.1 we found that there is a positive trend - not fully linear because of plateau between 2011? and 2016?, but steadily increasing so definitely not multiplicative - we will try with additive trend
# in section 2.2 we found that there is seasonality, since seasonal spikes stay constant over time, we select an additive seasonality (not multiplicative)
# additionally, could not see a multiplicative error in the ETS decomposition -> additive error chosen

fitETS <- train %>%
  model (
    auto = ETS(Beds),
    manual = ETS(Beds ~ error("A") + trend("Ad") + season("A"))
  )

# check out the reports for both ETS forecasts
fitETS %>%
  select(auto) %>%
  report()

fitETS %>%
  select(manual) %>%
  report()
# (A,Ad,A) was also chosen by auto model -> we don't have to choose the best model between them but can just continue with auto model as it is identical (also error terms will be the same)

# alpha (smoothing parameter for level/base of forecast) - higher means more weight given to recent observations than very old observations - 0.8607495 in our case, meaning model values recent changes relatively high, meaning it adapts quickly to changes (e.g. the plateau between 2011? and 2016?) - alpha = 1 means we have a naive method
# beta (smoothing parameter for trend component) - higher means more weight given to recent observations - 0.01559182 in our case, meaning the model looks at the general trend over most of the time series, not specifically only the recent years (makes sense since there has been no trend in recent years so the model tries to capture general trend over the years)
# gamma (smoothing parameter for seasonal component) - higher means more weight given to recent observations - 0.0001000446 very small in our case, meaning recent observations are not relevant to the model -> model more stable and less responsive to recent changes (makes sense since seasonality is very stable in our data)
# phi (damping parameter) - 1 means no damping applied to the trend - 0.9799993 in our case, meaning close to no damping is applied


# Residuals of forecast
fitETS %>%
  select(auto) %>%
  gg_tsresiduals(type = "innovation") + labs(x = "Months")

# Ljung-Box test -> H0 = autocorrelation of the residuals is 0
fitETS %>%
  select(auto) %>%
  residuals()  %>%
  features(.resid, features = ljung_box, lag = 20)
# p-value is 0.0254 -> smaller than 5% level -> reject H0 of no autocorrelation --> THERE seems to be autocorrelation in the residuals

# Shapiro-Wilk test -> H0 = sample has been generated from a normal distribution
shapiro.test(fitETS %>%
               select(auto) %>%
               residuals() %>%
               select(.resid) %>%
               as.ts())
# p-value is 2.458e-08 -> smaller than 5% level -> reject H0 that sample has been generated from normal distribution -> residuals are not normally distributed

# Forecast the data with ETS
fc.ets <- fitETS %>%
  select(auto) %>% 
  forecast(test)

plot.5 <- fitETS %>%
  select(auto) %>%
  forecast(test) %>%
  autoplot(Beds_TS) + 
  labs(title = "Forecasts from auto model (same as manual model)")


print(plot.5)

# Check accuracy
fabletools::accuracy(fc.ets, Beds_TS)

##### 7. Establishing a baseline model and finally comparing all models #####

finalModels <- train %>%
  model (
    #SNAIVE = SNAIVE(Beds),
    #ARIMA_auto = ARIMA(Beds),
    ETS = ETS(Beds),
    ARIMA = ARIMA(Beds ~ 0 + pdq(1,1,1) + PDQ(1,1,1))
  )

finalModels %>%
  forecast(h = length(test$Beds)) %>%
  autoplot(Beds_TS %>% filter_index("2019 Jan" ~ .), level = NULL) + labs(x = "Months")

# assess the accuracy of all models against each other
fabletools::accuracy(finalModels %>% forecast(h = length(test$Beds)), Beds_TS)

#plot.1 <- finalModels %>%
#  select(SNAIVE) %>%
#  forecast(PassengerCars_test) %>%
#  autoplot(PassengerCarsTS) + 
#  labs(title = "Forecasts from benchmark SNAIVE model")

# print the final forecasts
plot.1 <- finalModels %>%
  select(ETS) %>%
  forecast(test) %>%
  autoplot(Beds_TS) + 
  labs(title = "Forecast of the best ETS model")

plot.2 <- finalModels %>%
  select(ARIMA) %>%
  forecast(test) %>%
  autoplot(Beds_TS) + 
  labs(x = "Months")

show(plot.1)
show(plot.2)

# finally use the best performing model to generate a forecast for the next X years
fit <- Beds_TS %>%
  model (
    ARIMA <- ARIMA(Beds)
  )

fc <- fit %>%
  forecast(h = length(test$Beds)) %>%
  autoplot(Beds_TS)

show(fc)

