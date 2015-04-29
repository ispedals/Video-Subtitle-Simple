#!perl

use strict;
use warnings;
use Test::More tests => 4;

use Video::Subtitle::Simple::SRT::Subtitle;

my $subtitle =
  Video::Subtitle::Simple::SRT::Subtitle->new( start => 2, end => 3 );

isa_ok( $subtitle, 'Video::Subtitle::Simple::SRT::Subtitle' );
is(
    $subtitle->to_string,
    "00:00:02,000 --> 00:00:03,000\n\n",
    'to_string() works'
);
$subtitle->set_text("Ha\nI knew you were dumb!\n");
is(
    $subtitle->get_text(),
    "Ha\nI knew you were dumb!",
    'text strips final newline'
);

my $subtitle2 = Video::Subtitle::Simple::SRT::Subtitle->new(
    start => 2,
    end   => 3,
    text  => "Ha\nI knew you were dumb!"
);
ok( $subtitle->is_equal($subtitle2), 'is_equal() works' );
