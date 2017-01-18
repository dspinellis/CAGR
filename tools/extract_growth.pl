#!/usr/bin/perl
#
#	This script takes growth files in standard format, (YYYY-MM-DD,sloc) records
#	and computes the 0-100% growth and also the 25-75% growth.
#
#	Growth is calculated from the standard compound growth formula:-
#
#		S = So(1+p)^r				(1)
#	where
#		So is initial source size in SLOC.
#		S is the final source size in SLOC after an annual growth rate
#			of p over r years.
#
#	This is approximated as a linear trend by taking the log of (1) to get
#
#		log S = r. log(1+p) + log So
#	where
#		r is the number of years (fractional)
#		log So is the intercept.
#
#	Revision:	$Revision: 1.4 $
#	Date:	$Date: 2009/03/17 14:47:18 $
#--------------------------------------------------------------
#
use strict;
use Date::Calc qw(Delta_Days Date_to_Days);
use Getopt::Std;

my	(%opt);
my	(@startday,@pointday);

my	$csvname			= "";
my	@partsrec;
my	$firstline		= 1;
my	$startdays		= 0;
my	$startlines		= 0;
my	$pointdays		= 0;
my	$pointlines		= 0;
my	$dropfirstn		= 2;
my	$countlines		= 0;
my	$totallines		= 0;
my	$maxlines			= 0;
my	$lastlines		= 0;
my	$process			= 1;

getopts('c:d:l', \%opt);

if ( ! defined $opt{c} )			{ die "-c csvname is obligatory\n";}
if ( defined $opt{d} )			{ $dropfirstn	= $opt{d};		}

$csvname	= $opt{c};

#
#	To turn off any specific directories, adjust the following.
#
#	if 		( $csvname =~ /kde\//i )		{ $process	= 0;}

if ( ! $process )					{ exit(0); }
#								============
#	Here if we are processing this .csv file.
#
#	Read the datafile.  We have to read it twice to compute the 25-75th percentile so we
#	localise it.
#
open( DAT, $csvname)		||	die "Couldn't open input file $csvname\n";
my	@all_lines = <DAT>;
close( DAT );
#	----------------------------------------
#	Now read through it to find the size0, size100 and their corresponding times.
#
my	$time0		= 0.0;
my	$time100		= 0.0;
my	$size0		= 0.0;
my	$size100		= 0.0;
my	$max1q		= 0.0;
my	$max4q		= 0.0;

my	$refactor		= 1.0;
#
#	For the least squares linear fit.
#
my	$meanx		= 0.0;
my	$meany		= 0.0;
my	$countxy		= 0;

foreach	my	$cline	(@all_lines)
{
#
#	The format is YYYY-MM-DD, nlines
#
	my	($thedate,$nlines)	= split( /\,/, $cline );
#
#	Discard any records which have zero lines or occur in the first $dropfirstn lines.
#
	if ( ($nlines > 0) && (++$countlines > $dropfirstn) )
	{
		my	@parse_date	= split( /-/, $thedate );
		my	$theday		= &Date_to_Days( @parse_date );
		my	$thedayyr		= $theday / 365.0;			# Ignore leap years :-).
		$meanx			+= $thedayyr;
		$meany			+= log($nlines);
		++$countxy;

		if ( $firstline )
		{
			$time0		= $thedayyr;
			$size0		= $nlines;

			$firstline	= 0;
		}
		else
		{
#
#			Store the maximum found, (this may well not be at the end due to refactoring).
#
			if ( $nlines > $maxlines )
			{
				$time100		= $thedayyr;
				$size100		= $nlines;

				$maxlines		= $nlines;
			}
		}

		$lastlines	= $nlines;
	}
}

$totallines	= $countlines;

if ( $lastlines > 0 )
{
#
#	Prepare to calculate the best fit line.
#	m = sum (xi-xbar)(yi-ybar) / sum (xi-xbar)^2
#
	$meanx		/= $countxy;
	$meany		/= $countxy;

	my	$num		= 0.0;
	my	$den		= 0.0;

	$refactor		= $maxlines / $lastlines;
#	----------------------------------------
#	Now re-read through it to find the size25, size75 and their corresponding times.
#	This is read under identical conditions.
#
	my	$time25		= 0.0;
	my	$time75		= 0.0;
	my	$size25		= 0.0;
	my	$size75		= 0.0;
	my	$nlines25		= 0.25 * ($maxlines - $size0) + $size0;
	my	$nlines75		= 0.75 * ($maxlines - $size0) + $size0;

	$countlines		= 0;

	foreach	my	$cline	(@all_lines)
	{
		my	($thedate,$nlines)	= split( /\,/, $cline );
#
#		Discard any records which have zero lines or occur in the first $dropfirstn lines.
#
		if ( ($nlines > 0) && (++$countlines > $dropfirstn) )
		{
			my	@parse_date	= split( /-/, $thedate );
			my	$theday		= &Date_to_Days( @parse_date );
			my	$thedayyr		= $theday / 365.0;			# Ignore leap years :-).
			my	$loglines		= log($nlines);

			if ( $nlines25 > $nlines )
			{
				$time25		= $thedayyr;
				$size25		= $nlines;

				if ( ($countlines < (0.25 * $totallines)) && ($nlines > $max1q) )		{ $max1q = $nlines; }
			}

			if ( $nlines75 <  $nlines )
			{
#
#				Store the maximum found, (this may well not be at the end due to refactoring).
#
				$time75		= $thedayyr;
				$size75		= $nlines;

				if ( ($countlines > (0.75 * $totallines)) && ($nlines > $max4q) )		{ $max4q = $nlines; }
			}

			$num		+= ($thedayyr - $meanx)*($loglines - $meany);
			$den		+= ($thedayyr - $meanx)**2;
		}
	}
#
#	Now compute the best fit line on the log(size) v. time.
#
	my	$bestfit	= 0.0;
	if ( $den > 0.0 )				{ $bestfit	= $num / $den; }
#
#	We can now calculate the 0-100 and 25-75 percentile growth rates.
#
	my	$p0_100	= 0.0;
	my	$p25_75	= 0.0;

	if ( ($time75 <= $time25) || ($size25 == 0.0) )
	{
		printf "0,%s,%f,%f,%f,%f,%f,0\n", 
			$csvname, $time0, $time25, $time75, $time100, $maxlines;
	}
	else
	{
		$p0_100	= (($size100/$size0) ** (1.0/($time100 - $time0))) - 1.0;
		$p25_75	= (($size75/$size25) ** (1.0/($time75 - $time25))) - 1.0;
#
#		We output a duration,maxlines,p0-100,p25_75,(maxsize/finalsize),bestfit record.
#
		if ( $max1q > $max4q )
		{
			printf "2,%s,%f,%f,%f,%f,%f,%f\n", 
				$csvname, $time100-$time0, $maxlines, $p0_100, $p25_75, $refactor, $bestfit;
		}
		else
		{
			printf "1,%s,%f,%f,%f,%f,%f,%f\n", 
				$csvname, $time100-$time0, $maxlines, $p0_100, $p25_75, $refactor, $bestfit;
		}
	}
}
else
{
#
#	Empty file.
#
	printf "0,%s,0.0,0,0.0.0,0.0,%f,0\n", 
		$csvname, $maxlines;
}

exit(0);
