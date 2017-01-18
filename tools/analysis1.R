#
#	R script to compute approximate error bounds for growth
#	rates using median() and mad() functions of R.
#
#	Read from data files created by prepare_r.sh.
p0_100 <- read.table("../analyses/p0_100.dat",header=FALSE)
#	Read into vector
vp0_100 <- as.vector(p0_100$V1)

#	Plot mode on to produce file used in paper.
postscript(file = "../doc/p0_100stats.eps", horizontal = FALSE)
# Plot parameter: 1 row, 3 columns
par(mfrow=c(1,3))
# Magnification of X and Y axis labels
par(cex.lab=2.0)
# Magnification of X and Y axis annotation
par(cex.axis=2.0)
# Clip plotting to figure region
par(xpd=NA)

boxplot(vp0_100)
hist(vp0_100)
qqnorm(vp0_100)

# Restore clipping to plot region (otherwise line is drawn outside it)
par(xpd=FALSE)
qqline(vp0_100)

dev.off()
#	Summary and approximate calculation using
#	http://www.dst.unive.it/rsr/BelVenTutorial.pdf, p. 10-11.
summary(vp0_100)
se.med <- sqrt((pi/2)*(mad(vp0_100)^2/length(vp0_100)))
median(vp0_100) - qnorm(0.975)*se.med
median(vp0_100) + qnorm(0.975)*se.med
#-----------------------------------------
#	Read from data files created by prepare_r.sh.
p25_75 <- read.table("../analyses/p25_75.dat",header=FALSE)
#	Read into vector
vp25_75 <- as.vector(p25_75$V1)
#	Plot mode on to produce file used in paper.
postscript(file = "../doc/p25_75stats.eps")
par(mfrow=c(1,3))
par(cex.lab=2.0)
par(cex.axis=2.0)
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
#-----------------------------------------
