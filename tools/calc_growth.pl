#!/usr/bin/perl
#
#	Perl script to analyse growth data, apply robust measures 
#	and calculate the growth rate.
#
#	Revision:	$Revision: 1.4 $
#	Date:	$Date: 2009/03/17 14:47:18 $
#--------------------------------------------------------------
#
use strict;
use Getopt::Std;

my	(%opt);

my	$csvname		= "";
my	$minsize		= 50000.0;			# SLOC
my	$maxsize		= 10000000.0;			# SLOC
my	$mintime		= 5.0;				# Years
my	$refactorrat	= 0.1;
my	$trim 		= 30;
my	$countrefact	= 0;
my	$totalsloc	= 0;
my	$winnsloc		= 0;
my	$totalproj	= 0;
my	$winnproj		= 0;

getopts('c:m:pr:s:t:knquvwyx:z', \%opt);

if ( ! defined $opt{c} )			{ die "-c csvname is obligatory\n";}

if ( defined $opt{m} )			{ $trim		= $opt{m};}
if ( defined $opt{r} )			{ $refactorrat	= $opt{r};}
if ( defined $opt{s} )			{ $minsize	= $opt{s};}
if ( defined $opt{t} )			{ $mintime	= $opt{t};}
if ( defined $opt{x} )			{ $maxsize	= $opt{x};}

$csvname	= $opt{c};
#
#	Read the datafile.
#
my	$avg0_100		= 0.0;
my	$std0_100		= 0.0;
my	$avg25_75		= 0.0;
my	$std25_75		= 0.0;
my	$avgbf		= 0.0;
my	$stdbf		= 0.0;

my	(@p0_100_all,@p25_75_all,@bf_all,@s_all,@t_all);

my	$ncorrupt			= 0;
my	$n2small			= 0;
my	$n2big			= 0;
my	$n2short			= 0;
my	$n2variable		= 0;

open( DAT, $csvname)		||	die "Couldn't open input file $csvname\n";
while (my $cline = <DAT>)
{
#
#	The format is YYYY-MM-DD, nlines
#
	chomp($cline);
	my	($stat,$fname,$t,$s,$p0_100,$p25_75,$r,$bf)	= split( /\,/, $cline );

	$totalsloc	+= $s;
	++$totalproj;

	if ( $stat == 0 )										{ ++$ncorrupt; ++$winnproj; $winnsloc += $s; next ; }
	if ( $s < $minsize )									{ ++$n2small; ++$winnproj; $winnsloc += $s; next ; }
	if ( $s > $maxsize )									{ ++$n2big; ++$winnproj; $winnsloc += $s; next ; }
	if ( $t < $mintime )									{ ++$n2short; ++$winnproj; $winnsloc += $s; next ; }
	if ( ($r > 1.0 + $refactorrat) || ($r < 1.0 - $refactorrat) )	{ ++$n2variable; ++$winnproj; $winnsloc += $s; next ; }

	printf "%f,%f,%f,%s\n", $p0_100, $p25_75, $bf, $fname if $opt{p};

	push( @p0_100_all, $p0_100 );
	push( @p25_75_all, $p25_75 );
	push( @bf_all, $bf );
	push( @t_all, $t );
	push( @s_all, $s );

	if ( $r > 1.0 )										{ ++$countrefact; }
}
close( DAT );
#
#	Sort the arrays as we are going to trim them to remove outliers.
#
my	@p0_100_sort	= sort {$a <=> $b} @p0_100_all;
my	@p25_75_sort	= sort {$a <=> $b} @p25_75_all;
my	@bf_sort		= sort {$a <=> $b} @bf_all;
my	@s_sort		= sort {$a <=> $b} @s_all;

my	$analsloc	= 0;
my	$analproj	= 0;

my	$trimsloc	= 0;
my	$trimproj	= 0;

foreach	my	$i	( keys @s_sort)
{
	if ( $i > $trim && $i < scalar @s_sort - $trim )
	{
		$analsloc	+= $s_sort[$i];
		++$analproj;
	}
	else
	{
		$trimsloc	+= $s_sort[$i];
		++$trimproj;
	}
}

foreach	my	$i	( keys @p0_100_sort)
{
	if ( $i > $trim && $i < scalar @p0_100_sort - $trim )
	{
		$avg0_100		+= $p0_100_sort[$i];
		$std0_100		+= ($p0_100_sort[$i] * $p0_100_sort[$i]);

		if ( $opt{w} )
		{
			print "$p0_100_sort[$i]\n";
		}
	}
}

