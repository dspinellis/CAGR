#
#	Read in the trimmed dataset.
#
p0_100 <- read.table("../analyses/p0_100_trimmed.dat", header=FALSE)
#
#	Add 1 to vector to produce CAGR, (the original data contains only the fractional growth).
#
p0_100t = p0_100 + 1
#
#	Produce approximate normal distribution with correct robust parameters.
#
nx <- seq(1,3,by=.01)
ny <- dnorm(nx,mean=1.18,sd=0.016)
#
#	Set up the postscript graphics device.
#
setEPS()
postscript("../doc/boxplot.eps")

par(fig=c(0,0.8,0,0.8), new=TRUE)
plot(nx,ny,type="l",xlab="CAGR",ylab="")
#
#	Box and whiskers plot.
#
par(fig=c(0,0.8,0.55,1), new=TRUE)
boxplot(p0_100t,data=p0_100t,col=(c("gold")),varwidth=TRUE,horizontal=TRUE,axes=FALSE,frame.plot=TRUE)
#
#	Add a title.
#
title(main="CAGR boxplot of 0-100th percentile data",xlab="Robust Normal Approximate Distribution")
#
#	After much guesswork, annotate the median.
#
text(1.45,0.53,"Median = 1.18",col="red")
#
#	Increase the tick resolution for an x-axis.
#
c <- c(1:50)
x <- c/10
#
#	Plot the x-axis
#
#axis(1,at=x,labels=)
#
#	End plotting device.
#
dev.off()
