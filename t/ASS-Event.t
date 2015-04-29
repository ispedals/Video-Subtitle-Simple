#!perl

use strict;
use warnings;

use Test::More tests => 3;

use Video::Subtitle::Simple::ASS::Event;
my $event = Video::Subtitle::Simple::ASS::Event->new(
    Format => 'Dialogue',
    start  => 2,
    end    => 3
);
isa_ok( $event, 'Video::Subtitle::Simple::ASS::Event' );
is(
    $event->to_string,
    'Dialogue: 0,00:00:02.000,00:00:03.000,Default,,0000,0000,0000,,',
    'to_string() works'
);
ok( $event->is_equal($event), 'is_equal() works' );
