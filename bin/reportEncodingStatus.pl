#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov 16 11:46:46 PST 2024
# Modified:    Sat Nov 16 11:46:46 PST 2024
# File:        reportEncodingStatus.pl
# Syntax:      Perl 5
# Description: report status of encoding process
#
#    -e, only report works that have been encoded
#    -E, report encoding status of all works
#    -v, only report works that have been verified in vhv
#    -V, report vhv checking of all works
#    -ev or -EV, report both

use strict;
use warnings;
use Getopt::Std;

getopts('eEvV');

chomp (my @encoding_data = `cat metadata/encoding_data.tsv`);

my @encoding = @{ get_keys(2) };
my @vhv = @{ get_keys(3) };

#########################
#    SUBROUTINES

# get_keys
# 2 or 3 -> \@
# produce a list of keys
sub get_keys {
    my $index = shift (@_);
    my @keys;
    foreach my $datum (@encoding_data) {
        my @fields = split (/\t/, $datum);
        if ($index == 2) {
            if ($opt_e && !$fields[$index]) {
                next;
            }
        }
        if ($index == 3) {
            if ($opt_v && !$fields[$index]) {
                next;
            }
        }
        push (@keys, $fields[$index]);
    }
    return \@keys;
}
