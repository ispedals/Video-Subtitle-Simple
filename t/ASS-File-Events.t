#!perl
use v5.16;
use utf8;
use strict;
use warnings;

use Test::More tests => 15;

use Video::Subtitle::Simple::ASS::File;

my $file = Video::Subtitle::Simple::ASS::File->new;
isa_ok( $file, 'Video::Subtitle::Simple::ASS::File' );

$file->add_event( Format => 'Dialogue', start => 2, end => 3, Text => 'C,A' );
is( scalar @{ $file->Events }, 1, 'add_event() added to Events attribute' );
is( $file->Events->[0]->get_text, 'C,A', 'and had the correct Text attribute' );

$file->add_dialogue( start => 1, end => 2, Text => 'B' );
is( scalar @{ $file->Events }, 2, 'add_dialogue() added to Events attribute' );

$file->add_comment( start => 0, end => 1, Text => 'A' );
is( scalar @{ $file->Events }, 3, 'add_comment() added to Events attribute' );

my @subs = $file->get_subtitles;
is( scalar @subs, 2, 'get_subtitles() filtered comment' );
is( join( '', map { $_->get_text } @subs ),
    'BC,A', 'get_subtitles() sorted subtitles' );

$file->add_dialogue(
    start => 30,
    end   => '00:01:00',
    Text  => '<Hola>',
    Name  => 'Bill'
);
$file->add_dialogue(
    start => '00:01:15',
    end   => '00:01:20',
    Text  => '<Como estas>',
    Name  => 'Jill'
);
is( scalar $file->get_events_by_attribute( sub { $_->get_text =~ /^</; } ),
    2, 'get_events_by_attribute() works' );

$file->remove_event($_)
  foreach $file->get_events_by_attribute( sub { $_->Name eq 'Bill'; } );
my @s = $file->get_subtitles;
is( scalar @s, 3, 'remove_event() works' );

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
Dialogue: 0,00:00:02.000,00:00:03.000,Default,,0000,0000,0000,,C,A
Dialogue: 0,00:00:01.000,00:00:02.000,Default,,0000,0000,0000,,B
Comment: 0,00:00:00.000,00:00:01.000,Default,,0000,0000,0000,,A
Dialogue: 0,00:01:15.000,00:01:20.000,Default,Jill,0000,0000,0000,,<Como estas>
END

is( $file->to_string, $out, 'to_string() outputted correctly' );

$out = <<'END';
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
Dialogue: 0,0:01:40.400,0:01:43.070,Default,,0,0,0,,姫っち\Nはひッ！
Dialogue: 0,0:16:40.100,0:16:43.100,Default,,0,0,0,,いや　こっちだろう\Nワンパク！
Dialogue: 0,0:00:11.830,0:00:14.400,Default,,0,0,0,,そういえば　真宵さんは
END

$file = Video::Subtitle::Simple::ASS::File->create_from_string($out);
my @g = $file->get_subtitles;
cmp_ok( $g[0]->start->as_seconds, '==', 11.830, 'sorting is numeric' );

$out = <<'END';
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
Dialogue: 0,0:01:04.400,0:01:04.070,Default,,0,0,0,,姫っち\Nはひッ！
Dialogue: 0,0:16:40.100,0:16:43.100,Default,,0,0,0,,いや　こっちだろう\Nワンパク！
Dialogue: 0,0:00:11.830,0:00:14.400,Default,,0,0,0,,そういえば　真宵さんは
END

$file = Video::Subtitle::Simple::ASS::File->create_from_string($out);
@g    = $file->get_subtitles;
cmp_ok( $g[0]->start->as_seconds, '==', 11.830,
'get_subtitles() sorted by considering the entire timestamp, not just the "second" component'
);

$file = Video::Subtitle::Simple::ASS::File->new;

$file->add_event(
    { Format => 'Dialogue', start => 2, end => 3, Text => 'C,A' } );
is( scalar @{ $file->Events }, 1, 'add_event() handles hashrefs' );

$file->add_dialogue( { start => 1, end => 2, Text => 'B' } );
is( scalar @{ $file->Events }, 2, 'add_dialogue() handles hashrefs' );

$file->add_comment( { start => 0, end => 1, Text => 'A' } );
is( scalar @{ $file->Events }, 3, 'add_comment() handles hashrefs' );
