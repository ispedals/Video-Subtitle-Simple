#!perl
use v5.12;
use strict;
use warnings;

use Test::More tests => 4;

use Video::Subtitle::OO::ASS::File;

my $file = Video::Subtitle::OO::ASS::File->new;
isa_ok( $file, 'Video::Subtitle::OO::ASS::File' );

$file->add_event(
    Format => 'Dialogue', start => 2, end => 3, Text => 'C,A' );
$file->add_dialogue( start => 1, end => 2, Text => 'B');
$file->add_comment( start => 0, end => 1, Text => 'A' );
$file->add_dialogue(
    start => '0:01:15', end => '0:01:20', Text => '<Como estas>', Name => 'Jill' );

my $out = <<'END';
[Script Info]
Title:untitled
Original Script:unknown
ScriptType:v4.00+
Collisions:Normal
WrapStyle:0

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Default,Arial,16,&H00FFFFFF,&H000000FF,&H0027415C,&H9027415C,0,0,0,0,100,100,0,0,1,2,1,2,0,0,0,1
[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,0:00:02.000,0:00:03.000,Default,,0000,0000,0000,,C,A
Dialogue: 0,0:00:01.000,0:00:02.000,Default,,0000,0000,0000,,B
Comment: 0,0:00:00.000,0:00:01.000,Default,,0000,0000,0000,,A
Dialogue: 0,0:01:15.000,0:01:20.000,Default,Jill,0000,0000,0000,,<Como estas>
END

is( Video::Subtitle::OO::ASS::File->create_from_string($out)->to_string,
    $file->to_string, 'create_from_string() works' );

use IO::String;

my $io = IO::String->new($out);

is( Video::Subtitle::OO::ASS::File->create_from_file($io)->to_string,
    $file->to_string, 'create_from_file() works' );

my @e = $file->get_events_by_attribute( sub { $_->Name eq 'Jill'; } );
$e[0]->Name('');    #remove name for comparision
my @subs = $file->get_subtitles;
$file->Events( \@subs );    #easy removal of comment

my $srt = <<'END';
1
0:00:01,000 --> 0:00:02,000
B

2
0:00:02,000 --> 0:00:03,000
C,A

3
0:01:15,000 --> 0:01:20,000
<Como estas>
END

my $srtio = IO::String->new($srt);

SKIP: {
    eval { require Video::Subtitle::OO::SRT::File };

    skip "Video::Subtitle::OO::SRT::File not installed", 1 if $@;
    is(
        Video::Subtitle::OO::ASS::File->create_from_subtitle(
            Video::Subtitle::OO::SRT::File->create_from_file($srtio)
          )->to_string,
        $file->to_string,
        'create_from_subtitle() works'
    );
}
