#!/usr/bin/perl
#
#	Perl script to count the total number of lines and
#	print out the totals.
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
my	$package		= "";
my	$csvname		= "";
my	$count		= 0;
my	$totlines		= 0;
my	$totmax		= 0;
my	$nempty		= 0;
my	$refactor		= 0;

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
#	The format is YYYY-MM-DD, nlines, package
#
	($maxlines,$lastlines,$package)	= split( /\,/, $cline );
	$totmax						+= $maxlines;
	$totlines						+= $lastlines;

	if ( $maxlines == 0 )			{ ++$nempty; }
	if ( $maxlines > $lastlines )		{ ++$refactor; }

	++$count;
}

printf "Number of packages          = %d\n", $count;
printf "Total maxlines of code      = %d\n", $totmax;
printf "Total last lines of code    = %d\n", $totlines;
printf "Number empty                = %d\n", $nempty;
printf "Number refactored           = %d\n", $refactor;

exit(0);
