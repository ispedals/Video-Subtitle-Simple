#!perl
use v5.12;
use strict;
use warnings;

use Test::More tests => 2;

use Video::Subtitle::OO::ASS::Event;
my $event =
  Video::Subtitle::OO::ASS::Event->new( Format => 'Dialogue', start => 2, end => 3 );
isa_ok( $event, 'Video::Subtitle::OO::ASS::Event' );
is(
    $event->to_string,
    'Dialogue: 0,00:00:02.000,00:00:03.000,Default,,0000,0000,0000,,',
    'to_string() works'
);
