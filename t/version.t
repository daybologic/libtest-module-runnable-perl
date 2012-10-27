#!/usr/bin/perl -w

use Daybo::ConfReader;
package main;
use Test::More tests => 1;

use constant CHECK_PKG => 'Daybo::ConfReader';
use constant CHECK_VER => '2.1.0';

is(
	$Daybo::ConfReader::VERSION,
	CHECK_VER(),
	sprintf(
		'%s::VERSION is \'%s\'',
		CHECK_PKG(),
		CHECK_VER()
	)
);
