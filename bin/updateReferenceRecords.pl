#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov  9 20:42:53 PST 2024
# Modified:    Sat Nov  9 20:42:53 PST 2024
# File:        updateReferenceRecords.pl
# Syntax:      Perl 5
# Description: update reference records in kern files
#
#    if initialize, will only add reference records to
#    files that only have !!key:
#    otherwise, will only update reference records in
#    files that already have them

use strict;
use warnings;
use Getopt::Long;

my @REF = ("COM", "CDT", "CBL", "CDL", "CNT",
           "TWV", "TWV-genre", "TWV-work", 
           "OPR", "OTL", "OMD", "OMV", "ODT",
           "AST", "AGN", "AMT", "AIN",
           "RTL1", "RPN1", "RMM1", "RC#1", "RRD1", "RLC1", "RDT1", "RT#1",
           "RTL2", "RPN2", "RMM2", "RC#2", "RRD2", "RLC2", "RDT2", "RT#2",
           "RTL3", "RPN3", "RMM3", "RC#3", "RRD3", "RLC3", "RDT3", "RT#3")
my %metadata = hash_metadata();

my $initialize;

GetOptions ("i|initialize" => \$initialize);

print "Listing kern files . . . ";
chomp (my @kern_files = `find kern -name '*krn' -print`);
print "DONE!\n";

print "Getting keys from files . . . ";
my @keys = get_keys();
print "DONE!\n";

if ($initialize) {
    print "Initializing files that only contain keys . . .\n";
    initialize_files();
    print "DONE!";
    exit (0);
}

print "Searching for uninitialized files . . . ";
my @files_to_update = search_uninitialized();
print "DONE!\n";

print "Updating metadata . . .\n";
update_metadata();
print "DONE!\n";


#########################
#    SUBROUTINES

# hash_metadata
# void -> %
# produces a hash of metadata
sub hash_metadata {
    my %meta;
    chomp (my @contents = `cat metadata/reference_records.tsv`);
    shift (@contents); # remove header
    foreach my $content (@contents) {
        my $key =~ m/tele.{+}\t/;
        $key =~ s/\t//;
        my $val = $content =~ s/tele.{+}\t//; 
        $meta{$key} = $val;
    }
    return %meta;
}

# get_keys
# void -> @
# produces a list of keys from the files
sub get_keys {
    my @keys;
    foreach my $kern (@kern_files) {
        open (my $filehandle, "<", $kern);
        chomp (my $key = readline ($filehandle));
        $key =~ s/!!key:\ //;
        push (@keys, $key);
        close ($filehandle);
    }
    return @keys;
}

# initialize_files 
# void -> void
# foreach file that only contains !!key, add reference records from metadata
sub initialize_files {
    for (my $i = 0; $i < scalar (@kern_files); $i++) {
        chomp (my @contents = `cat $kern_files[$i]`);
        if (scalar (@contents) == 0) {
            print "Error: $kern_files[$i] is EMPTY.\n";
            next;
        }
        if (scalar (@contents) > 1) {
            next;
        }
        add_references($kern_files[$i], $keys[$i]);
        print "$kern_files[$i] . . . DONE!\n";
    }
}

# add_references
# String String -> void
# add references from metadata to file
sub add_references {
    my $path = $_[0];
    my $key = $_[1];
    my @meta = get_metadata($key);
    open (my $filehandle, ">", $path);
    for (my $i = 0; $i < scalar (@REF); $i++) {
        if ($meta[$i] eq "NA") {
            next;
        }
        my $record = "!!!" . $REF[$i] . ": " . $meta[$i];
    }
    close ($filehandle);
}

# get_metadata
# String -> @
# produce array of tsv elements from metadata with key
sub get_metadata {
    my $key = $_[0];
    return split (/\t/, $metadata{$key});
}

# search_uninitialized
# void -> @
# if file in kern_files is unitialized, report to user, else add to files_to_update
sub search_uninitialized {
    foreach my $kern (@kern_files) {
        chomp (my @contents = `cat $kern`);
        if (scalar (@contents) == 0) {
            print "\nError: $kern_files[$i] is EMPTY.\n";
            next;
        }
        if (scalar (@contents) == 1) {
            print "\n$kern is uninitialized.\n";
            next;
        }
        push (@files_to_update, $kern);
    }
}

# update_metadata
# void -> void
# update metadata in each kern file in files_to_update
sub update_metadata {
    foreach my $kern (@files_to_update) {
        open (my $filehandle, "<", $kern);
        my $key = readline ($filehandle);
        my $metadatum = $metadata{$key};
    }
}
