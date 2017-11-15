#!/usr/bin/perl

package mockNonExistentMethodTests;
use strict;
use Moose;
extends 'Test::Module::Runnable';

use English qw(-no_match_vars);
use Test::Module::Runnable;
use IO::Pipe;
use POSIX;
use Test::Exception;
use Test::More;
use Test::Output;

use lib 't/lib';
use Private::Test::Module::Runnable::Dummy2; # FIXME: Merge classes dummy and Dummy2
use Private::Test::Module::Runnable::DummyWithAutoload;

sub setUp {
	my ($self) = @_;

	$self->sut(Test::Module::Runnable->new);
	#$self->forcePlan(); # TODO: Not yet available

	return EXIT_SUCCESS;
}

sub tearDown {
	my ($self) = @_;

	$self->clearMocks();

	return EXIT_SUCCESS;
}

sub testClassWithoutAutoload {
	my ($self) = @_;
	plan tests => 2;

	my $pipe = IO::Pipe->new;
	BAIL_OUT("pipe: $ERRNO") unless $pipe;

	my $pid = fork;
	BAIL_OUT("fork: $ERRNO") unless defined $pid;

	# Easiest way to test BAIL_OUT is to fork a new process and execute it as
	# a new perl process.
	if ($pid == 0) {
		$pipe->writer();
		open STDOUT, '>&', $pipe;
		open STDERR, '>&', $pipe;

		my $code = <<EOF;
use Test::Module::Runnable;
use Private::Test::Module::Runnable::Dummy;
Test::Module::Runnable->new->mock('Private::Test::Module::Runnable::Dummy', 'noSuchMethod');
EOF

		exec('perl', (map { "-I$_" } @INC), '-e', $code);
		exit 127;
	}

	$pipe->reader();

	my $line = <$pipe>;
	is($line, "Bail out!  Cannot mock Private::Test::Module::Runnable::Dummy->noSuchMethod because it doesn't exist and Private::Test::Module::Runnable::Dummy has no AUTOLOAD\n",
		'bailed out as expected when mocking nonexistent method on class without AUTOLOAD');

	$pipe->close();
	wait;
	isnt($?, 0, 'process reported failure');

	return EXIT_SUCCESS;
}

sub testClassWithAutoload {
	my ($self) = @_;
	plan tests => 2;

	lives_ok { $self->mock('Private::Test::Module::Runnable::DummyWithAutoload', 'noSuchMethod') } 'can mock nonexistent method when class has AUTOLOAD';

	lives_ok { Private::Test::Module::Runnable::DummyWithAutoload->noSuchMethod } 'can call mocked method';

	return EXIT_SUCCESS;
}

package main;
use strict;
exit(mockNonExistentMethodTests->new->run);
