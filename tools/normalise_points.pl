#!/usr/bin/perl
#
#	Perl script to normalise the growth points from each package so that
#	they can all be combined to extract the overall trend.
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
my	$csvname	= "";
my	@partsrec;
my	$firstline	= 1;
my	$startdays		= 0;
my	$startlines		= 0;
my	$pointdays		= 0;
my	$pointlines		= 0;
my	$dropfirstn		= 5;
my	$countlines		= 0;

getopts('c:d:l', \%opt);

if ( ! defined $opt{c} )			{ die "-c csvname is obligatory\n";}
if ( defined $opt{d} )			{ $dropfirstn	= $opt{d};		}

$csvname	= $opt{c};
#
#	Read the datafile.
#
open( DAT, $csvname)		||	die "Couldn't open input file $csvname\n";
while (my $cline = <DAT>)
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
			$startlines	= $nlines;

			$firstline	= 0;
		}
		else
		{
			@pointday		= split( /-/, $thedate );
			$pointdays	= &Date_to_Days( @pointday );
			$pointlines	= $nlines;
#
#			Normalise the datapoint into years (leap year not handled) and
#			current size / initial size.
#
			my	$normdate		= ($pointdays - $startdays) / 365.0;
			my	$normsize		= $pointlines / $startlines;

			if ( defined $opt{l} )
			{
				printf "%f,%f\n", $normdate, log($normsize);
			}
			else
			{
				printf "%f,%f\n", $normdate, $normsize;
			}
		}
	}
}

exit(0);
