#!/bin/sh
#	Script to plot one .csv files in the data directory by driving an
#	R script.
#---------------------------------------------------------------------
if test $# -ne 1
then
	echo "Usage: [csvfile] "
	exit
fi

rm	-f temp$$.R

TARGET=../codeplots
csvfile=$1
bname=`basename $csvfile .csv`
#
#	Have to copy it locally to stop sed having conniption fits.
#
cp $csvfile	$bname

cat	plot_template.R	\
	| sed 's/FFFF/'"${bname}"'/g' \
	> temp$$.R

R	-q --no-save < temp$$.R
mv 	lin_$bname.eps log_$bname.eps	$TARGET

rm	-f temp$$.R	$bname
