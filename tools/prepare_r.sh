#!/bin/sh
#
#	Prepares data files for R analysis from the raw data.
#
calc_growth.pl -c ../analyses/allgrowths.csv -s 10 -x 1000000000 -t 1 -m 5 -v >	../analyses/p25_75.dat
calc_growth.pl -c ../analyses/allgrowths.csv -s 10 -x 1000000000 -t 1 -m 5 -w >	../analyses/p0_100.dat
