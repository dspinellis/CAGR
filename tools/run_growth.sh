#!/bin/sh
#	Script to run full growth analysis on data.
#---------------------------------------------------------------------
ALL=../analyses/allgrowths.csv
IALL=../analyses/allgrowths_impact.csv

#	-------------------------
#	Extract the OS growth data.
#
get_allgrowths.sh $ALL $IALL
#	-------------------------
#	Prepares data files for R analysis from the raw data.
#	This growth population does not use the impact data.
#
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -u >	../analyses/bestfit.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -v >	../analyses/p25_75.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -w >	../analyses/p0_100.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -y >	../analyses/summary.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -q >	../analyses/xy.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -n >	../analyses/tg.dat
calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -k >	../analyses/ts.dat

calc_growth.pl -c $ALL -s 10 -x 1000000000 -t 1 -m 0 -z >	../doc/summary-latex.tex

cat	../analyses/tg.dat			| awk '{print $1;}'	> cagr_corr_x_g.txt
cat	../analyses/tg.dat			| awk '{print $2;}'	> cagr_corr_y_g.txt

cat	../analyses/ts.dat			| awk '{print $1;}'	> cagr_corr_x_s.txt
cat	../analyses/ts.dat			| awk '{print $2;}'	> cagr_corr_y_s.txt
#	-------------------------
#	Now perform growth test using median() and mad().
#
R	-q --no-save < analysis_growth.R > ../analyses/growth_results.txt
#	-------------------------

echo "Results in ../analyses/growth_results.txt, summary in ../analyses/summary.dat"
