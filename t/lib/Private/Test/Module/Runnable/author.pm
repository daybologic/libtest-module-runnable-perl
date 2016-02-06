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

package Private::Test::Module::Runnable::author;
use lib 't/lib';
use Moose;
use Test::More 0.96;
use POSIX qw/EXIT_SUCCESS EXIT_FAILURE/;
use strict;
use warnings;

extends 'Test::Module::Runnable';

=item C<methodsCalled>

The methods called hash is populated only in the instance of
the class under the C<sut>.

=cut

has 'methodsCalled' => (
	isa => 'HashRef[Str]',
	is  => 'ro',
	default => sub {{}},
);

sub setUpBeforeClass {
	my $self = shift;
	my $ret;

	$ENV{TEST_AUTHOR} = 0;

	$self->sut(Private::Test::Module::Runnable::author->new(
		pattern => qr/^subTest/, # Prevents recursion
	));
	return EXIT_FAILURE unless ($self->sut);

	$self->sut->author->{testAuthor} = 1;
	diag(($self->pattern));
	# FIXME: This is broken; deep recursion
	subtest 'subTest' => sub { $ret = $self->run() };
	return $ret;
}

sub subTestAuthor {
	my ($self, %args) = @_;
	plan tests => 1;
	is(++($self->methodsCalled->{$args{method}}), 1, 'record call');
	return EXIT_SUCCESS;
}

sub subTestUser {
	my ($self, %args) = @_;
	plan tests => 1;
	is(++($self->methodsCalled->{$args{method}}), 1, 'record call');
	return EXIT_SUCCESS;
}

sub testReal {
	my $self = shift;

	plan tests => 1;

	is_deeply(
		$self->sut->methodsCalled,
		{ 'subTestUser' => 1 },
		'Only user tests called'
	);

	return EXIT_SUCCESS;
}
1;
