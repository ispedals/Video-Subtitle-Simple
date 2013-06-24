#!perl

use v5.10;
use strict;
use warnings;
use Test::More tests => 11;

use Video::Subtitle::OO::SRT::File;

my $file = Video::Subtitle::OO::SRT::File->new;
isa_ok( $file, 'Video::Subtitle::OO::SRT::File' );

my @subtitles = @{ $file->subtitles };
is( scalar @subtitles, 0, 'Empty constructor defaulted to no subtitles' );

$file->add_subtitle(
    { start => 2, end => 3, text => 'This occurs at 2 seconds' } );
is( scalar @{ $file->subtitles },
    1, 'add_subtitle() added to Subtitles attribute' );

is(
    @{ $file->subtitles }[0]->get_text,
    'This occurs at 2 seconds',
    'and had the correct Text attribute'
);

$file->add_subtitle(
    { start => 1, end => 2, text => 'This occurs at 1 second' } );
my @subs = $file->get_subtitles();
is(
    join( ', ', map { $_->get_text } @subs ),
    'This occurs at 1 second, This occurs at 2 seconds',
    'getSubtitles() sorted subtitles'
);

$file->add_subtitle( { start => 30, end => 60, text => '<Hola>' } );
$file->add_subtitle( { start => 75, end => 80, text => '<Como estas>' } );
is( scalar $file->get_subtitles_by_attribute( sub { $_->get_text =~ /^</; } ),
    2, 'get_subtitles_by_attribute() works' );

$file->remove_subtitle($_)
  foreach $file->get_subtitles_by_attribute( sub { $_->start->second == 30; }
  );
my @s = $file->get_subtitles();
is( scalar @s, 3, 'remove_subtitle() works' );

my $out = <<END;
1
00:01:34,117 --> 00:01:36,953
A

2
00:01:36,953 --> 00:01:39,053
B

3
00:01:40,106 --> 00:01:42,106
C
END

$file = Video::Subtitle::OO::SRT::File->create_from_string($out);
is( $file->to_string, $out, 'create_from_string() worked' );

my $newout = "\t  \n$out";

$file = Video::Subtitle::OO::SRT::File->create_from_string($newout);
is( $file->to_string, $out,
    'create_from_string() with leading whitespace worked' );
@subs = $file->get_subtitles;
is( $subs[2]->get_text, 'C', 'get_subtitles() sorted numerically' );my $file2 = Video::Subtitle::OO::SRT::File->new();
$file2->add_subtitle( { start => "00:01:34,117",  end => "00:01:36,953",  text => 'A' } );
$file2->add_subtitle( { start => "00:01:36,953",  end => "00:01:39,053",  text => 'B' } );
$file2->add_subtitle( { start => "00:01:40,106", end => "00:01:42,106", text => 'C' } );
#TODO add test that fails when sorted stringly and when start and end take seconds only values
#$file2->add_subtitle( { start => 94.117,  end => 96.953,  text => 'A' } );
#$file2->add_subtitle( { start => 96.953,  end => 99.053,  text => 'B' } );
#$file2->add_subtitle( { start => 100.106, end => 102.106, text => 'C' } );

ok( $file->is_equal($file2), 'is_equal() works' );
