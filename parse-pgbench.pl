#!/usr/bin/perl -w
use strict;
use warnings;

use Date::Parse;
use DateTime;
use Data::Dumper;

my $current_testname = 'pgbench';
my $current_vers;
my $current_gitvers;
my $current_gitdate_ymd;
my $current_gitdate_iso;

my $scaling_factor;
my $query_mode;
my $nclients;
my $nthreads;
my $duration;
my $ntransactions;
my $tps;
my %latency;
my $start_time;
my $kernel_vers;
my $read_iostat_cpu = 0;
my $read_iostat_io = 0;
my %iostat_cpu;
my %iostat_io;
my $end_time;

my @SRCDIRS = ("/home/stark/src/postgres", 
			   "/home/stark/src/pg/postgresql-master");
my $SRCDIR;

for (@SRCDIRS) {
	$SRCDIR=$_ and last if -d $_;
}
die "Couldn't find Postgres source" unless defined $SRCDIR;

print(join(",",
		   'Release Date',
		   'Release Timestamp',
		   'Test Name',
		   'Test Duration',
		   'Test Start Time',
		   'Test End Time',
		   'Kernel Version',
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
#        print STDERR "Parsing output for $current_vers ($current_gitvers from $current_gitdate_iso) (file=$ARGV)\n";
    }

    chomp;

	if (my ($testing_verdate, $testing_vers) = /^Testing ([0-9]{4}-[0-9]{2}-[0-9]{2})-(.*)$/) {
		if ($current_vers ne $testing_vers) {
			die "mismatching version $testing_vers in $ARGV (Expecting $current_vers)";
		}
	}
	elsif (/^Start Time: (.*)$/) {
		$start_time = str2time($1);
	} elsif (/^Linux ([^ ]*)/) {
		$kernel_vers = $1;
	} elsif (/^avg-cpu/) {
		$read_iostat_cpu = 1;
	} elsif ($read_iostat_cpu) {
		$read_iostat_cpu = 0;
		@iostat_cpu{qw(user nice system iowait steal idle)} = split;
	} elsif (/^Device/) {
		$read_iostat_io = 1;
	} elsif ($read_iostat_io && /^(sd|md)/n) {
		my ($drive, @stats) = split;
		my %stats;
		@stats{qw(rrqmps wrqmps rps wps rkbps wkbps avgrqsz avgqusz await r_await w_await svctm utilization)} = @stats;
		@iostat_io{$drive} = \%stats;
	} elsif ($read_iostat_io) {
		$read_iostat_io = 0;
	} elsif (/^End Time: (.*)$/) {
		$end_time = str2time($1);
	} elsif (/scaling factor: (\d*)/) {
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

	if (/^Testing/ || ( /^transaction type/ && defined $scaling_factor) || eof) {
		# about to start a new test or reached the end of an input file
		if (!defined $scaling_factor) {
			# first test of a file
		} elsif (defined $ntransactions && $ntransactions == 0) {
			warn "no transactions for test";
		} elsif (!defined $nclients || !defined $nthreads || !defined $duration || !defined $ntransactions || !defined $tps) {
			local($^W) = 0;
			warn "missing data (scaling_factor=$scaling_factor query_mode=$query_mode nclients=$nclients nthreads=$nthreads duration=$duration ntransactions=$ntransactions tps=$tps)";
		} else {
			if (%iostat_cpu) {
				#print Dumper(\%iostat_cpu);
			}
			if (%iostat_io) {
				#print Dumper(\%iostat_io);
			}

			print(join(",",
					   $current_gitdate_ymd,
					   $current_gitdate_iso,
					   $current_testname,
					   (defined $start_time && defined $end_time) ? $end_time-$start_time : 'unknown',
					   defined $start_time ? DateTime->from_epoch(epoch=>$start_time)->iso8601() : 'unknown',
					   defined $end_time ? DateTime->from_epoch(epoch=>$end_time)->iso8601() : 'unknown',
					   defined $kernel_vers ? $kernel_vers : 'unknown',
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
		%latency = ();
		undef $start_time;
		undef $kernel_vers;
		if ($read_iostat_cpu or $read_iostat_io) {
			warn "finished in midst of iostat output (read_iostat_cpu=$read_iostat_cpu read_iostat_io=$read_iostat_io)";
		}
		$read_iostat_cpu = 0;
		$read_iostat_io = 0;
		%iostat_cpu = ();
		%iostat_io = ();
		undef $end_time;
	}
}
