#!/usr/bin/env perl
package modeSwitchTester;
use Moose;

extends 'Test::Module::Runnable';

use POSIX qw(EXIT_SUCCESS);
use Test::More 0.96;

has [qw(modeTracker mode)] => (isa => 'Int', is => 'rw', default => 0);
has modeName => (isa => 'Str', default => 'dummy mode name', is => 'ro');

sub modeSwitch {
	my ($self, $n) = @_;

	$self->debug(sprintf('mode is %d, iteration %d, setting mode %d',
	    $self->mode, $n, 1 + $n));

	$self->mode(1 + $n);

	return EXIT_SUCCESS;
}

sub testBlah {
	my ($self) = @_;
	plan tests => 1;

	is($self->mode, $self->modeTracker, sprintf('Mode is %u', $self->modeTracker));
	$self->modeTracker(1 + $self->modeTracker);

	return EXIT_SUCCESS;
}

package main;
use strict;
use warnings;

exit(modeSwitchTester->new->run(n => 3));
