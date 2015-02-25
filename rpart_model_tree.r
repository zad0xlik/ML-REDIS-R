##############################################################################################################
##Make sure to install all packages prior running script
##############################################################################################################


##install.packages('rattle')
##install.packages('rpart.plot')
##install.packages('RColorBrewer')
##install.packages('xlsx')
##install.packages('party')
##install.packages('randomForest')
##install.packages("RPostgreSQL")
##install.packages("DBI")
##install.packages("scrypt")

##install.packages("networkD3")
##install.packages("devtools")
##install.packages("partykit")
##install.packages("rlist")
##install.packages("pipeR")
##install.packages("data.table")

##devtools::install_github("timelyportfolio/networkD3@feature/d3.chart.layout")

library(RPostgreSQL)
library(DBI) # These first two packages are for building connection with PostgreSQL
library(rattle)
library(rpart.plot)
library(RColorBrewer)
library(xlsx)
library(party)
library(partykit)
library(strucchange) # For the sctest function to extract p-values (see help for ctree and sctest)
library(randomForest) # readme - rfNews()
library(htmltools) 
library(rlist)
library(pipeR)
library(data.table)
library(networkD3)

# <<<<<<< e5f0a1411120735bcbe2f9edca01c178e6d90b49
# setwd("/Professional/CODES") # set dir
# mydata <- read.xlsx("Workbook.xlsx", 1) # change tabs
# mydata <- mydata[1:40,]
# 
# attach(mydata)
# 
# rpart_model <- rpart(qty ~ call_option_symbol + call_bid_ask_size, data=mydata, method="class",control=rpart.control(minsplit=20, cp=0))
# par(mfrow = c(1,2), xpd = TRUE)
# 
# ##attributes(rpart_model)
# print(rpart_model)
# ##plot(rpart_model, uniform=T)
# fancyRpartPlot(rpart_model, uniform=TRUE, main="Classification Tree for Optionsnapshot")
# text(rpart_model, use.n=TRUE, all=TRUE, cex=.8)
# 
# detach(mydata)

# drv = dbDriver("PostgreSQL")
# hashed1 <- scrypt::hashPassword("otsosika")
# scrypt::verifyPassword(hashed1, "otsosika")
# con = dbConnect(drv, user = "postgres", password = "otsosika", dbname = "QTRACK", host = "76.100.253.70", port = 5432)

# setwd("/Professional/CODES/r_anomaly_detect")
setwd("C:/QTRACK/PROGRAMS/r_anomaly_detect")
mydata <- read.xlsx("tree_1.xlsx", 1) # change tabs
mydata <- mydata[1:46,]

# attach(mydata)

##############################################################################################################
##Regression Tree
##############################################################################################################
rpart_model1 <- rpart(oi ~ strike + dte + volume, data = mydata, control = rpart.control(minsplit=20, cp = 0))


rpk <- as.party(rpart_model1)


## get meta information
rpk.text <- capture.output( print(rpk) ) %>>%
  ( .[grep( x = ., pattern = "(\\[)([0-9]*)(\\])")] ) %>>%
  strsplit( "[\\[\\|\\]]" , perl = T) %>>%
  list.map(
    tail(.,2) %>>%
      (
        data.frame(
          "id" = as.numeric(.[1])
          , description = .[2]
          , stringsAsFactors = F )
      )
  ) %>>% list.stack

# binding the node names from rpk with more of the relevant meta data from rp
# i don't think that partykit imports this automatically for the inner nodes, so i did it manually
rpk.text <- cbind(rpk.text, rpart_model1$frame)

# rounding the mean DV value
rpk.text$yval <- round(rpk.text$yval, 2)

# terminal nodes have descriptive stats in their names, so I stripped these out
# so the final plot wouldn't have duplicate data
rpk.text$description <- sapply(strsplit(rpk.text[,2], ":"), "[", 1)

dat = rapply(rpk$node,unclass,how="replace")

#fill in information at the root level for now
#that might be nice to provide to our interactive graph
dat$info = rapply(
  unclass(rpk$data)[-1]
  ,function(l){
    l = unclass(l)
    if( class(l) %in% c("terms","formula","call")) {
      l = paste0(as.character(l)[-1],collapse=as.character(l)[1])
    }          
    attributes(l) <- NULL
    return(l)
  }
  ,how="replace"
)

dat = jsonlite::toJSON(
  dat
  ,auto_unbox = T
)

# replace kids with children to ease d3
dat = gsub( x=dat, pattern = "kids", replacement="children")

# change id to node to ease d3; will replace with name later
dat = gsub ( x=dat, pattern = '"id":([0-9]*)', replacement = '"name":"node\\1","size":nodesize\\1' )


# calling the root node by the dataset name, but it might make more sense to call it
# "root" so that the code can be generalized
dat = sub (x = dat, pattern = "node1", replacement = "root")

# replacing the node names from node1, node2, etc., with the extracted node names and metadata from
# rpk.text, and rp$table. 
for (i in 2:nrow(rpk.text)) {
  dat = sub (
    x = dat
    , pattern = paste("node", i, sep = "")
    , replacement = paste(
      rpk.text[i,2]
      , ", mean = ", rpk.text[i,7]
      , ", n = ", rpk.text[i,4]
      , sep = ""
    )
    , fixed = T
  )

  dat = sub (
    x = dat
    , pattern = paste("nodesize", i, sep = "")
    , replacement = rpk.text[i,4]
    , fixed = T
  )
}
 

# replace size of root or node1
dat = sub (
  x = dat
  , pattern = "nodesize1"
  , replacement = rpk.text[1,4]
  , fixed = T
)

hN <- hierNetwork( jsonlite::fromJSON(dat), zoomable = T, collapsible = T )

# fromJSON does not translate well so manual override
hN$x$root = dat
lapply(
  c(
      "pack.nested"
     ,"pack.flattened"
     ,"partition.arc"
     ,"partition.rectangle"
     ,"treemap"
     ,"tree.cartesian"
  )
  ,function(chartType){
    hN$x$options$type = chartType
    return(hN) 
  }
)

##############################################################################################################
##############################################################################################################