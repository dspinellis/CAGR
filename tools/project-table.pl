#!/usr/bin/perl
#
# Create a table of projects examined
#

use strict;
use warnings;

my $data_dir = "../data";

my ($total_lines, $total_points, $total_projects);

# Reported projects
my @projects;

# Projects that have their own meta file
# This is used for correctly reporting the rest.meta contents
my %own_meta;

# Debugging variables
my $debug_meta = undef;
my $debug_csv = undef;
my $debug_lastline = undef;

for my $f (<$data_dir/rest/*.meta>, <$data_dir/*.meta>) {
	my $fh;
	my ($description, $url, $vcs, $file, $base, $points);

	print STDERR "Process $f\n" if ($debug_meta);
	$base = $f;
	$base =~ s/\.meta$//;
	$file = "$base.csv";
	open($fh, '<', $f) || die "Unable to open $f: $!\n";
	$own_meta{$f} = 1;
	my $reported;
	while (<$fh>) {
		chop;
		$description = $1 if (/^\%D\s+(.*)/);
		$url = $1 if (/^\%U\s+(.*)/);
		$vcs = $1 if (/^\%V\s+(.*)/);
		# Multiple files in one meta description
		if (/^\%F\s+(.*)/) {
			$file = $1;
			print STDERR "csv(F)=$data_dir/$file\n" if ($debug_csv);
			report($description, $url, $vcs, 1, lastline("$data_dir/$file"));
			$own_meta{"$data_dir/$file"} = 1;
			$reported = 1;
		}
	}
	my $nproj = 0;
	my $nlines = 0;
	my $npoints = 0;
	if (defined($description) && !$reported) {
		if (-d $base) {
			my $total;
			for my $csv (<$base/*.csv>) {
				next if ($own_meta{$csv});
				print STDERR "csv(*)=$csv\n" if ($debug_csv);
				my ($p, $l) = lastline($csv);
				if ($l) {
					$nproj++;
					$nlines += $l;
					$npoints += $p;
				}
			}
		} else {
			print STDERR "csv(1)=$base.csv\n" if ($debug_csv);
			($npoints, $nlines) = lastline("$base.csv");
			$nproj = 1 if ($nlines);
			$own_meta{"$base.csv"} = 1;
		}
		report($description, $url, $vcs, $nproj, $npoints, $nlines);
	}
}

# Report projects ordered alphabetically
for my $line (sort {lc($a) cmp lc($b)} @projects) {
	print $line;
}

# Print totals
print "\\hline\n";
$total_projects = human_integer($total_projects);
$total_points = human_integer($total_points);
$total_lines = human_integer(int($total_lines / 1000));
print " Total & & & $total_projects & $total_points & $total_lines \\\\\n";

# Convert an integer number to a human-readable form
# by adding thousand separators
sub
human_integer
{
        my ($n) = @_;
        $n =~ s/\B(?=(\d{3})+(?!\d))/,/g;
        return $n;
}

# Return the number of records and number of code lines listed in the last line of the
# passed CSV file
sub
lastline
{
	my ($f) = @_;
	my $fh;
	open($fh, '<', $f) || die "Unable to open $f: $!\n";
	my ($date, $loc, $recs);
	$loc = 0;
	$recs = 0;
	while (<$fh>) {
		chop;
		next unless (/,/);
		($date, $loc) = split(/,/, $_);
		$recs++;
	}
	print STDERR "lastline $f = $loc\n" if ($debug_lastline);
	return ($recs, $loc);
}

# Report the passed project keeping totals
sub
report
{
	my ($description, $url, $vcs, $nproj, $npoints, $nlines) = @_;

	# Keep totals
	$total_lines += $nlines;
	$total_projects += $nproj;
	$total_points += $npoints;

	# Format numbers
	$nlines = human_integer(sprintf('%.0f', $nlines / 1000));
	$nproj = human_integer($nproj);
	$npoints = human_integer($npoints);

	# Format VCS string
	if ($vcs eq 'git') {
		$vcs = 'Git';
	} elsif ($vcs eq 'hg') {
		$vcs = 'Hg';
	} elsif ($vcs =~ m|^[A-Z/]+$|) {
		$vcs = '{\sc ' . lc($vcs) . '}';
	}

	# Remote http from URL
	$url =~ s|https?://||;

	push (@projects, "$description & {\\footnotesize \\url{$url}} & $vcs & $nproj & $npoints & $nlines \\\\\n");
}
