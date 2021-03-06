#!/bin/sh

set -e

here="$(dirname "${BASH_SOURCE[0]}")"
start="$(date +%s)"

pgoptions="" # "-c shared_buffers=16384"

locale=uk_UA.UTF-8
encoding=unicode
wordlist=/usr/share/dict/ukrainian

export LC_ALL=$locale
export LC_COLLATE=$LC_ALL
export LC_CTYPE=$LC_ALL
export LC_NUMERIC=C # c.f. REL7_3~975
export LC_TIME=C
export LC_MESSAGES=C

RELS="pgsql-HEAD-2016-03-11 pgsql-pg0001-2016-03-11 pgsql-pg0002-2016-03-11 pgsql-pg0003-2016-03-11"

NRELS="$(for v in $RELS; do echo "$v" ; done | wc -l)"
N=0

for ver in $RELS ; do
    d="/usr/local/$ver"
    rel="$(basename $d)"

	now="$(date +%s)"
	if [[ $N > 0 ]]; then
		elapsed=$(( ( $now - $start ) / $N ))
		remaining=$(( ( $NRELS - $N ) * $elapsed ))
		eta=$(( $now + $remaining ))
		remaining_str="$( LC_ALL=C date +%Hh%MM -d @$remaining )"
		eta_str="$( LC_ALL=C date -d @$eta )"
	fi


    N=$(( N + 1 ))

    if [[ ! -f $d/bin/initdb ]] ; then
		echo
		echo "========================================================================"
		echo "Skipping $rel ($N/$NRELS)"
		echo "========================================================================"
		continue
    fi

    TESTDIR="/var/tmp/benchpgsql"
    if [[ ! -d $TESTDIR ]] ; then
		mkdir $TESTDIR
    fi

    bin="$d/bin"
    lib="$d/lib"
    binfallback="$(echo "$d/../*-REL7_3_21/bin")"
    db="$TESTDIR/d-$rel"
    log="$TESTDIR/l-$rel.log"
    out="$TESTDIR/o-$rel.out"

    echo
    echo "========================================================================"
    echo "Testing $rel ($N/$NRELS)"
	echo "Logs in:  	$log"
	echo "Output in: 	$out"
	echo "Remaining: 	$remaining_str"
  	echo "ETA:   	  	$eta_str"
    echo "========================================================================"


    if [ ! -d $db ] ; then
		echo "Running initdb for $rel in $db"
		initdbargs=""
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb --help | grep -e --encoding >/dev/null ; then
			initdbargs="$initdbargs --encoding $encoding"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb --help | grep -e --locale >/dev/null ; then
			initdbargs="$initdbargs --locale $LC_ALL"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb --help | grep -e --lc-numeric >/dev/null ; then
			initdbargs="$initdbargs --lc-numeric C"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb --help | grep -e --lc-time >/dev/null ; then
			initdbargs="$initdbargs --lc-time C"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb --help | grep -e --lc-messages >/dev/null ; then
			initdbargs="$initdbargs --lc-messages C"
		fi
		PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/initdb -D $db $initdbargs || continue
    fi

    if [[ -e /tmp/.s.PGSQL.5432 ]] ; then
		echo /tmp/.s.PGSQL.5432 already exists
    fi

    trap "$bin/pg_ctl -D $db stop" EXIT
    $bin/pg_ctl -D $db -l $log -o "$pgoptions" start || PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/postmaster -D $db $pgoptions > $log 2>&1 &
    echo -n "Waiting for $rel to start up..."
    for i in `seq 1 30` ; do
		sleep 1
    	PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/psql -o /dev/null -X template1 -c 'select 1' 2>/dev/null && break
		echo -n .
    done
    if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/psql -o /dev/null -X template1 -c 'select 1' ; then
		echo done
    else
		$bin/pg_ctl -D $db stop -m fast || echo pg_ctl exited with status $?
		trap - EXIT
		continue
    fi

    if ! PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/psql -o /dev/null -X -c 'select 1'; then
		createdbargs=""
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/createdb --help | grep -e '--encoding' >/dev/null; then
			createdbargs="$createdbargs --encoding unicode"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/createdb --help | grep -e '--locale' >/dev/null; then
			createdbargs="$createdbargs --locale $locale"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/createdb --help | grep -e '--lc_collate' >/dev/null; then
			createdbargs="$createdbargs --lc_collate $locale"
		fi
		if PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/createdb --help | grep -e '--lc_ctype' >/dev/null; then
			createdbargs="$createdbargs --lc_ctype $locale"
		fi
		echo "Creating and initializing db for $rel"
		PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/createdb $createdbargs
		PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/psql -X --set wordlist="'$wordlist'" -f $here/benchmark-setup.sql
    fi

    #PATH=$bin:$PATH LD_LIBRARY_PATH=$lib $bin/psql -X -f $here/benchmark-fix.sql

    sync
    sleep 1

    echo -n "Running Benchmark on $rel..."
    TIMEFORMAT=%0lR
    time ( ( $bin/psql -X -f $here/benchmark-run-x8-pg.sql )  >>$out 2>&1 || echo psql exited with status $?)
    unset TIMEFORMAT

    trap - EXIT
    $bin/pg_ctl -D $db stop -m fast || echo pg_ctl exited with status $?

done
