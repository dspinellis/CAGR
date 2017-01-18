#!/usr/local/bin/Rscript
#
# Create the Mars exploration size figure
#

library('ggplot2')
library('scales')

mars <- read.csv('mars.csv', header=TRUE, sep="\t")

postscript("mars.eps")

qplot(Year, LOC, data=mars, geom=c('point'), label=Name) +
  theme_bw(base_size = 24) +
  ylab("Lines of code") +
  geom_text(hjust=1.1, vjust = 0, size = 10) +
  scale_y_log10(labels = trans_format("log10", math_format(10^.x))) +
  geom_smooth(method = "lm", se=FALSE, color="blue") +
  coord_cartesian(xlim = c(1968, 2012), ylim = c(1e3, 1e7)) +
  geom_text(data = data.frame(), aes(1975, 4e6, label = "CAGR = 1.2"), size = 10)
