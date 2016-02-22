#!/usr/bin/perl -w
use strict;
use warnings;

use Date::Parse;
use DateTime;

my $read_work_mem = 0;
my $read_test = 0;
my $read_date = 0;
my $current_work_mem;
my $current_testname;
my $current_result;
my $current_time;
my $current_date;
my $current_vers;
my $current_gitvers;
my $current_gitdate;
my $current_testdate;

print(join("\t",
	   'Release Date',
	   'Test Name',
	   'Time (ms)',
	   'work_mem (bytes)',
	   'Release Tag',
	   'Test Timestamp',
	   'Test Result',
	   'Release Tag Containing'),
      "\n");

while (<>) {

    my ($verdate, $vers) = ($ARGV =~ /o-([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*)\.out$/);
    if (!defined $vers) {
	die "what version is $ARGV ?";
    }
    if (!defined $current_vers || $vers ne $current_vers) {
	if ($read_test || defined $current_testname || $read_work_mem || $read_date || defined $current_result) {
	    warn "finished file $current_vers in invalid state ($read_test, $current_testname, $read_work_mem, $read_date)";
	}
	$current_vers = $vers;

	my $gitdesc = qx{
	    cd /home/stark/src/postgresql ; 
	    git describe --tags  --candidates=0 "$vers" 2>/dev/null || 
	    git describe --tags  --contains --match REL[0-9]_[0-9] "$vers" 2>/dev/null || 
	    git describe --tags  --contains --match REL[0-9]_[0-9]_0 "$vers" 2>/dev/null || 
	    git describe --tags "$vers" 2>/dev/null
        };
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

    if (/garbage/) {
	$read_work_mem = 0;
	$read_test = 0;
	undef $current_result;
	undef $current_testname;
	undef $current_time;
    }

    if (/(work|sort)_mem/) {
	$read_work_mem = 1;

    } elsif (/^ *(sort[a-z0-9_]*|seqscan) *$/) {
	$current_testname = $1;
	$read_test = 1;

    } elsif (/^ *now *$/) {
	$read_date = 1;

    } elsif ($read_date && /^ *(20\d\d-\d\d-\d\d[-0-9:.+ ]+) *$/) {
	$read_date = 0;
	my $newdate = int str2time($1);
	$current_testdate = DateTime->from_epoch(epoch=>$newdate)->iso8601();

    } elsif (/sort_mem is ([0-9]*)$/) {
	$current_work_mem = (0+$1) * 1024;
    
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
	$current_result = 0+$1;

    } elsif ($read_test && /^Time: ([0-9.,]+) ms$/) {
	$current_time = $1;
	$current_time =~ tr/,/./;
	$current_time += 0;
	
	if (!$current_result || !$current_time || !$current_work_mem || !$current_vers || !$current_gitdate || !$current_testdate) {
	    warn "Missing data (rows=$current_result time=$current_time work_mem=$current_work_mem vers=$current_vers gitdate=$current_gitdate testdate=$current_testdate )";
	    next;
	}
	print "$current_gitdate\t$current_testname\t$current_time\t$current_work_mem\t$current_vers\t$current_testdate\t$current_result\t$current_gitvers\n";

	$read_test = 0;
	undef $current_result;
	undef $current_testname;
	undef $current_time;
    }

}
