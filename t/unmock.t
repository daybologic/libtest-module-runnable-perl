#!/usr/bin/perl
package unmockTests;
use strict;
use warnings;
use Moose;
extends 'FIXME::Tester';

use Test::More 0.96;

use Readonly;
use Test::MockModule;
use Test::Exception;
use FIXME::Tester;
use FIXME::Log::Mock 1.4.0;

has __controlClass => (isa => 'Str', is => 'ro', default => 'Alpha::Beta::Gamma');
has __mockingClass => (isa => 'Str', is => 'ro', default => 'FIXME::Log::Mock'); # Must be a real module
has __mockingMethodActive => (isa => 'Str', is => 'ro', default => 'trace'); # This is the method we're mocking
has __mockingMethodControl => (isa => 'Str', is => 'ro', default => 'debug'); # This is just to test we're not kidding ourselves

has __mockCallResult => (isa => 'Str', is => 'rw', default => '');

sub setUp {
	my ($self) = @_;
	my $dummy;
	my $methodActive = $self->__mockingMethodActive;

	$self->sut(FIXME::Tester->new);
	$self->forcePlan();

	$self->sut->mock($self->__mockingClass, $methodActive, ['Lenny','Horatio']);
	$dummy = $self->__mockingClass->new;
	$self->__mockCallResult($dummy->$methodActive('Horatio'));

	return 0;
}

sub tearDown {
	my ($self) = @_;

	$self->clearMocks;
	$self->__mockCallResult('');

	return 0;
}

sub testSanity {
	my ($self) = @_;

	plan tests => 6;

	is($self->__mockCallResult, 'Lenny', 'called mocked method');
	Readonly my $class => $self->__mockingClass;
	isa_ok($self->sut->{mock_module}->{$class}, 'Test::MockModule', 'mocker has been set') or diag(explain($self->sut->{mock_module}));
	is($self->sut->{mock_module}->{$class}->is_mocked($self->__mockingMethodActive), 1, sprintf('method \'%s\' is mocked', $self->__mockingMethodActive));
	is($self->sut->{mock_module}->{$class}->is_mocked($self->__mockingMethodControl), undef, sprintf('method \'%s\' is NOT mocked', $self->__mockingMethodControl));
	isa_ok($self->sut->{mock_args}->{$class}, 'HASH', 'mock_args for method');
	isa_ok($self->sut->{mock_args}->{$class}->{$self->__mockingMethodActive}, 'ARRAY', 'mock_args for method') or diag(explain($self->sut->{mock_args}));

	return;
}

sub testWithClassAndMethod {
	my ($self) = @_;
	Readonly my $class => $self->__mockingClass;

	plan tests => 4;

	is($self->sut->unmock($self->__mockingClass, $self->__mockingMethodActive), $self->sut, 'unmock return value');

	subtest 'after unset call' => sub {
		plan tests => 4;

		isa_ok($self->sut->{mock_module}->{$class}, 'Test::MockModule', 'mocker is still set') or diag(explain($self->sut->{mock_module}));
		is($self->sut->{mock_module}->{$class}->is_mocked($self->__mockingMethodActive), undef, sprintf('method \'%s\' is no longer mocked', $self->__mockingMethodActive));
		is($self->sut->{mock_args}->{$class}->{ $self->__mockingMethodActive }, undef, 'mock_args for method are cleared');
		isa_ok($self->sut->{mock_args}->{$class}, 'HASH', 'mock_args for class');
	};

	# Unmocking the unmocked method has no testable effect, nor has unmocked an unmocked class.
	# However, this allows us to enter a branch of code which would not otherwise execute.
	is($self->sut->unmock($self->__controlClass, $self->__mockingMethodControl), $self->sut, 'unmock return value');
	is($self->sut->unmock($self->__mockingClass, $self->__mockingMethodControl), $self->sut, 'unmock return value');

	return;
}

sub testWithClassOnly {
	my ($self) = @_;
	Readonly my $class => $self->__mockingClass;

	plan tests => 2;

	is($self->sut->unmock($self->__mockingClass), $self->sut, 'unmock return value');

	subtest 'after unset call' => sub {
		plan tests => 2;

		is($self->sut->{mock_module}->{$class}, undef, 'mocker is no longer set') or diag(explain($self->sut->{mock_module}));
		is(exists($self->sut->{mock_args}->{$class}), '', 'mock_args for class') or diag(explain($self->sut->{mock_args}));
	};

	return;
}


sub testNoArgs {
	my ($self) = @_;
	my $called = 0;

	plan tests => 2;

	$self->mock(ref($self->sut), 'clearMocks', sub {
		$called++;
	});

	is($self->sut->unmock(), $self->sut, 'unmock return value');

	subtest 'after unset call' => sub {
		plan tests => 1;

		is($called, 1, 'clearMocks was called');
	};

	return;
}

sub testWithNoClassButMethod {
	my ($self) = @_;

	plan tests => 1;

	throws_ok(sub { $self->sut->unmock(undef, 'x') }, qr/^It is not legal to unmock a method in many or unspecified classes/);

	return;
}

package main;
use strict;
exit(unmockTests->new->run);
