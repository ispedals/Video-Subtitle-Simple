#!perl

use v5.10;
use strict;
use warnings;
use Test::More tests => 4;

use Video::Subtitle::OO::SRT::Subtitle;

my $subtitle = Video::Subtitle::OO::SRT::Subtitle->new( start => 2, end => 3 );

isa_ok( $subtitle, 'Video::Subtitle::OO::SRT::Subtitle' );
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

my $subtitle2 = Video::Subtitle::OO::SRT::Subtitle->new(
    start => 2,
    end   => 3,
    text  => "Ha\nI knew you were dumb!"
);
ok( $subtitle->is_equal($subtitle2), 'is_equal() works' );
