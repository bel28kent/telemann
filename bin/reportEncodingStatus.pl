#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov 16 11:46:46 PST 2024
# Modified:    Sat Nov 16 16:10:01 PST 2024
# File:        reportEncodingStatus.pl
# Syntax:      Perl 5
# Description: report status of encoding process

use strict;
use warnings;
use Getopt::Long;

my $last;
my $next;

GetOptions ("l|last=s" => \$last,
            "n|next=s" => \$next);

chomp (my @encoding_data = `cat metadata/encoding_data.tsv`);
shift (@encoding_data); # remove header

unless ($last || $next) {
    foreach my $datum (@encoding_data) {
        my @fields = split (/\t/, $datum);
        my $key = $fields[0];
        my $encoded = $fields[2];
        my $vhv_checked = $fields[3];
        if ($encoded) {
            if ($vhv_checked) {
                printf "%s:\t%s\t%s\n", $key, "encoded", "vhv checked";
            } else {
                printf "%s:\t%s\t%s\n", $key, "encoded", "not checked";
            }
        }
    }
}

report_last() if $last;
report_next() if $next;


#########################
#    SUBROUTINES

# report_last
# void -> void
# print key of last encoded work
sub report_last {
    foreach my $datum (reverse (@encoding_data)) {
        my @fields = split (/\t/, $datum);
        if ($fields[2]) {
            print "$fields[0]\n";
            exit 0;
        }
    }
}

# report_next
# void -> void
# print key of next work to encode
sub report_next {
    my $next = pop (@encoding_data);
    foreach my $datum (reverse (@encoding_data)) {
        my @fields = split (/\t/, $datum);
        if ($fields[2]) {
            $next =~ /(tele[^\t]+)/;
            print "$1\n";
            exit 0;
        }
        $next = $datum;
    }
}
