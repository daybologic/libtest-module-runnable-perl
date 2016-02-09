#!/usr/bin/perl
#
# Module test framework
# Copyright (c) 2015-2016, David Duncan Ross Palmer (2E0EOL) and others,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. Neither the name of the project nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE PROJECT AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE PROJECT OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#

package DayboHoratioTester; # TODO: Move to private hierarchy
use Moose;

extends 'Test::Module::Runnable';

sub notHoratio {
	return;
}

sub horatioDummy {
	return;
}

package DayboSharedPatternTester; # TODO: Move to private hierarchy
use lib 't/lib';
use Moose;
use Test::More 0.96;
use Test::Exception;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;
use strict;
use warnings;

extends 'Daybo::Shared::Tester';

has 'newPattern' => (
	isa => 'Regexp',
	is  => 'ro',
	default => sub { qr/^horatio/ },
);

sub setUp {
	my $self = shift;

	$self->sut(DayboHoratioTester->new());
	return EXIT_SUCCESS if ($self->sut);
	return EXIT_FAILURE;
}

sub testSut {
	my $self = shift;

	plan tests => 2;

	isa_ok($self->sut, 'DayboHoratioTester');
	isa_ok($self->sut, 'Test::Module::Runnable');

	return EXIT_SUCCESS;
}

sub testDefault {
	my $self = shift;

	plan tests => 1;

	is($self->sut->pattern, qr/^test/, 'default pattern');

	return EXIT_SUCCESS;
}

sub testConstructor {
	my $self = shift;

	plan tests => 2;

	$self->sut($self->sut->clone(pattern => $self->newPattern));
	is($self->sut->pattern, $self->newPattern, 'Pattern overridden via clone');
	$self->sut(ref($self->sut)->new(pattern => $self->newPattern));
	is($self->sut->pattern, $self->newPattern, 'Pattern overridden via new');

	return EXIT_SUCCESS;
}

sub testMethodsReturned {
	my $self = shift;

	plan tests => 2;

	is_deeply([$self->sut->methodNames], [], 'Nothing as default pattern');
	$self->sut($self->sut->clone(pattern => $self->newPattern));
	is_deeply([$self->sut->methodNames], ['horatioDummy'], 'horatioDummy with overridden pattern');

	return EXIT_SUCCESS;
}

package main;
use Test::More 0.96;

use strict;
use warnings;

sub main {
	$SIG{__WARN__} = sub { BAIL_OUT("@_") } unless ($ENV{TEST_VERBOSE});
	return DayboSharedPatternTester->new()->run();
}

exit(main());
