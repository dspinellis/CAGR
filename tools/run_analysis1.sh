#!/bin/sh
#	Script to run mad analysis on data.
#	R script.
#---------------------------------------------------------------------
if test $# -ne 0
then
	echo "Usage: $0"
	exit
fi

R	-q --no-save < analysis1.R
