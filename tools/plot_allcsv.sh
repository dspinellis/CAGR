#!/bin/sh
#	Script to rummage through the whole data directory, plotting csv
#	files using an R template.
#---------------------------------------------------------------------
if test $# -ne 0
then
	echo "Usage: $0"
	exit
fi

CSVDIR=../data
#
#	-d n - drop the first n lines from the normalisation.
#	-l   - output log of lines
#
find $CSVDIR -name '*.csv' -exec plot_onecsv.sh {} \;
