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

sub helper { } # Not called
sub testExample { } # Called due to 'test' prefix.

package main;

my $tester = new YourTestSuite;
plan tests => $tester->testCount;
foreach my $name ($tester->testMethods) {
	subtest $name => $tester->$name;
}

alternatively...

my $tester = new YourTestSuite;
return $tester->run;

=head1 DESCRIPTION

A test framework used by Daybo Logic and associated coders;
offered gratis to the community.

=cut

package Daybo::Shared::Tester;
use Moose;
use Daybo::Shared::Log;
use Daybo::Shared::Internal::Cache;
use Test::More 0.96;
use POSIX qw/EXIT_SUCCESS/;

extends 'Daybo::Shared::Internal::Base';

use strict;
use warnings;

our $VERSION = '0.2.1'; # Copy of master version number (TODO: Get from Base)

=head2 Methods

=over 12

=item C<sut>

System under test - a generic slot for an object you are testing, which
could be re-initialized under the C<setUp> routine, but this entry may be
ignored.

=cut

has 'sut' => (is => 'rw', required => 0);

=item C<methodNames>

Returns a list of all names of test methods which should be called by C<subtest>,
ie. all method names beginning with 'test'.

If you use C<run>, this is handled automagically.

=cut

sub methodNames {
        my @ret = ( );
        my $self = shift;
        my @methodList = $self->meta->get_all_methods();

        foreach my $method (@methodList) {
		$method = $method->name;
                next unless ($self->can($method)); # Skip stuff we cannot do
                next if ($method !~ m/^test/); # Skip our own helpers
                push(@ret, $method);
        }

        return @ret;
}

=item C<methodCount>

Returns the number of tests to pass to C<plan>

=cut

sub methodCount {
        my $self = shift;
        return scalar($self->methodNames());
}

sub __wrapFail {
	my ($self, $type, $method, $returnValue) = @_;
	return if (defined($returnValue) && $returnValue eq '0');
	BAIL_OUT($type . ' returned non-zero for ' . $method);
}

=item C<run>

Executes all of the tests, in a random order
An optional override may be passed with the tests parameter.

  * tests
    An ARRAY ref which contains the inclusive list of all tests
    to run.  If not passed, all tests are run. If an empty list
    is passed, no tests are run.  If a test does not exist, C<confess>
    is called.

  * n
    Number of times to iterate through the tests.
    Defaults to 1.  Setting to a higher level is useful if you want to
    prove that the random ordering of tests does not break, but you do
    no want to type 'make test' many times.

Returns:
    The return value is always EXIT_SUCCESS, which you can pass straight
    to C<exit>

=cut

sub run {
	my ($self, %params) = @_;
	my @tests;

	$params{n} = 1 unless ($params{n});

	if (ref($params{tests}) eq 'ARRAY') { # User specified
		@tests = @{ $params{tests} };
	} else {
		@tests = $self->methodNames();
	}

	plan tests => scalar(@tests) * $params{n};

	for (my $i = 0; $i < $params{n}; $i++) {
		foreach my $method (@tests) {
			my $fail = 0;

			# Check if user specified just one test, and this isn't it
			confess(sprintf('Test \'%s\' does not exist', $method))
				unless $self->can($method);

			$fail = $self->setUp(method => $method) if ($self->can('setUp')); # Call any registered pre-test routine
			$self->__wrapFail('setUp', $method, $fail);
			subtest $method => sub { $self->$method() }; # Correct test (or all)
			$fail = 0;
			$fail = $self->tearDown(method => $method) if ($self->can('tearDown')); # Call any registered post-test routine
			$self->__wrapFail('tearDown', $method, $fail);
		}
	}

	return EXIT_SUCCESS;
}

sub debug {
	my (undef, $format, @params) = @_;
	return unless ($ENV{'TEST_VERBOSE'});
	diag(sprintf($format, @params));
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

None known.

=cut

1;
