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
my	$dropfirstn		= 5;
my	$countlines		= 0;
my	$maxlines			= 0;
my	$lastlines		= 0;

getopts('c:d:l', \%opt);

if ( ! defined $opt{c} )			{ die "-c csvname is obligatory\n";}
if ( defined $opt{d} )			{ $dropfirstn	= $opt{d};		}

$csvname	= $opt{c};
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

my	$refactor		= 1.0;

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
		if ( $firstline )
		{
			@startday		= split( /-/, $thedate );
			$startdays	= &Date_to_Days( @startday );
			$time0		= $startdays / 365.0;			# Ignore leap years :-).
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
				@pointday		= split( /-/, $thedate );
				$pointdays	= &Date_to_Days( @pointday );
				$time100		= $pointdays / 365.0;		# Ignore leap years :-).
				$size100		= $nlines;

				$maxlines		= $nlines;
			}
		}

		$lastlines	= $nlines;
	}
}

$refactor		= $maxlines / $lastlines;
#	----------------------------------------
#	Now re-read through it to find the size25, size75 and their corresponding times.
#	This is read under identical conditions.
#
my	$time25		= 0.0;
my	$time75		= 0.0;
my	$size25		= 0.0;
my	$size75		= 0.0;
my	$nlines25		= 0.25 * $maxlines;
my	$nlines75		= 0.75 * $maxlines;

$countlines		= 0;

foreach	my	$cline	(@all_lines)
{
	my	($thedate,$nlines)	= split( /\,/, $cline );
#
#	Discard any records which have zero lines or occur in the first $dropfirstn lines.
#
	if ( ($nlines > 0) && (++$countlines > $dropfirstn) )
	{
		if ( $nlines25 > $nlines )
		{
			@startday		= split( /-/, $thedate );
			$startdays	= &Date_to_Days( @startday );
			$time25		= $startdays / 365.0;			# Ignore leap years :-).
			$size25		= $nlines;
		}
		elsif ( $nlines75 >  $nlines )
		{
#
#			Store the maximum found, (this may well not be at the end due to refactoring).
#
			@pointday		= split( /-/, $thedate );
			$pointdays	= &Date_to_Days( @pointday );
			$time75		= $pointdays / 365.0;		# Ignore leap years :-).
			$size75		= $nlines;
		}
	}
}
#
#	We can now calculate the 0-100 and 25-75 percentile growth rates.
#
my	$p0_100	= 0.0;
my	$p25_75	= 0.0;

$p0_100	= (($size100/$size0) ** (1.0/($time100 - $time0))) - 1.0;
$p25_75	= (($size75/$size25) ** (1.0/($time75 - $time25))) - 1.0;

#	printf "size0 = %f, size100 = %f, size25 = %f, size75 = %f\n", $size0, $size100, $size25, $size75;
#	printf "time0 = %f, time100 = %f, time25 = %f, time75 = %f\n", $time0, $time100, $time25, $time75;
#
#	We output a duration,maxlines,p0-100,p25_75,(maxsize/finalsize).
#
printf "%f,%f,%f,%f,%f\n", $time100-$time0, $maxlines, $p0_100, $p25_75, $refactor;

exit(0);
