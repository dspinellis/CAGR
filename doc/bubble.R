#!/usr/local/bin/Rscript
#
# Create bubble chart of software size vs sales volume
#


# Keep only integer 10^X values
keep10 <- function(x) {
  x[which(x/10^floor(log10(x)) == 1)]
}

bubble <- read.csv('bubble.csv', header=TRUE, sep="\t")

setEPS()
postscript("bubble.eps")

# Draw circles
symbols(
  bubble$Volume,
  bubble$Size,
  rep(1, each=length(bubble$Size)),
  inches=0.4,
  fg='white',
  bg='cyan',
  xlab='Volume of unique users per year',
  ylab='Software size in LOC',
  log="xy",
  xaxt='n',
  yaxt='n',
  xlim=c(0.5, 1e9),
  ylim=c(9e4, 1e8)
)

# Add labels
text(bubble$Volume, bubble$Size, bubble$Name, cex=0.7)

# Draw x axis
atx <- keep10(axTicks(1))
labelsx <- sapply(atx, function(i) {
	      j <- log10(i)
	      if (j == 0) {
		1
	      } else {
		as.expression(bquote(10^ .(j)))
	      }
	    }
          )
axis(1, at=atx,labels=labelsx)


# Draw y axis
aty <- keep10(axTicks(2))
labelsy <- sapply(aty, function(i) {
	      j <- log10(i)
	      as.expression(bquote(10^ .(j)))
	    }
          )
axis(2, at=aty,labels=labelsy)

dev.off()
