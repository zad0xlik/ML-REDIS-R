
# install.packages('quantmod')
# install.packages('foreach')
# install.packages('doRedis')

library('quantmod')
library('foreach')

#get symbols from yahoo
F <- getSymbols('F', from='2014-01-01', to='2014-12-31', auto.assign=FALSE)[,6]
AIG <- getSymbols('AIG', from='2014-01-01', to='2014-12-31', auto.assign=FALSE)[,6]

# Convert to returns
F <- diff(log(F))
AIG <- diff(log(AIG))

# Compute empirically observed beta
coef(lm(F ~ AIG))

# Bootstrap to get a sense of variability
n <- length(F)
t1 <- proc.time()

beta <- foreach(j=1:1000, .combine=c, 
                .multicombine=TRUE, .inorder=FALSE) %dopar%
  
{
  ind <- sample(n,n,replace=TRUE)
  coef(lm(F[ind] ~ AIG[ind]))[2]
}
print(proc.time() - t1)

hist(beta, col='yellow')
abline(v=coef(lm(F ~ AIG))[2],col='blue',lwd=2)

# now we will try to do this in parallel
library('doRedis')
registerDoRedis(queue='jobs')
startLocalWorkers(n=1, queue='jobs')
setChunkSize(250)

# Now we encapsulate the combine function in a closure that reports average
# performace everytime the combine function is called to aggregate results
f <- function()
{
  count <-0
  x <- 0
  y <-0
  time <- proc.time()[3]
  function(...)
  {
    count <<- count + length(list(...)) - 1
    dt <-proc.time()[3] - time
    cat("Average iterations per second: ", count/dt, "\n")
    x <<- c(x, dt)
    y <<- c(y, count/dt)
    plot(x,y,type="l", lwd=2, col=4, xlab="time (s)",
         main="Running average bootstrap iterations/s")
    Sys.sleep(0.01) # Yield to update the plot
    flush.console()
    c(...)
  }
}

g <- f()
# The following loop is 10x longer than before to help us get a feel for 
# the parallel speed up
beta <- foreach(j=1:1000000, .combine=g, .inorder=FALSE,
                .multicombine=TRUE, .maxcombine=250) %dopar%  
{
  ind <- sample(n,n,replace=TRUE)
  coef(lm(F[ind] ~ AIG[ind]))[2]
}





