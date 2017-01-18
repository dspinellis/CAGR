#!/bin/sh
#	Script to rummage through the whole data directory, extracting growth stats.
#---------------------------------------------------------------------
if test $# -ne 2
then
	echo "Usage: $0 [output csvfile] [output impact csvfile] "
	exit
fi

ICSVDIR=../impactdata
CSVDIR=../data

OSDATA=../analyses/$1
IMPACTDATA=../analyses/$2
#
#	Note that the impact data does not have entries removed from the beginning as
#	they may only be two entries.  The OS data is multiple point, extracted automatically.
#
find $CSVDIR -name '*.csv' -exec extract_growth.pl -d 2 -c {} \; 	> $OSDATA
find $ICSVDIR -name '*.csv' -exec extract_growth.pl -d 0 -c {} \; 	> $IMPACTDATA
#
#	Remove the Impact yawl dataset as it is not proprietary.
#
egrep -v impact_yawl $IMPACTDATA > temp$$
mv temp$$ $IMPACTDATA
#
#	Remove the saferc, gundalf and master datapoints are they are proprietary.
#
egrep -v gundalf_gui $OSDATA > temp$$
mv temp$$ $OSDATA
egrep -v saferc_engine $OSDATA > temp$$
mv temp$$ $OSDATA
egrep -v "/master.csv" $OSDATA > temp$$
mv temp$$ $OSDATA
