souinstall.packages ("RPostgreSQL")
install.packages ("DBI")
install.packages ("fda")
install.packages("devtools")
install.packages ("reshape", "chron")
devtools::install_github("twitter/AnomalyDetection")
library(AnomalyDetection)
library (RPostgreSQL)
library (DBI)
library (reshape)
library (chron)

drv = dbDriver("PostgreSQL")
con = dbConnect(drv, user = "ppei", password = "Ready2go", dbname = "QTRACK", host = "50.168.76.47", port = 5432)
rs <- dbGetQuery (con, "select load_date || ' ' || load_time, call_implied_volatility from optionsnapshot where load_date='2015-01-16' order by cast(load_time as time)")
rs <- dbGetQuery (con, "select load_date || ' ' || load_time, call_implied_volatility from optionsnapshot where load_date='2015-01-16' order by load_time")
dt <- as.data.frame(rs)
AnomalyDetectionVec(dt[,2], max_anoms=0.2, period=10, direction='both', only_last=FALSE, plot=TRUE)

res = AnomalyDetectionTs(rs, max_anoms=0.02, direction='both', plot=TRUE)
res$plot


#####
rs <- dbSendQuery (con, "select load_time, call_implied_volatility from optionsnapshot where load_date='2015-01-21' order by load_time")
df <- fetch(rs, n= -1)
dt <- as.data.frame(df)
AnomalyDetectionVec(dt[,2], max_anoms=0.2, period=10, direction='both', only_last=FALSE, plot=TRUE)


#####

library("devtools")
install_github("ropensci/plotly")
library(plotly)

set_credentials_file("phoenixpei","xylj590nlr")
py <- plotly()

data <- list( list(x=dt[,1], y=dt[,2]))

response <- py$plotly(data,kwargs=list(filename="Anomalies Detection", fileopt="overwrite"))

browseURL(response$url)





