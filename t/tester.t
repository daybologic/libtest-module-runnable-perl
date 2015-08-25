#!/usr/bin/perl
#
# Daybo Logic Shared Library
# Copyright (c) 2015, David Duncan Ross Palmer (2E0EOL), Daybo Logic
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#
#     * Neither the name of the Daybo Logic nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

package ExampleTest;
use Moose;
use Daybo::Shared::Tester;
use Test::More 0.96;

extends 'Daybo::Shared::Tester';

use strict;
use warnings;

has 'dummyRunCount' => (isa => 'Int', is => 'rw', default => 0);

sub increment {
	my $self = shift;
	$self->dummyRunCount(1 + $self->dummyRunCount);
}

sub funcNeverCalled {
	my $self = shift;
	plan tests => 1;

	$self->increment();
	cmp_ok($self->dummyRunCount, '>', 0, 'testFuncNeverCalled'); # Won't happen
	BAIL_OUT('Funcion never called, due to name');
}

sub testFuncIsCalled {
	my $self = shift;
	plan tests => 1;

	$self->increment();
	cmp_ok($self->dummyRunCount, '>', 0, 'funcIsCalled');
}

sub testFuncAnotherIsCalled {
	my $self = shift;
	plan tests => 1;

	$self->increment();
	cmp_ok($self->dummyRunCount, '>', 0, 'testFuncAnotherIsCalled');
}

package main;
use Test::More;
use POSIX qw/EXIT_SUCCESS/;
use Moose;
use List::MoreUtils qw/all/;
use strict;
use warnings;

sub main {
	my $tester;
	my $ret;
	my @methodNames;
	my %expectMethodNames = map { $_ => 1 } qw/testFuncIsCalled testFuncAnotherIsCalled/;
	my $allResult;

	plan tests => 10;

	$tester = new_ok('ExampleTest');
	isa_ok($tester, 'Daybo::Shared::Tester');
	can_ok($tester, qw/run methodCount sut methodNames/);

	is($tester->dummyRunCount, 0, 'No tests yet run');
	subtest 'run' => sub { $ret = $tester->run() };
	is($ret, EXIT_SUCCESS, 'Success returned');
	is($tester->dummyRunCount, 2, 'Two tests run');

	@methodNames = $tester->methodNames;
	$allResult = all { $expectMethodNames{$_} } @methodNames;
	isnt($allResult, undef, 'methodNames contains all expected names');
	is($tester->methodCount, 2, 'Method count correct');
	is(scalar(@methodNames), $tester->methodCount, 'methodNames returns same as methodCount');

	return $ret;
}

exit(main());
