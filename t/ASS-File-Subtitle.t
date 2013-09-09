#!perl
use v5.12;
use strict;
use warnings;

use Test::More tests => 4;

use Video::Subtitle::Simple::ASS::File;

my $file = Video::Subtitle::Simple::ASS::File->new;
isa_ok( $file, 'Video::Subtitle::Simple::ASS::File' );

SKIP: {
    eval { require Video::Subtitle::Simple::SRT::Subtitle };

    skip "Video::Subtitle::Simple::SRT::Subtitle not installed", 3 if $@;

    my $srt =
      Video::Subtitle::Simple::SRT::Subtitle->new(
        { start => 0, end => 1, text => 'srt' } );
    say $srt->get_text;
    $file->add_subtitle($srt);
    my @s = $file->get_subtitles;
    is( scalar @s, 1, 'add_subtitle() works' );

    my @matches =
      $file->get_events_by_attribute( sub { $_->get_text eq 'srt' } );
    is( scalar @matches, 1, 'get_events_by_attribute matched a subtitle' );

    $file->remove_subtitle($srt);
    @s = $file->get_subtitles;
    is( scalar @s, 0, 'remove_subtitle() works' );
}
