#!/usr/bin/perl
#
# Module test framework
# Copyright (c) 2015-2016, David Duncan Ross Palmer (2E0EOL) and others,
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
#

package Private::Test::Module::Runnable::unique;
use lib 't/lib';
use Moose;
use Private::Test::Module::Runnable::unique;
use Test::More 0.96;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;
use strict;
use warnings;

extends 'Test::Module::Runnable';

=item C<trials>

The number of iteration to stress the unique 'rand' domain

=cut

has 'trials' => (
	isa     => 'Int',
	is      => 'ro',
	default => 10_000,
);

sub setUp {
	my $self = shift;

	$self->sut(Private::Test::Module::Runnable::unique->new());
	return EXIT_SUCCESS if ($self->sut);
	return EXIT_FAILURE;
}

sub testUnique {
	my $self = shift;
	my ($default, $other1, $other2) = (0, 0, 0);

	plan tests => 8;

	can_ok($self->sut, 'unique');

	is($self->sut->unique(), ++$default, 'Initial returned value');
	is($self->sut->unique(), ++$default, 'Next value');
	is($self->sut->unique(undef), ++$default, 'Default domain if undef');
	is($self->sut->unique(''), ++$default, 'Default domain if empty string');
	is($self->sut->unique(0), ++$other1, 'Zero is not the default domain');
	is($self->sut->unique('db3eb5cf-a597-4038-aea8-fd06faea6eed'), ++$default, 'Internal default domain UUID');
	is($self->sut->unique('5349b4de-c0e1-11e5-9912-ba0be0483c18'), ++$other2, 'Other domain UUID');

	return EXIT_SUCCESS;
}

sub testRandom {
	my $self = shift;
	my %spent; # Random numbers seen previously

	plan tests => $self->trials;

	for (my $i = 0; $i < $self->trials; $i++) {

		my $result = $self->sut->unique('rand');

		my $iter = sprintf(
			'trial iteration %u/%u',
			$i + 1, $self->trials,
		);

		subtest $iter => sub {
			plan tests => 3;

			cmp_ok($result, '>', 0, 'unique rand > 0');

			is($spent{$result}, undef, sprintf(
				'result %d not seen previously',
				$result
			));

			# Record result seen and do sanity check
			$spent{$result} = 1;
			is(scalar(keys(%spent)), $i + 1, sprintf(
				'%u items in spend list',
				$i + 1
			));
		};
	}

	return EXIT_SUCCESS;
}

1;
