#!/bin/sh
#
#	Script to rummage through the whole data directory, counting the maximum,
#	and last line line count.
#---------------------------------------------------------------------
if test $# -ne 1
then
	echo "Usage: $0 [output csvfile] "
	exit
fi

CSVDIR=../data
RDATA=../analyses/$1

find $CSVDIR -name '*.csv' -exec extract_lines.pl -c {} \; \
	| sort -n		> $RDATA

count_lines.pl -c $RDATA
