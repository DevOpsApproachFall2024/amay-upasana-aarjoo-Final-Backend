use strict;
use warnings;
use ExtUtils::MakeMaker;

# Define your project dependencies
my @prereqs = (
    'Dancer2' => '0',
    'MongoDB' => '0',
    'JSON' => '0',
    'JSON::MaybeXS' => '0',
    'Dancer2::Plugin::JWT' => '0',
    'Crypt::PBKDF2' => '0',
);

# Create the Makefile
WriteMakefile(
    NAME         => 'TriviaApp',  # Change this to your module's name
    PREREQ_PM    => { @prereqs },
);
