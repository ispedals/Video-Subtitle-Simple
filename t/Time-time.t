#!perl

use v5.10;
use strict;
use warnings;
use Test::More tests => 18;

use Video::Subtitle::Time;

my $time = Video::Subtitle::Time->new( second => 0 );
isa_ok( $time, 'Video::Subtitle::Time' );

$time = Video::Subtitle::Time->from_string('0:00:03.50');

#is() uses 'eq' for comparison, which result in a string comparsion, making 3.5 != to 3.500; using cmp_ok() allows us to use the numerical '=='
cmp_ok( $time->second, '==', 3.5, 'from_string with noninteger seconds parses second correctly' );
is( $time->hour,           0, 'from_string with noninteger seconds parses hour correctly' );
is( $time->minute,         0, 'from_string with noninteger seconds parses minute correctly' );
is( $time->integer_second, 3, 'integer_seconds works' );
is( $time->millisecond, 3500, 'millisecond works' );



is( $time->as_string, '00:00:03.500', 'as_string() works' );
is( $time->as_subrip_string(),
    '00:00:03,500', 'as_subrip_string() works' );

$time = Video::Subtitle::Time->from_string('01:16:03.578');
cmp_ok( $time->second, '==', 3.578,
    'from_string() with leading 0 parsed second correctly' );
is( $time->millisecond, 3578, 'millisecond works with from_string() with leading 0' );
is( $time->hour,           1, 'from_string with nonzero hour parses correctly' );
is( $time->minute,         16, 'from_string with nonzero minute parses correctly' );

$time = Video::Subtitle::Time->from_string('01:16:03,50');
cmp_ok( $time->second, '==', 3.5, 'from_string() with comma works' );
is( $time->millisecond, 3500, 'millisecond works with from_string() with comma' );
is( $time->hour,           1, 'from_string with comma parses hour correctly' );
is( $time->minute,         16, 'from_string with comma parses minute correctly' );

$time = Video::Subtitle::Time->from_string('00:10:59,978');
cmp_ok( $time->second, '==', 59.978,
    'second() is rounding correctly' );

$time = Video::Subtitle::Time->from_string('0:00:11');
cmp_ok( $time->second, '==', 11,
    'from_string() without milliseconds work' );
