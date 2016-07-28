#!/usr/bin/perl -w
use strict;
use warnings;

use Date::Parse;
use DateTime;

my $current_testname = 'pgbench';
my $current_time = 'unknown';
my $current_vers;
my $current_gitvers;
my $current_gitdate_ymd;
my $current_gitdate_iso;

my ($scaling_factor, $query_mode, $nclients, $nthreads, $duration, $ntransactions, $tps, %latency);

my $SRCDIR = "/home/stark/src/postgres";

print(join(",",
		   'Release Date',
		   'Release Timestamp',
		   'Test Name',
		   'Test Timestamp',
		   'Release Tag',
		   'Scaling Factor',
		   'Query Mode',
		   'Number of Clients',
		   'Number of Threads',
		   'Test Duration',
		   'Number of Transactions',
		   'TPS'),
	  "\n");

while (<>) {

    my ($verdate, $vers) = ($ARGV =~ /o-([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*)\.out$/);
    if (!defined $vers) {
        die "what version is $ARGV ?";
    }
    if (!defined $current_vers || $vers ne $current_vers) {
        $current_vers = $vers;

        my $gitdesc = qx{
        cd ${SRCDIR}; 
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
			# Use fork point of branch not final release date to avoid anomalies on graph
			$vers_for_date = `cd $SRCDIR; git merge-base $current_vers HEAD`;
        } else {
            $vers_for_date = $current_vers;
        }

        my $gitinfo = `cd $SRCDIR ; git log -n 1 --date=iso $vers_for_date`;
        my ($date) = $gitinfo =~ /^Date: *(.*)$/m;
        if (!defined $date) {
            die "Couldn't find date for version $current_vers";
        }
        my $new_gitdate = str2time($date);
        $current_gitdate_ymd = DateTime->from_epoch(epoch=>$new_gitdate)->ymd();
        $current_gitdate_iso = DateTime->from_epoch(epoch=>$new_gitdate)->iso8601();
        print STDERR "Parsing output for $current_vers ($current_gitvers from $current_gitdate_iso)\n";
    }

    chomp;

	if (/scaling factor: (\d*)/) {
		$scaling_factor = $1;
	} elsif (/query mode: ([a-z]*)/) {
		$query_mode = $1;
	} elsif (/number of clients: (\d*)/) {
		$nclients = $1;
	} elsif (/number of threads: (\d*)/) {
		$nthreads = $1;
	} elsif (/duration: (\d*) s/) {
		$duration = $1;
	} elsif (/number of transactions actually processed: (\d*)/) {
		$ntransactions = $1;
	} elsif (/tps = ([0-9.]*) \(excluding connections establishing\)/) {
		$tps = $1;
	} elsif (/^ *([0-9.]*) +(.*)$/) {
		$latency{$2} = $1;
	}

} continue {

	if (/^transaction type/ || eof) {
		# about to start a new test or reached the end of an input file
		if (!defined $scaling_factor) {
			# first test of a file
		} elsif (!defined $nclients || !defined $nthreads || !defined $duration || !defined $ntransactions || !defined $tps) {
			warn "missing data (scaling_factor=$scaling_factor query_mode=$query_mode nclients=$nclients nthreads=$nthreads duration=$duration ntransactions=$ntransactions tps=$tps)";
		} else {
			print(join(",",
					   $current_gitdate_ymd,
					   $current_gitdate_iso,
					   $current_testname,
					   $current_time,
					   $current_vers,
					   $scaling_factor,
					   $query_mode,
					   $nclients,
					   $nthreads,
					   $duration,
					   $ntransactions,
					   $tps),
				  "\n");
		}

		undef $scaling_factor;
		undef $query_mode;
		undef $nclients;
		undef $nthreads;
		undef $duration;
		undef $ntransactions;
		undef $tps;
	}
}
