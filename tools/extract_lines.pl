#!/usr/bin/perl
#
#	Perl script to count the total number of lines and
#	print out the largest number and the latest number.
#
#	Revision:	$Revision: 1.4 $
#	Date:	$Date: 2009/03/17 14:47:18 $
#--------------------------------------------------------------
#
use strict;
use Getopt::Std;

my	(%opt);

my	$maxlines		= 0;
my	$lastlines	= 0;
my	$csvname		= "";
my	$thedate		= "";
my	$nlines		= 0;
my	$process		= 1;

getopts('c:', \%opt);

if ( ! defined $opt{c} )			{ die "-c csvname is obligatory\n";}

$csvname	= $opt{c};

#
#	Read the datafile.
#
open( DAT, $csvname)		||	die "Couldn't open input file $csvname\n";
while (my $cline = <DAT>)
{
#
#		The format is YYYY-MM-DD, nlines
#
	($thedate,$nlines)	= split( /\,/, $cline );

	if ( $nlines > $maxlines )		{ $maxlines	= $nlines; }
}

$lastlines		= $nlines;

printf "%d,%d,%s\n", $maxlines, $lastlines, $csvname;

exit(0);
