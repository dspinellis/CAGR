#
#	R script to compute approximate error bounds for growth
#	rates using median() and mad() functions of R.
#
#	It does this from three different datasets.
#	- the 0-100 percentile sizes
#	- the 25-75 percentile sizes
#	- the best linear fit.
#
#	The script goes on to produce quartiles for the time distribution
#	and correlation computations for time v. growth as well as a plot.
#-------------------------------------------------------------
#	Stop it rotating everything for latex,
setEPS()
#
#	Read from data files created by run_growth.sh
p0_100 <- read.table("../analyses/p0_100.dat",header=FALSE)
#	Read into vector
vp0_100 <- as.vector(p0_100$V1)
#	Plot mode on to produce file used in paper.
postscript(file = "../doc/p0_100stats.eps", horizontal = FALSE)
par(mfrow=c(1,3))
boxplot(vp0_100,ylab="End-point growth")
hist(vp0_100)
qqnorm(vp0_100)
qqline(vp0_100)
dev.off()
#	Summary and approximate calculation using
#	http://www.dst.unive.it/rsr/BelVenTutorial.pdf, p. 10-11.
summary(vp0_100)
se.med <- sqrt((pi/2)*(mad(vp0_100)^2/length(vp0_100)))
median(vp0_100) - qnorm(0.975)*se.med
median(vp0_100) + qnorm(0.975)*se.med

median(vp0_100) - qnorm(0.995)*se.med
median(vp0_100) + qnorm(0.995)*se.med
#-----------------------------------------
#	Read from data files created by run_growth.sh
p25_75 <- read.table("../analyses/p25_75.dat",header=FALSE)
#	Read into vector
vp25_75 <- as.vector(p25_75$V1)
#	Plot mode on to produce file used in paper.
postscript(file = "../doc/p25_75stats.eps")
par(mfrow=c(1,3))
boxplot(vp25_75)
hist(vp25_75)
qqnorm(vp25_75)
qqline(vp25_75)
dev.off()
#	Summary and approximate calculation using
#	http://www.dst.unive.it/rsr/BelVenTutorial.pdf, p. 10-11.
summary(vp25_75)
se.med <- sqrt((pi/2)*(mad(vp25_75)^2/length(vp25_75)))
median(vp25_75) - qnorm(0.975)*se.med
median(vp25_75) + qnorm(0.975)*se.med

median(vp25_75) - qnorm(0.995)*se.med
median(vp25_75) + qnorm(0.995)*se.med
#-----------------------------------------
#	Read from data files created by run_growth.sh
bestfit <- read.table("../analyses/bestfit.dat",header=FALSE)
#	Read into vector
vbestfit <- as.vector(bestfit$V1)
#	Plot mode on to produce file used in paper.
postscript(file = "../doc/bestfitstats.eps")
par(mfrow=c(1,3))
boxplot(vbestfit)
hist(vbestfit)
qqnorm(vbestfit)
qqline(vbestfit)
dev.off()
#	Summary and approximate calculation using
#	http://www.dst.unive.it/rsr/BelVenTutorial.pdf, p. 10-11.
summary(vbestfit)
se.med <- sqrt((pi/2)*(mad(vbestfit)^2/length(vbestfit)))
median(vbestfit) - qnorm(0.975)*se.med
median(vbestfit) + qnorm(0.975)*se.med

median(vbestfit) - qnorm(0.995)*se.med
median(vbestfit) + qnorm(0.995)*se.med
#-----------------------------------------
#	Script to plot the correlation between CAGR and time/size.
#
time <- scan('cagr_corr_x_g.txt')
growth <- scan('cagr_corr_y_g.txt')
#
#	Add 1 to vector to produce CAGR, (the original data contains only the fractional growth).
#
growth = growth + 1
#
#	Set up the postscript graphics device.
#
setEPS()
postscript("../doc/time_growth.eps")
#
#	Plot the cross-correlation of time and CAGR.
#
plot(time,growth,xlab="Project duration (years)",ylab="CAGR")
#
#	Linear analysis.
#
cagr_corr <- data.frame(x=time,y=growth)
fm=lm(y~x,data=cagr_corr)
summary(fm)

size <- scan('cagr_corr_x_s.txt')
growth <- scan('cagr_corr_y_s.txt')
#
#	Add 1 to vector to produce CAGR, (the original data contains only the fractional growth).
#
growth = growth + 1
#
#	Set up the postscript graphics device.
#
setEPS()
postscript("../doc/size_growth.eps")
#
#	Plot the cross-correlation of time and CAGR.
#
plot(size,growth,xlab="Project size (LOC)",ylab="CAGR")
#
#	Linear analysis.
#
cagr_corr <- data.frame(x=size,y=growth)
fm=lm(y~x,data=cagr_corr)
summary(fm)
#
#	Quartiles.
#
summary(time)
summary(size)
#
#	End plotting device.
#
dev.off()
#-----------------------------------------
