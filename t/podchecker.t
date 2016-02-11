#!/usr/bin/perl -w
package main;

use POSIX qw(EXIT_SUCCESS);
use Test::More 0.96;
use strict;
use warnings;

plan tests => 1;

SKIP: {
	skip 'TEST_AUTHOR only', 1 unless ($ENV{TEST_AUTHOR});

	is(system('podchecker lib/Test/Module/Runnable.pm'), EXIT_SUCCESS, 'podchecker');
};

exit(EXIT_SUCCESS);
