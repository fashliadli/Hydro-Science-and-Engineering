library(ncdf4)  # read .nc files
library(fields)  # plot
library(rworldmap)  # coastlines and country borders
library(RColorBrewer)  # color palettes

setwd("E:/backup SSD/2025/TU Dresden/Hydro Science and Engineering/MHYWI05 Statitsitcal Learning/Exam")  # set working folder

#Open temperature data

nc_temp <- nc_open("temperature.nc")  # open temperature file

temp_time <- ncvar_get(nc_temp, varid = "time")  # time values
temp_lat <- ncvar_get(nc_temp, varid = "latitude")  # latitude values
temp_lon <- ncvar_get(nc_temp, varid = "longitude")  # longitude values
temp <- ncvar_get(nc_temp, varid = "tg")  # temperature values (lon x lat x time)

nc_close(nc_temp)  # close file

#Open precipitation data

nc_prep <- nc_open("precipitation.nc")  # open precipitation file

prep_time <- ncvar_get(nc_prep, varid = "time")  # time values
prep_lat <- ncvar_get(nc_prep, varid = "latitude")  # latitude values
prep_lon <- ncvar_get(nc_prep, varid = "longitude")  # longitude values
prep <- ncvar_get(nc_prep, varid = "rr")  # precipitation values (lon x lat x time)

nc_close(nc_prep)  # close file

#Check

low_temp <- min(temp, na.rm = TRUE) # lowest temperature value
high_temp <- max(temp, na.rm = TRUE) # highest temperature value

low_prep <- min(prep, na.rm = TRUE) # lowest precipitation value
high_prep <- max(prep, na.rm = TRUE) # highest precipitation value

  
#Fitting at each location

# Temp
coef_temp <- function(x) {  # function for one location's time series
  if (all(is.na(x))) return(c(NA, NA))  # no data, return NA
  s <- summary(lm(x ~ temp_time))  # linear regression against time
  co <- s$coefficients[2,c(1,4)]  # slope and p-value
  return(co)  # return them
  
}

# Prep
coef_prep <- function(x) {  # function for one location's time series
  if (all(is.na(x))) return(c(NA, NA))  # no data, return NA
  s <- summary(lm(x ~ prep_time))  # linear regression against time
  co <- s$coefficients[2,c(1,4)]  # slope and p-value
  return(co)  # return them
  
}

#Applying coefficient to every location
temp_cp <- apply(temp,1:2,coef_temp)  # slope and p-value at every temperature location
prep_cp <- apply(prep,1:2,coef_prep)  # slope and p-value at every precipitation location

#Pallete
col_temp <- rev(brewer.pal(11, "RdYlBu"))  # red = high, blue = low
col_prep <- (brewer.pal(11, "RdYlBu"))  # flipped: red = drier, blue = wetter
data("countriesCoarse")  # load country borders


#Limit
lim_temp <- max(abs(temp_cp[1,,]), na.rm = TRUE)  # largest absolute slope, sets color range
lim_prep <- max(abs(prep_cp[1,,]), na.rm = TRUE)  # largest absolute slope, sets color range


#Plot All
par(mfrow = c(1, 2))  # two plots side by side

image.plot(temp_lon, temp_lat, temp_cp[1,,], col = col_temp, zlim=c(-lim_temp,lim_temp),  # temperature trend map
           main = "Temperature Trend", xlim = range(temp_lon) + c(-1, 1), ylim = range(temp_lat) + c(-1, 1))  # title and extra margin around map
plot(coastsCoarse, add = TRUE)  # add coastlines
plot(countriesCoarse, add = TRUE)  # add country borders

image.plot(prep_lon, prep_lat, prep_cp[1,,], col = col_prep, zlim=c(-lim_prep, lim_prep),  # precipitation trend map
           main = "Precipitation Trend", xlim = range(prep_lon) + c(-1, 1), ylim = range(prep_lat) + c(-1, 1))  # title and extra margin around map
plot(coastsCoarse, add = TRUE)  # add coastlines
plot(countriesCoarse, add = TRUE)  # add country borders


#Strongest Trend = highest slope
max_trend_temp <- max(abs(temp_cp[1,,]), na.rm = TRUE)  # strongest temperature trend
max_trend_prep <- max(abs(prep_cp[1,,]), na.rm = TRUE)  # strongest precipitation trend

# Locations contain significant trends (Normal)
sig_temp <- sum(temp_cp[2,,] < 0.05, na.rm = TRUE)  # temperature locations with p < 0.05
sig_prep <- sum(prep_cp[2,,] < 0.05, na.rm = TRUE)  # precipitation locations with p < 0.05

# False Positive
n_temp <- sum(!is.na(temp_cp[1,,]))  # temperature locations with data
n_prep <- sum(!is.na(prep_cp[1,,]))  # precipitation locations with data

false_pos_temp <- n_temp * 0.05  # expected false positives (locations x 0.05)
false_pos_prep <- n_prep * 0.05  # expected false positives (locations x 0.05)

#Significance modification using Benjamini-Hochberg
q_prep_bh <- matrix(p.adjust(prep_cp[2,,], method = "BH"),160,160)  # BH-adjusted p-values as 160 x 160 grid
q_temp_bh <- matrix(p.adjust(temp_cp[2,,], method = "BH"),160,160)  # BH-adjusted p-values as 160 x 160 grid

# Locations contain significant trends (BH)
sig_temp_bh <- sum(q_temp_bh<0.1, na.rm = TRUE)  # temperature locations with q < 0.1
sig_prep_bh <- sum(q_prep_bh<0.1, na.rm = TRUE)  # precipitation locations with q < 0.1

#Filter only significant based on BH
temp_sig <- temp_cp[1,,]  # copy temperature slopes
temp_sig[q_temp_bh >= 0.1] <- NA  # remove non-significant ones

prep_sig <- prep_cp[1,,]  # copy precipitation slopes
prep_sig[q_prep_bh >= 0.1] <- NA  # remove non-significant ones

#Legend limit
lim_sig_temp <- max(abs(temp_sig), na.rm = TRUE)  # largest absolute slope among significant ones
lim_sig_prep <- max(abs(prep_sig), na.rm = TRUE)  # largest absolute slope among significant ones

#Plot significant only (BH)
image.plot(temp_lon, temp_lat, temp_sig, col = col_temp, zlim=c(-lim_sig_temp, lim_sig_temp),  # significant temperature slopes map
           main = "Temperature Trend",xlim = range(temp_lon) + c(-1, 1), ylim = range(temp_lat) + c(-1, 1))  # title and extra margin around map
plot(coastsCoarse, add = TRUE)  # add coastlines
plot(countriesCoarse, add = TRUE)  # add country borders


image.plot(prep_lon, prep_lat, prep_sig, col = col_prep, zlim=c(-lim_sig_prep, lim_sig_prep),  # significant precipitation slopes map
           main = "Precipitation Trend",xlim = range(prep_lon) + c(-1, 1), ylim = range(prep_lat) + c(-1, 1))  # title and extra margin around map
plot(coastsCoarse, add = TRUE)  # add coastlines
plot(countriesCoarse, add = TRUE)  # add country borders

#Calling some values

#Low and high
low_temp 
high_temp
low_prep 
high_prep

#Strongest trend
max_trend_temp
max_trend_prep

#Number of locations that are significant (using alpha=0.05)
sig_temp
sig_prep

#Expected false positive (using alpha=0.05)
false_pos_temp
false_pos_prep

#Number of locations that are significant (using q=0.1)
sig_temp_bh
sig_prep_bh

#Expected false positive (using q=0.1)
sig_temp_bh*0.1
sig_prep_bh*0.1
