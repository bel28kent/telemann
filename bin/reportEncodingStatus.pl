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

my @encoding;
my @vhv;

report_encoding(0) if $opt_e;
report_encoding(1) if $opt_E;

report_vhv(0) if $opt_v;
report_vhv(1) if $opt_V;

#########################
#    SUBROUTINES
