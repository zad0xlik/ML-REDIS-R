##################################################################
##project name:R Anomaly Detection
##date modified:2/11/2015
##comments:The query below pulls data from PostgreSQL optionts
##table and conducts anomaly detectioin analysis with R. 
##################################################################

install.packages ("RPostgreSQL")
install.packages ("DBI")
install.packages ("fda")
install.packages("devtools")
install.packages ("reshape", "chron")
##pp: install package for hashing password
if (!require("devtools")) install.packages("devtools")


##fmk: need clarification on model that is being used
devtools::install_github("twitter/AnomalyDetection")
##pp: load scrypt package for password hashing
devtools::install_github("rstudio/rscrypt")
library(AnomalyDetection)
library (RPostgreSQL)
library (DBI)
library (reshape)
library (chron)

drv = dbDriver("PostgreSQL")

##fmk: password needs to get hashed through another function
##pp: hash password
hashed1 <- scrypt::hashPassword("xxx")
scrypt::verifyPassword(hashed1, "xxx")

con = dbConnect(drv, user = "xxx", password = "xxx", dbname = "QTRACK", host = "xxx", port = 5432)
rs <- dbGetQuery (con, "select (load_date || ' ' || load_time)::timestamp, call_implied_volatility from optionsnapshot where load_date='2015-01-16' order by cast(load_time as time)")

dt <- as.data.frame(rs)
model <- AnomalyDetectionVec(dt[,2], max_anoms=0.2, period=7, direction='both', only_last=FALSE, plot=TRUE)
md <- print(model)

#####

library("devtools")
install_github("ropensci/plotly")
library(plotly)

##fmk: password needs to get hashed through another function
##pp: hash password
hashed2 <- scrypt::hashPassword("xylj590nlr") 
set_credentials_file("phoenixpei","xylj590nlr")
py <- plotly()

##pp: dt[,1] includes timestamp. needs to find the right way to bring it to data parameter
data <- list( list(x=dt[,1], y=dt[,2]))

response <- py$plotly(data,kwargs=list(filename="Anomalies Detection", fileopt="overwrite"))

browseURL(response$url)

##fmk: additional section needs to be created to store plot results into a postgres table
dbWriteTable(con, name = "anomalystream", md)

con = dbConnect(drv, user = "xxx", password = "xxx", dbname = "QTRACK", host = "xxx", port = 5432)
rs <- dbGetQuery (con, "select (load_date || ' ' || load_time)::timestamp, call_implied_volatility from optionsnapshot where load_date='2015-01-16' order by cast(load_time as time)")

dt <- as.data.frame(rs)
AnomalyDetectionVec(dt[,2], max_anoms=0.2, period=7, direction='both', only_last=FALSE, plot=TRUE)

res = AnomalyDetectionTs(rs, max_anoms=0.02, direction='both', plot=TRUE)
res$plot


#####

library("devtools")
install_github("ropensci/plotly")
library(plotly)

##fmk: password needs to get hashed through another function
##pp: hash password
hashed2 <- scrypt::hashPassword("xylj590nlr") 
set_credentials_file("phoenixpei","xylj590nlr")
py <- plotly()

##pp: dt[,1] includes timestamp. needs to find the right way to bring it to data parameter
data <- list( list(x=dt[,1], y=dt[,2]))

response <- py$plotly(data,kwargs=list(filename="Anomalies Detection", fileopt="overwrite"))

browseURL(response$url)

##fmk: additional section needs to be created to store plot results into a postgres table
dbWriteTable(con, name = "anomalystream",dt)
dbDisconnect(con)			

