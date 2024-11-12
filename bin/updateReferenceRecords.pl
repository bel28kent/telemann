#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sat Nov  9 20:42:53 PST 2024
# Modified:    Tue Nov 12 13:45:57 PST 2024
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
           "RTL3", "RPN3", "RMM3", "RC#3", "RRD3", "RLC3", "RDT3", "RT#3");
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
    print "DONE!\n";
    exit 0;
}

print "Searching for uninitialized files . . . ";
my @files_to_update = search_uninitialized();
print "DONE!\n";

print "Updating metadata . . .\n";
update_metadata();
print "DONE!\n";


#########################
#    SUBROUTINES


##########
# getters

# get_key
# String -> String
# produce key from file
sub get_key {
    my $kern = $_[0];
    open (my $filehandle, "<", $kern);
    chomp (my $key = readline ($filehandle));
    close ($filehandle);
    $key =~ /(tele[^\t]+)/;
    return $1;
}

# get_keys
# void -> @
# produces a list of keys from the files
sub get_keys {
    my @keys;
    foreach my $kern (@kern_files) {
        my $key = get_key($kern);
        push (@keys, $key);
    }
    return @keys;
}

# get_metadata
# String -> @
# produce array of tsv elements from metadata with key
sub get_metadata {
    my $key = $_[0];
    return split (/\t/, $metadata{$key});
}

# get_references
# String -> %
# return a hash of key-val pairs for each $REF
sub get_references {
    my $kern = $_[0];
    my $key = get_key($kern);
    my @meta = get_metadata($key);
    my %references;
    for (my $i = 0; $i < scalar (@REF); $i++) {
        my $ref = $REF[$i];
        my $val = $meta[$i];
        $references{$ref} = $val;
    }
    return %references;
}

# get_ref_tag
# String -> String
# produce the tag of this reference record
sub get_ref_tag {
    my $ref_record = $_[0];
    $ref_record =~ /([\w\d\-@]{3,})/;
    return $1;
}


#############
# predicates

# is_reference
# String -> 1 or 0
# if string starts with !!! return 1, else 0
sub is_reference {
    my $record = $_[0];
    if ($record =~ m/^!!!/) {
        return 1;
    }
    return 0;
}

# member
# String @ -> 1 or 0
# if String is member of @, return 1, else 0
sub member {
    my $potential = $_[0];
    my @list = @{$_[1]};
    foreach my $first (@list) {
        return 1 if ($potential eq $first);
    }
    return 0;
}


##########
# i/o

# add_references
# String String -> void
# add references from metadata to file
sub add_references {
    my $path = $_[0];
    my $key = $_[1];
    my @meta = get_metadata($key);
    if (scalar (@meta) != scalar (@REF)) { exit 1; }
    open (my $filehandle, ">>", $path);
    for (my $i = 0; $i < scalar (@REF); $i++) {
        if ($meta[$i] eq "NA") {
            next;
        }
        my $record = "!!!" . $REF[$i] . ": " . $meta[$i];
        print $filehandle "$record\n";
    }
    close ($filehandle);
}

# hash_metadata
# void -> %
# produces a hash of metadata
sub hash_metadata {
    my %meta;
    chomp (my @contents = `cat metadata/reference_records.tsv`);
    shift (@contents); # remove header
    foreach my $content (@contents) {
        $content =~ /(tele[^\t]+)/;
        my $key = $1;
        $content =~ /(Telemann.+$)/;
        my $val = $1;
        $meta{$key} = $val;
    }
    return %meta;
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

# search_uninitialized
# void -> @
# report if file in kern_files is unitialized, else add to files_to_update
sub search_uninitialized {
    foreach my $kern (@kern_files) {
        chomp (my @contents = `cat $kern`);
        if (scalar (@contents) == 0) {
            print "\nError: $kern is EMPTY.\n";
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
        print "$kern . . .\n";
        my %references = get_references($kern);
        chomp (my @contents = `cat $kern`);
        my @new_contents;
        foreach my $content (@contents) {
            if (is_reference ($content)) {
                my $tag = get_ref_tag($content);
                if (member ($tag, \@REF)) {
                    my $new_ref = "!!!" . $tag . ": " . $references{$tag};
                    push (@new_contents, $new_ref);
                } else {
                    push (@new_contents, $content);
                }
            } else {
                push (@new_contents, $content);
            }
        }
        write_new_contents ($kern, \@new_contents);
        print "DONE!\n";
    }
}

# write_new_contents
# String @ -> void
# write @ to file at String
sub write_new_contents {
    my $kern = $_[0];
    my @to_write = @{$_[1]};
    print "writing to temp.krn\n";
    open (my $filehandle, ">", "temp.krn");
    foreach my $line (@to_write) {
        print $filehandle "$line\n";
    }
    close $filehandle;
    print "closed temp.krn\n";
    `rm $kern`;
    print "removed $kern\n";
    `mv temp.krn $kern`;
    print "moved temp.krn to $kern\n";
}
