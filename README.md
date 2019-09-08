# README #

Base class for runnable unit tests using Moose introspection
and a user-defined pattern for subtest routines.

## What is this repository for? ##

* This is the source code for Test::Module::Runnable

## How do I get set up? ##

* The easiest way to install this package is via the cpan CLI;
  Simply type install Test::Module::Runnable
* Alternatively, Debian packages are available via the author's website.

## Contribution guidelines ##

### Writing tests (internal) ###

nb. not to be confused with writing your own tests, for your own code.

All tests line under the t/ directory.

All tests are based on the framework itself, either as a subclass, or via the 'sut',
("system under test") member attribute.  We keep to the standard 'test' pattern,
unless testing the pattern code itself.

### Code review ###

There is presently no pull request system on Sourcehut, so all patches must be submitted
via the 'discuss' mailing list, using the hg bundle feature.

## Other guidelines ##

We use the [Mercurial](https://www.mercurial-scm.org/) source control system and our primary hosting location
is the primary [Sourcehut](https://hg.sr.ht/~m6kvm/libtest-module-runnable-perl) (not self-hosted).

## Contacting us ##

* [Duncan Ross Palmer](http://www.daybologic.co.uk/contact.php)
* [announce](https://lists.sr.ht/~m6kvm/libtest-module-runnable-perl-announce) mailing list
* [discuss](https://lists.sr.ht/~m6kvm/libtest-module-runnable-perl-discuss) mailing list

### Availability ###

The project is available for download from the following sites:
* [Sourcehut](https://hg.sr.ht/~m6kvm/libtest-module-runnable-perl)
* [Daybo Logic](http://www.daybologic.co.uk/software.php?content=libtest-module-runnable-perl)
* [CPAN](https://metacpan.org/pod/Test::Module::Runnable)

#### Direct download links ####

* [Sourcehut (.tar.gz)](https://hg.sr.ht/~m6kvm/libtest-module-runnable-perl/archive/libtest-module-runnable-perl-0.4.1.tar.gz)
* [CPAN (.tar.gz)](https://cpan.metacpan.org/authors/id/D/DD/DDRP/Test-Module-Runnable-0.4.1.tar.gz)
* [Daybo Logic (.tar.gz)](http://downloads.daybologic.co.uk/libtest-module-runnable-perl-0.4.1.tar.gz)
* [Daybo Logic (Debian package)](http://downloads.daybologic.co.uk/libtest-module-runnable-perl_0.4.1_all.deb)
