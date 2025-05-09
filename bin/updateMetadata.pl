#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov  9 20:33:36 PST 2024
# Modified:    Tue Nov 12 13:55:38 PST 2024
# File:        updateMetadata.pl
# Syntax:      Perl 5
# Description: get data from telemann_metadata reference_records
#
# wget -O ./filename.tsv "LINK"

use strict;
use warnings;
use Getopt::Long;

my $header;

GetOptions ("h|header" => \$header);

my $filename = "metadata/reference_records.tsv";

print "Checking for existing metadata/reference_records.tsv . . . ";
if (-e ($filename)) {
    print "EXISTS!\n";
    print "Deleting existing metadata/reference_records.tsv . . . ";
    `rm $filename`;
    if (-e ($filename)) {
        print "ERROR!\n";
        exit 1;
    } else {
        print "DONE!\n";
    }
} else {
    print "DOESN'T EXIST!\n";
}

my $id = "2PACX-1vT7cL4WILKYh8r5-i8V2zdbrpFHh3lcS7Uuv_68Vl3vXLo0_0z-eHKlMMgPO_VusvDQFsUbLDDJasdg";
my $url = "https://docs.google.com/spreadsheets/d/e/$id/pub?gid=0&single=true&output=tsv";

print "Creating new metadata/reference_records.tsv . . . \n";
`wget -O ./$filename "$url"`;
if (-e ($filename)) {
    print "Processing carriage returns . . .";
    process_returns();
    print "DONE!\n";
    print "SUCCESS!\n";
} else {
    print "ERROR!\n";
    exit 1;
}

remove_header() if $header;


#########################
#    SUBROUTINES

# process_returns
# void -> void
# replaces carriage returns in file with newlines
sub process_returns {
    local $/ = "\r";
    chomp (my @contents = `cat $filename`);
    open (my $filehandle, ">", "temp.tsv");
    foreach my $content (@contents) {
        print $filehandle "$content";
    }
    close ($filehandle);
    `rm $filename`;
    `mv temp.tsv $filename`;
}


# remove_header
# void -> void
# removes top header from sheet
sub remove_header {
    chomp (my @current_file = `cat $filename`);
    shift (@current_file);
    open (my $filehandle, ">", "metadata/temp.tsv");
    foreach my $record (@current_file) {
        print $filehandle "$record\n";
    }
    close ($filehandle);
    `rm $filename`;
    `mv metadata/temp.tsv $filename`;
}
