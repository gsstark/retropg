#!/usr/bin/perl -w
use strict;
use warnings;

use Date::Parse;
use DateTime;

my $read_work_mem = 0;
my $read_test = 0;
my $read_date = 0;
my $current_work_mem;
my $current_nrows;
my $current_time;
my $current_date;
my $current_vers;
my $current_gitvers;
my $current_gitdate;
my $current_testdate;

print(join("\t",
	   'Release Date',
	   'Number of Rows',
	   'Time (ms)',
	   'work_mem (bytes)',
	   'Release Tag',
	   'Test Timestamp',
	   'Release Tag Containing'),
      "\n");

while (<>) {

    my ($vers) = ($ARGV =~ /o-pgsql-(.*)\.out$/);
    if (!defined $current_vers || $vers ne $current_vers) {
	if ($read_test || $read_work_mem || $read_date || defined $current_nrows) {
	    die "finished file $current_vers in invalid state ($read_test, $read_work_mem, $read_date)";
	}
	$current_vers = $vers;

	my $gitdesc = `cd /home/stark/src/postgresql ; git describe --tags --contains --match 'REL*_*_[0-9]*' $vers`;
	chomp $gitdesc;
	#print STDERR "Fixing up $vers to be $gitdesc\n";
	$current_gitvers = $gitdesc;

	# If we are on a point release we need to find the date of the first point release
	my $vers_for_date;
	if ($current_vers =~ /^REL[0-9_]*$/) {
	    my ($major) = $current_vers =~ /^(REL[0-9]*_[0-9]*)_.*$/;
	    $vers_for_date = `cd /home/stark/src/postgresql ; git describe --tags --abbrev=0 --match '${major}_0' $current_vers 2>/dev/null`;
	    $vers_for_date = `cd /home/stark/src/postgresql ; git describe --tags --abbrev=0 --match '${major}' $current_vers 2>/dev/null`
		unless $vers_for_date;
	} else {
	    $vers_for_date = $current_vers;
	}

	my $gitinfo = `cd /home/stark/src/postgresql ; git log -n 1 $vers_for_date`;
	my ($date) = $gitinfo =~ /^Date: *(.*)$/m;
	if (!defined $date) {
	    die "Couldn't find date for version $current_vers";
	}
	my $new_gitdate = str2time($date);
	$current_gitdate = DateTime->from_epoch(epoch=>$new_gitdate)->ymd();
	print STDERR "Parsing output for $current_vers ($current_gitvers from $current_gitdate)\n";
    }

    chomp;

    if (/(work|sort)_mem/) {
	$read_work_mem = 1;

    } elsif (/^ *count *$/) {
	$read_test = 1;

    } elsif (/^ *now *$/) {
	$read_date = 1;

    } elsif ($read_date && /^ *(20\d\d-\d\d-\d\d[-0-9:.+ ]+) *$/) {
	$read_date = 0;
	my $newdate = int str2time($1);
	$current_testdate = DateTime->from_epoch(epoch=>$newdate)->iso8601();

    } elsif ($read_work_mem && /^ *([0-9]+)(MB|kB|GB)? *$/) {
	$read_work_mem = 0;
	my $unit;
	if (!defined $2 || $2 eq 'kB') {
	    $unit = 1024;
	} elsif ($2 eq 'MB') {
	    $unit = 1024 * 1024;
	} elsif ($2 eq 'GB') {
	    $unit = 1024 * 1024 * 1024;
	} else {
	    die "unrecognized units: $2";
	}

	$current_work_mem = (0+$1) * $unit;

    } elsif ($read_test && /^ *([0-9]+) *$/) {
	$current_nrows = 0+$1;

    } elsif ($read_test && /^Time: ([0-9.]+) ms$/) {
	$current_time = 0+$1;
	
	if (!$current_nrows || !$current_time || !$current_work_mem || !$current_vers || !$current_gitdate || !$current_testdate) {
	    die "Missing data (rows=$current_nrows time=$current_time work_mem=$current_work_mem vers=$current_vers gitdate=$current_gitdate testdate=$current_testdate )";
	}
	print "$current_gitdate\t$current_nrows\t$current_time\t$current_work_mem\t$current_vers\t$current_testdate\t$current_gitvers\n";

	$read_test = 0;
	undef $current_nrows;
	undef $current_time;
    }

}
