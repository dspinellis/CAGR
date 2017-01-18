#!/bin/sh
#	Script to rummage through the whole data directory, extracting normalised
#	points ready to dump into R.
#---------------------------------------------------------------------
if test $# -ne 1
then
	echo "Usage: $0 [output csvfile] "
	exit
fi

CSVDIR=../data
RDATA=../analyses/$1
#
#	-d n - drop the first n lines from the normalisation.
#	-l   - output log of lines
#
find $CSVDIR -name '*.csv' -exec normalise_points.pl -d 5 -l -c {} \; \
	| sort -n		> $RDATA
