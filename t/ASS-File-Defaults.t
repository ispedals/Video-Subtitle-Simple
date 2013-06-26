#!perl
use v5.12;
use strict;
use warnings;

use Test::More tests => 4;

use Video::Subtitle::OO::ASS::File;

my $file = Video::Subtitle::OO::ASS::File->new;
isa_ok( $file, 'Video::Subtitle::OO::ASS::File' );

my @events = @{ $file->Events };
is( scalar @events, 0, 'Empty constructor defaulted to no events' );

my @styles = @{ $file->Styles };
is( scalar @styles, 1, 'Empty constructor defaulted with single Style' );

is( $styles[0]->Name, 'Default', 'and the Style was Default' );
