#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov 16 11:46:46 PST 2024
# Modified:    Sat Nov 16 16:10:01 PST 2024
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
verify_options();

chomp (my @encoding_data = `cat metadata/encoding_data.tsv`);

my @encoding;
my @vhv;

if (($opt_e || $opt_E) && !($opt_v || $opt_V)) {
    @encoding = @{ get_keys(2) };
    report(\@encoding);
    exit 0;
}
if (($opt_v || $opt_V) && !($opt_e || $opt_E)) {
    @vhv = @{ get_keys(3) };
    report(\@vhv);
    exit 0;
}
report(\@encoding, \@vhv);


#########################
#    SUBROUTINES

# verify_options
# void -> void
# unless only one option is set, or both ev OR EV are set, exit
sub verify_options {
    # TODO
    return 0;
}


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

# report
# \@, \@ -> void
# report encoding AND/OR vhv checking
sub report {
    # TODO
}
