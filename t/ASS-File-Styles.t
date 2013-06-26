#!perl
use v5.12;
use strict;
use warnings;

use Test::More tests => 5;

use Video::Subtitle::OO::ASS::File;

my $file = Video::Subtitle::OO::ASS::File->new;
isa_ok( $file, 'Video::Subtitle::OO::ASS::File' );

$file->add_style( Name => 'Note' );
is( scalar @{ $file->Styles },   2,      'add_style() added Style' );
is( @{ $file->Styles }[1]->Name, 'Note', 'and it was correct' );

my $note = @{ $file->Styles }[1];
$note->Name('Boom');
is( @{ $file->Styles }[1]->Name, 'Boom', 'Styles are recieved as reference' );

$file->remove_style($_)
  foreach $file->get_style_by_attribute( sub { $_->Name eq 'Boom' } );
is( scalar @{ $file->Styles }, 1, 'remove_style() removed Style' );