foreach	my	$i	( keys @p25_75_sort)
{
	if ( $i > $trim && $i < scalar @p25_75_sort - $trim )
	{
		$avg25_75		+= $p25_75_sort[$i];
		$std25_75		+= ($p25_75_sort[$i] * $p25_75_sort[$i]);

		if ( $opt{v} )
		{
			print "$p25_75_sort[$i]\n";
		}
	}
}

foreach	my	$i	( keys @bf_all)
{
	if ( $opt{q} )
	{
#
#		Trim the really big ones.
#
		if ( $p0_100_all[$i] < 4.0 )
		{
			print "$bf_all[$i] $p0_100_all[$i]\n";
		}
	}
}

foreach	my	$i	( keys @t_all)
{
	if ( $opt{n} )
	{
#
#		Check for cross-correlation.
#
		if ( $p0_100_all[$i] < 4.0 )
		{
#
#			Trim the really big ones.
#
			print "$t_all[$i] $p0_100_all[$i]\n";
		}
	}
}

foreach	my	$i	( keys @s_all)
{
	if ( $opt{k} )
	{
#
#		Check for cross-correlation.
#
		if ( $p0_100_all[$i] < 4.0 && $s_all[$i] < 1000000 )
		{
#
#			Trim the really big ones.
#
			print "$s_all[$i] $p0_100_all[$i]\n";
		}
	}
}

foreach	my	$i	( keys @bf_sort)
{

	if ( $i > $trim && $i < scalar @bf_sort - $trim )
	{
		$avgbf		+= $bf_sort[$i];
		$stdbf		+= ($bf_sort[$i] * $bf_sort[$i]);

		if ( $opt{u} )
		{
			print "$bf_sort[$i]\n";
		}
	}
}
#
#	Optionally print out summary.
#
$avg0_100	= $avg0_100 / $analproj;
$avg25_75	= $avg25_75 / $analproj;
$avgbf	= $avgbf / $analproj;

$std0_100	= $std0_100 / ($analproj - 1.0)	- ($avg0_100 ** 2);
$std25_75	= $std25_75 / ($analproj - 1.0)	- ($avg25_75 ** 2);
$stdbf	= $stdbf / ($analproj - 1.0)	- ($avgbf ** 2);

if ( $opt{y} && ! $opt{u} && ! $opt{v} && ! $opt{w} )
{
#
#	Text summary.
#
	printf "SUMMARY ------------------------------\n";
	printf "  Parameters -------------------------\n";
	printf "  Minimum size           = %d\n", $minsize;
	printf "  Maximum size           = %d\n", $maxsize;
	printf "  Minimum duration       = %d\n", $mintime;
	printf "  Refactored             = %d\n", $countrefact;
	printf "  Initial    -------------------------\n";
	printf "  Total SLOC (end-start) = %d\n", $totalsloc;
	printf "  Total projects         = %d\n", $totalproj;
	printf "  Winnowed   -------------------------\n";
	printf "  Total SLOC             = %d\n", $winnsloc;
	printf "  Total projects         = %d\n", $winnproj;
	printf "  .. Corrupted, or empty = %d\n", $ncorrupt;
	printf "  .. Too small           = %d\n", $n2small;
	printf "  .. Too big             = %d\n", $n2big;
	printf "  .. Too short           = %d\n", $n2short;
	printf "  .. Too variable        = %d\n", $n2variable;
	printf "  Trimmed   -------------------------\n";
	printf "  Total SLOC             = %d\n", $trimsloc;
	printf "  Total projects         = %d\n", $trimproj;
	printf "  Number trimmed         = %d\n", $trim;
	printf "  Analysed  -------------------------\n";
	printf "  Total SLOC             = %d\n", $analsloc;
	printf "  Total projects         = %d\n", $analproj;
	printf "  Average growth 0-100   = %f\n", $avg0_100;
	printf "  Std. Dev.      0-100   = %f\n", $std0_100;
	printf "  Average growth 25_75   = %f\n", $avg25_75;
	printf "  Std. Dev.      25_75   = %f\n", $std25_75;
	printf "  Average slope          = %f\n", $avgbf;
	printf "  Std. Dev. slope        = %f\n", $stdbf;
}
elsif ( $opt{z} && ! $opt{u} && ! $opt{v} && ! $opt{w} )
{
#
#	Latex format summary.
#
	printf "All projects & %d & %d \\\\\n", $totalsloc, $totalproj;
	printf "Winnowed projects; empty (%d); small (%d), large (%d), short (%d) or variable (%d) & %d & %d \\\\\n", 
		$ncorrupt, $n2small, $n2big, $n2short, $n2variable, $winnsloc, $winnproj;
	printf "Analysed projects & %d & %d \\\\\n", $analsloc, $analproj;
}

exit(0);
