#
#	R script to compare oss and css data using
#	Wilcoxon-Mann-Whitney nonparametric test.
#
#-----------------------------------------
#	Read from data files created by prepare_wilcox.sh.
p25_75_css <- read.table("../analyses/p25_75_css.dat",header=FALSE)
#	Read into vector
vp25_75_css <- as.vector(p25_75_css$V1)

p25_75_oss <- read.table("../analyses/p25_75_oss.dat",header=FALSE)
#	Read into vector
vp25_75_oss <- as.vector(p25_75_oss$V1)

#	Observations are not paired.
wilcox.test( vp25_75_oss, vp25_75_css )
#-----------------------------------------
