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

=head1 NAME

Daybo::Shared::Tester - An OOP extension on top of Test::More

=head1 SYNOPSIS

package YourTestSuite;
use Moose;
use Test::More 0.96;
use strict;

extends 'Daybo::Shared::Tester';

sub myTest { }
sub testHelperFunction { }

package main;

my $tester = new YourTestSuite;
plan tests => $tester->testCount;
foreach my $name ($tester->testMethods) {
	subtest $name => $tester->$name;
}
...

=head1 DESCRIPTION

A test framework used by Daybo Logic and associated coders;
offered gratis to the community.

=cut

package Daybo::Shared::Tester;
use Moose;
use Daybo::Shared::Log;
use Daybo::Shared::Internal::Cache;
use List::MoreUtils qw/none/;
use Test::More 0.96;
use POSIX qw/EXIT_SUCCESS/;

extends 'Daybo::Shared::Internal::Base';

use strict;
use warnings;

our $VERSION = '0.0.4'; # Copy of master version number (TODO: Get from Base)

=head2 Methods

=over 12

=item C<sut>

System under test - a generic slot for an object you are testing, which
could be re-initialized under the C<setUp> routine, but this entry may be
ignored.

=cut

has 'sut' => (is => 'rw', required => 0);

=item C<testMethods>

Returns the names of all test methods which should be called by C<subtest>

=cut

sub testMethods {
        my @ret = ( );
        my $self = shift;
        my @methodList = $self->meta->get_method_list();

        foreach my $method (@methodList) {
                next unless ($self->can($method)); # Skip stuff we cannot do
		next if ($method eq 'sut' or $method eq 'setUp' or $method eq 'tearDown'); # Reserved routines
                next if ($method eq 'meta'); # Skip Moose internals
                next if ($method =~ m/^test/); # Skip our own helpers
                next if ($method =~ m/^[A-Z_]+$/o); # Skip constants
                push(@ret, $method);
        }

        return @ret;
}

=item C<testCount>

Returns the number of tests to pass to C<plan>

=cut

sub testCount {
        my $self = shift;
        return scalar($self->testMethods());
}

=item C<run>

Executes all of the tests, in a random order
An optional override may be passed with the tests parameter.

  * tests
    An ARRAY ref which contains the inclusive list of all tests
    to run.  If not passed, all tests are run. If an empty list
    is passed, no tests are run.  If a test does not exist, C<confess>
    is called.

Returns:
    The return value is always EXIT_SUCCESS, which you can pass straight
    to C<exit>

=cut

sub run {
	my ($self, %params) = @_;
	my @tests;

	if (ref($params{tests}) eq 'ARRAY') { # User specified
		@tests = @{ $params{tests} };
	} else {
		@tests = $self->testMethods();
	}

	plan tests => scalar(@tests);

	foreach my $method (@tests) {
		# Check if user specified just one test, and this isn't it
		#next if (scalar(@tests) && none { $_ eq $method } @tests);
		confess(sprintf('Test \'%s\' does not exist', $method))
			unless $self->can($method);

		$self->setUp() if ($self->can('setUp')); # Call any registered pre-test routine
		subtest $method => sub { $self->$method() }; # Correct test (or all)
		$self->tearDown() if ($self->can('tearDown')); # Call any registered post-test routine
	}

	return EXIT_SUCCESS;
}

=back

=head1 AUTHOR

David Duncan Ross Palmer, 2E0EOL L<mailto:palmer@overchat.org>

=head1 LICENCE

Daybo Logic Shared Library
Copyright (c) 2015, David Duncan Ross Palmer (2E0EOL), Daybo Logic
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

    * Neither the name of the Daybo Logic nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

=head1 AVAILABILITY

https://bitbucket.org/daybologic/libdaybo-shared-perl

=head1 CAVEATS

TODO: I have not unit tested the tester ;)

=cut

1;
