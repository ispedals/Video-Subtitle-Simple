#!perl

use strict;
use warnings;

use Test::More tests => 3;

use Video::Subtitle::Simple::ASS::Style;
my $style = Video::Subtitle::Simple::ASS::Style->new( Name => 'def' );
isa_ok( $style, 'Video::Subtitle::Simple::ASS::Style' );
is(
    $style->to_string,
'Style: def,Arial,16,&H00FFFFFF,&H000000FF,&H0027415C,&H9027415C,0,0,0,0,100,100,0,0,1,2,1,2,0,0,0,1',
    'to_string() works'
);
ok( $style->is_equal($style), 'is_equal() works' );
