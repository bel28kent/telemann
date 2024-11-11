#!/usr/bin/perl

# Programmer:  Bryan Jacob Bell
# Begun:       Sun Nov 10 13:47:24 PST 2024
# Modified:    Sun Nov 10 13:47:24 PST 2024
# File:        createKernDirAndFiles.pl
# Syntax:      Perl 5
# Description: make a directory with kern files
#
#    directory_name is specified without "kern/"
#
#    files are initialized with "!!key: " and the key from
#    metadata
#
#    files are given the name of the key found in metadata
#
#    unless override, will not make files with duplicate keys

use strict;
use warnings;
use Getopt::Long;

my $metadata = "metadata/reference_records.tsv";

my $directory_name;
my $search_string;
my $override;

GetOptions ("d|directory=s" => \$directory_name,
            "s|search=s" => \$search_string,
            "o|override" => \$override)
or die ("Error in options!\n");

print "Creating $directory_name in kern/ . . . ";
create_directory();

print "Searching metadata for files . . . ";
my @files = search_metadata();
die "No possible files found!\n" if (scalar (@files) == 0);

my @files_to_create;
unless ($override) {
    print "Checking possible files for potential duplicates . . .\n";
    my @duplicates = check_duplicates();
    print "DONE!\n";
    if (scalar (@duplicates) > 0) {
        print "Filtering duplicate files from possible files . . . ";
        @files_to_create = filter_duplicates(\@duplicates);
        print "DONE!\n";
    } else {
        @files_to_create = @files;
    }
} else {
    print "Skipping checks for duplicates\n";
    @files_to_create = @files;
}

print "Making files . . .\n";
make_files (\@files_to_create);
print "DONE!\n";

#########################
#    SUBROUTINES

# create_directory
# void -> void
# makes directory if it does not exist, exits if it does
sub create_directory {
    my $kern_dir = "kern/" . $directory_name;
    if (-e ($kern_dir)) {
        print "\nERROR: $kern_dir already exists!\n";
        exit (1);
    } else {
        `mkdir $kern_dir`;
        print "SUCCESS!\n";
    }
}

# search_metadata
# void -> @
# returns an array of the keys found in metadata
sub search_metadata {
    chomp (my @reference_records = `cat $metadata`);
    shift (@reference_records);
    my @possible_files;
    foreach my $record (@reference_records) {
        my @fields = split (/\t/, $record);
        if ($fields[10] =~ m/$search_string/) {
            push (@possible_files, $fields[0]);
        }
    }
    return @possible_files;
}

# check_duplicates
# void -> @
# returns an array of keys in existing kern files duplicated in possible files 
sub check_duplicates {
    my @existing_kern = `find kern`;
    my @existing_keys;
    foreach my $kern (@existing_kern) {
        open (my $filehandle, "<", $kern);
        push (@existing_keys, readline $filehandle =~ s/!!key:\ //);
        close ($filehandle);
    }
    my @duplicates;
    foreach my $key (@files) {
        print "$key . . . ";
        if (member ($key, \@existing_keys) == 0) {
            print "OKAY\n";
        } else {
            push (@duplicates, $key);
            print "EXISTS\n";
        }
    }
    return @duplicates
}

# member
# String @ -> 0 or 1
# returns 0 if String is not a member of @, otherwise 1
sub member {
    my $key = $_[0];
    my @existing_keys = @{$_[1]};
    foreach my $element (@existing_keys) {
        if ($element eq $key) {
            return 1;
        }
    }
    return 0;
}

# filter_duplicates
# @ -> void
# removes elements in @files that are in @
sub filter_duplicates {
    my @duplicates = @{$_[0]};    
    foreach my $file (@files) {
        if (member ($file, \@duplicates) == 0) {
            push (@files_to_create, $file);
        }
    }
}

# make_files
# @ -> void
# foreach element, make a file at kern/directory_name/ with element as filename
sub make_files {
    my @files = @{$_[0]};
    foreach my $file (@files) {
        print "$file . . . ";
        open (my $filehandle, ">", "kern/$directory_name/$file.krn");
        print $filehandle "!!key: $file\n";
        close ($filehandle);
        if (-e "kern/$directory_name/$file.krn") {
            print "DONE!\n";
        } else {
            print "ERROR!\n";
        }
    }
}
