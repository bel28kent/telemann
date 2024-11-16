#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Fri Nov 15 22:36:14 PST 2024
# Modified:    Fri Nov 15 22:39:36 PST 2024
# File:        updateEncodingData.pl
# Syntax:      Perl 5
# Description: updates telemann/metadata/encoding_data.tsv
#
#    if header, delete first row

use strict;
use warnings;
use Getopt::Long;

my $header;

GetOptions ("h|header" => \$header);

my $filename = "metadata/encoding_data.tsv";

print "Checking for existing metadata/encoding_data.tsv . . . ";
if (-e ($filename)) {
    print "EXISTS!\n";
    print "Deleting existing metadata/encoding_data.tsv . . . ";
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

my $id = "2PACX-1vRYYRKYyev3HqxUG7zSCVLkpRFrjJPQWh6v7DdO4Wb4_rFhQ24HgG08_oMKpQ_oTDPlndW63ADyLVoW";
my $url = "https://docs.google.com/spreadsheets/d/e/$id/pub?gid=148446842&single=true&output=tsv";

print "Creating new metadata/encoding_data.tsv . . . \n";
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
