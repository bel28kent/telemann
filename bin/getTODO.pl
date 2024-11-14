#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Wed Nov 13 18:39:48 PST 2024
# Modified:    Wed Nov 13 18:39:48 PST 2024
# File:        getTODO.pl
# Syntax:      Perl 5
# Description: produce all records in a single file that match TODO
#
#    if -h, hide filename in reporting
#

use strict;
use warnings;
use Getopt::Long;

my $filename;
my $hide;

GetOptions ("f|filename=s" => \$filename,
            "h|hide" => \$hide);
if (!$filename) {
  die ("Error in options: f|filename=s, MAYBE h|hide\n");
}

open (my $filehandle, "<", $filename);
while (my $record = readline ($filehandle)) {
    chomp ($record);
    $record =~ /(TODO)/;
    if ($1) {
        unless ($hide) {
            printf "%s:\t%s\n", $filename, $record;
        } else {
            printf "%s\n", $record;
        }
    }
}
close ($filehandle);
