## Primitive R script to plot as log and as linear each of the .csv
## size files in the data directory.
##
## Load zoo library
library(zoo)
## Load data
df <- read.csv("FFFF", header = FALSE)
## Create the time series setting any zero samples as NA to
## avoid log(0).
ts = lag(zoo( df$V2, df$V1 ),0)
is.na(df$V2) <- df$V2 == 0
tslog = lag(zoo( log(df$V2), df$V1 ),0)
## Prepare the plots
xlab="Date"
setEPS()
postscript("log_FFFF.eps")
ylab="FFFF (log LOC)"
plot(tslog,xlab=xlab,ylab=ylab,cex.lab=1.5,cex.axis=1.5,cex.main=1.5,cex.sub=1.5)
dev.off()
## Linear plot
ylab="FFFF (LOC)"
postscript("lin_FFFF.eps")
plot(ts,xlab=xlab,ylab=ylab,cex.lab=1.5,cex.axis=1.5,cex.main=1.5,cex.sub=1.5)
dev.off()
