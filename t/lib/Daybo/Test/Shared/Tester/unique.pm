#!/usr/bin/perl
#
# Daybo Logic Shared Library
# Copyright (c) 2016, David Duncan Ross Palmer (2E0EOL), Daybo Logic
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

package Daybo::Test::Shared::Tester::unique;
use lib 't/lib';
use Moose;
use Daybo::Test::Shared::Tester::unique;
use Test::More 0.96;
use Test::Exception;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;
use strict;
use warnings;

extends 'Daybo::Shared::Tester';

sub setUp {
	my $self = shift;

	$self->sut(Daybo::Test::Shared::Tester::unique->new());
	return EXIT_SUCCESS if ($self->sut);
	return EXIT_FAILURE;
}

sub testUnique {
	my $self = shift;

	plan tests => 5;

	can_ok($self->sut, 'unique');
	is($self->sut->__unique, 0, 'Initial value');
	is($self->sut->unique(), 1, 'Initial returned value');
	is($self->sut->__unique, 1, 'Counter incremented');
	is($self->sut->unique(), 2, 'Next value');
}

1;
