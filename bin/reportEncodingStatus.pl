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

my @encoding = @{ report_encoding() };
my @vhv = @{ report_vhv() };

#########################
#    SUBROUTINES

# report_encoding
# void -> \@
# produce list of keys of encoded works
sub report_encoding {
    # TODO
    my @keys;
    return \@keys;
}

# report_vhv
# void -> \@
# produce list of keys of works checked in vhv
sub report_vhv {
    # TODO
    my @keys;
    return \@keys;
}
