#!/usr/bin/env perl
use strict;
use warnings;
use File::Copy;

# Path to the hook directory
my $git_hooks_dir = '.git/hooks';

# Files to copy
my @hooks = qw(pre-commit commit-msg);

# Copy each hook from the 'hooks' folder to the '.git/hooks' folder
for my $hook (@hooks) {
    my $source = "hooks/$hook";
    my $destination = "$git_hooks_dir/$hook";
    
    copy($source, $destination) or die "Failed to copy $source to $destination: $!\n";
    
    # Make sure the script is executable (on Unix-like systems)
    chmod 0755, $destination;
}

print "Git hooks installed successfully!\n";
