#!/bin/sh
#
#	Prepares data files for Wilcoxon R analysis to detect any possible
#	difference between commercial impact columns and open source data.
#
#	(Sledgehammer method, very ugly.  Elegant programmers please look away.)
#	-------------------------
#	Define the two datasets.  run_growth.sh must be run first.
#
OSS=../analyses/allgrowths.csv
CSS=../analyses/allgrowths_impact.csv
#	-------------------------
#	Perform winnowing.  Note that no trimming is applied in this
#	case as there are very few CSS points so for consistency
#	we treat both the same.  (Trimming OSS and not CSS makes
#	no significant difference it turns out.)
#
calc_growth.pl -c $OSS -s 10 -x 1000000000 -t 1 -m 0 -w >	../analyses/p0_100_oss.dat
calc_growth.pl -c $CSS -s 10 -x 1000000000 -t 1 -m 0 -w >	../analyses/p0_100_css.dat
#	-------------------------
#	Now perform Wilcox test.
#
R	-q --no-save < analysis_wilcox.R				> ../analyses/wilcox_results.txt
#-------------------------------------------------------------------------------------
