#!/usr/bin/perl
package mockTests;
use strict;
use lib 't/lib';
use Moose;

extends 'Test::Module::Runnable';

use POSIX qw(EXIT_SUCCESS);
use Private::Test::Module::Runnable::Dummy2;
use Test::Deep qw(cmp_deeply shallow);
use Test::Exception;
use Test::Module::Runnable;
use Test::More;

sub setUp {
	my ($self, %params) = @_;

	$self->sut(Test::Module::Runnable->new);

	return $self->SUPER::setUp(%params);
}

sub tearDown {
	my ($self, %params) = @_;
	$self->sut->clearMocks();
	return $self->SUPER::setUp(%params);
}

sub testVerbose {
	my ($self) = @_;

	my $v = $ENV{TEST_VERBOSE};
	$ENV{TEST_VERBOSE} = 1;

	$self->_testVerbose([], [], 'Private::Test::Module::Runnable::Dummy2::realMethod() returning ()');
	$self->_testVerbose([1], [2], 'Private::Test::Module::Runnable::Dummy2::realMethod(1) returning (2)');
	$self->_testVerbose([1, 2], ['a', 'b'], "Private::Test::Module::Runnable::Dummy2::realMethod(1, 2) returning ('a', 'b')");

	$self->_testVerbose([{}, []], [Private::Test::Module::Runnable::Dummy2->new], qr/^
		Private::Test::Module::Runnable::Dummy2::realMethod
		\(
		'HASH\(\w+\)', \s 'ARRAY\(\w+\)'
		\)
		\s returning \s
		\(
		'Private::Test::Module::Runnable::Dummy2=HASH\(\w+\)'
		\)$/x);

	$ENV{TEST_VERBOSE} = $v;

	return EXIT_SUCCESS;
}

sub _testVerbose {
	my ($self, $in, $out, $expectedMessage) = @_;

	$self->sut->mock('Private::Test::Module::Runnable::Dummy2', 'realMethod', sub { return @$out });

	my $lastdiag;
	my $mock = Test::MockModule->new('Test::Builder');
	$mock->mock('diag', sub { $lastdiag = $_[1] });

	my $obj = Private::Test::Module::Runnable::Dummy2->new;
	(undef) = $obj->realMethod(@$in);

	$mock = undef;

	if (ref $expectedMessage) {
		like($lastdiag, $expectedMessage);
	} else {
		is($lastdiag, $expectedMessage);
	}

	return;
}

sub test {
	my ($self) = @_;

	$self->sut->logger->clear();

	$self->sut->logger->debug("one");

	$self->sut->mock('FIXME::Log::Mock', 'debug');

	$self->sut->logger->debug("two");
	$self->sut->logger->debug();

	# 'two' and <no-args> mocked
	is_deeply($self->sut->mockCalls('FIXME::Log::Mock', 'debug'), [
		['two'],
		[],
	], 'correct mocked logger calls');

	$self->sut->clearMocks();

	is_deeply($self->sut->mockCalls('FIXME::Log::Mock', 'debug'), [], 'mock calls cleared');

	$self->sut->logger->debug("four");

	# we should have 'one' and 'four' logged for real
	is_deeply($self->sut->logger->get_entries, [
		[123, 'one'],
		[123, 'four'],
	], 'correct log entries (real)');

	return;
}

sub testCode {
	my ($self) = @_;

	my $counter = 0;
	$self->sut->mock('FIXME::Log::Mock', 'debug', sub { $counter++ });
	$self->sut->logger->debug("first");
	$self->sut->logger->debug("second");
	is($counter, 2, 'mocked code block was called');

	return;
}

sub testDie {
	my ($self) = @_;
	plan tests => 4;

	$self->sut->mock(ref($self->sut), 'unique', [
		"first",
		sub { die "dies second time" },
		"third",
	]);

	is($self->sut->unique('first'), 'first', 'first return value correct');
	throws_ok { $self->sut->unique('second') } qr/^dies second time/, 'dies second time correctly';
	is($self->sut->unique('third'), 'third', 'third return value correct');

	is_deeply($self->sut->mockCalls(ref($self->sut), 'unique'), [
		['first'],
		['second'],
		['third'],
	], 'correct calls recorded');

	return;
}

sub testArray {
	my ($self) = @_;

	$self->sut->mock('FIXME::Object', 'log', [1,2,3]);

	my $obj = FIXME::Object->new;
	is($obj->log, 1);
	is($obj->log, 2);
	is($obj->log, 3);
	is($obj->log, undef, 'undef (list exhausted)');
	is($obj->log, undef, 'undef again (just checking)');
	is_deeply([$obj->log], [], 'empty array in list context');

	return;
}

sub testArrayMixed {
	my ($self) = @_;

	$self->sut->mock('FIXME::Object', 'log', [
		'first call',
		['second', 'call'],
		{ third => 'call' },
		undef,
		sub { return ('fifth', 'call') },
	]);


	my $obj = FIXME::Object->new;
	is($obj->log, 'first call');
	is_deeply($obj->log, ['second', 'call']);
	is_deeply($obj->log, { third => 'call' });
	is($obj->log, undef, 'fourth call undef');
	is_deeply([$obj->log], ['fifth', 'call']); # note [] on left, so log() returns list, not array ref
	is($obj->log, undef);

	return;
}

sub testBadReturn {
	my ($self) = @_;

	throws_ok { $self->sut->mock('Test::Module::Runnable', 'unique', 1) } qr/^\$return must be CODE or ARRAY ref /;

	return;
}

sub testCodeReturn {
	my ($self) = @_;

	$self->sut->mock('FIXME::Log::Mock', 'debug', sub { return 'business' });
	is($self->sut->logger->debug(), 'business');

	$self->sut->mock('FIXME::Log::Mock', 'debug', sub { return ('list', 'of', 'things') });
	is_deeply([$self->sut->logger->debug()], ['list', 'of', 'things']);

	return;
}

sub testMultipleFunctions {
	my ($self) = @_;
	$self->sut->mock('FIXME::Log::Mock', 'debug');
	$self->sut->mock('FIXME::Log::Mock', 'trace');

	$self->sut->logger->debug("this is a debug");
	$self->sut->logger->trace("this is a trace");

	is_deeply($self->sut->mockCalls('FIXME::Log::Mock', 'debug'), [
		['this is a debug'],
	]);
	is_deeply($self->sut->mockCalls('FIXME::Log::Mock', 'trace'), [
		['this is a trace'],
	]);

	return;
}

sub testMockCallsWithObject {
	my ($self) = @_;
	plan tests => 1;

	my $logger1 = FIXME::Log::Mock->new;
	my $logger2 = FIXME::Log::Mock->new;

	$self->sut->mock('FIXME::Log::Mock', 'debug');

	my $msg = $self->uniqueStr;

	$logger1->debug();
	$logger2->debug($msg);

	cmp_deeply($self->sut->mockCallsWithObject('FIXME::Log::Mock', 'debug'), [
		[ shallow($logger1) ],
		[ shallow($logger2), $msg ],
	], 'correct log calls with object refs');

	return;
}

package main;
use strict;
exit(mockTests->new->run) unless caller;
