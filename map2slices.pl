#!/usr/bin/perl

# Copyright (C) 2010 Richard Wallman <richard.wallman@bossolutions.co.uk>
# This program is free software; you may redistribute it and/or modify it under the same terms as perl.

use strict;
use warnings;
use Image::Magick;

die "Cannot read the .map file" unless -r $ARGV[0];

open( my $mapfile, '<', $ARGV[0] ) or die "Cannot open the .map file";

# First line is the header
my $line = <$mapfile>;

# Extract the image filename from it
$line =~ m/src="(.*?)"/;
my $imagefile = $1;

die "Cannot find the image '$1'" unless -r $1;

# Read the image
my $image = new Image::Magick;
$image->read( $imagefile );

my $slicecount = 0;

# Read the rest of the .map file and slice when we find a region
while ( $line = <$mapfile> ) {

	# Skip line unless it contains some co-ordinates
	next unless $line =~ m/shape="rect" coords="(.*?)"/;

	# Process the coordinate list
	my @coords = split q{,}, $1;

	# If we don't have exactly 4 coordinates
	if ( ~~@coords != 4 ) {
		warn "Sorry, I can only work with RECT areas : $line";
		next;
	};

	my $slice = $image->clone();
	$slice->Crop( x=>$coords[0], y=>$coords[1], width=>$coords[2], height=>$coords[3] );
	if ( $line =~ m/ href="(.*?)"/ ) {
		$slice->Write( $1 );
	}
	else {
		$slice->Write( sprintf( '%03d.jpg', $slicecount++ ) );
	};
};

close( $mapfile );
