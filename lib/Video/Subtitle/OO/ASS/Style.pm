package Video::Subtitle::OO::ASS::Style;
# ABSTRACT: Representation of an ASS style
# VERSION
use v5.12;
use strict;
use warnings;

use Moo;

=head1 SYNOPSIS

    use Video::Subtitle::OO::ASS::Style;
    
    my $style=Video::Subtitle::OO::ASS::Style->new(Name => 'def');
    $style->Fontname('Helvatica');
    my $ASS_file_object;
    $ASS_file_object->add_style($style);

=head1 DESCRIPTION

This represents an ASS style
=cut

=attr Name

The string name of the style. This is required.
=cut

has 'Name' => (
    is       => 'rw',
    required => 1,
);

=attr Fontname

The string name of the font. It defaults to Arial
=cut

has 'Fontname' => ( default => 'Arial', is => 'rw' );

=attr Fontsize

The number font size. It defaults to 16
=cut

has 'Fontsize' => ( default => 16, is => 'rw' );

=attr PrimaryColour

Defaults to &H00FFFFFF
=cut

has 'PrimaryColour' => ( default => '&H00FFFFFF', is => 'rw' );

=attr SecondaryColour

Defaults to &H00FFFFFF
=cut

has 'SecondaryColour' => ( default => '&H000000FF', is => 'rw' );

=attr OutlineColour

Defaults to &H0027415C
=cut

has 'OutlineColour' => ( default => '&H0027415C', is => 'rw' );

=attr BackColour

Defaults to &H9027415C
=cut

has 'BackColour' => ( default => '&H9027415C', is => 'rw' );

=attr Bold

Defaults to false (0)
=cut

=attr Italic

Defaults to false (0)
=cut

=attr Underline

Defaults to false (0)
=cut

=attr StrikeOut

Defaults to false (0)
=cut

has [ 'Bold', 'Italic', 'Underline', 'StrikeOut' ] => ( default => 0, is => 'rw' );

=attr ScaleX

Defaults to 100
=cut

=attr ScaleY

Defaults to 100
=cut

has [ 'ScaleX', 'ScaleY' ] => ( default => 100, is => 'rw' );

=attr Spacing

Defaults to 0
=cut

has 'Spacing' => ( default => 0, is => 'rw' );

=attr Angle

Defaults to 0
=cut 

has 'Angle' => ( default => 0, is => 'rw' );

=attr BorderStyle

Defaults to 1
=cut

has 'BorderStyle' => ( default => 1, is => 'rw' );

=attr Outline

Defaults to 2
=cut

has 'Outline' => ( default => 2, is => 'rw' );

=attr Shadow

Defaults to 1
=cut

has 'Shadow' => ( default => 1, is => 'rw' );

=attr Alignment

Defaults to 2
=cut

has 'Alignment' => ( default => 2, is => 'rw' );

=attr MarginL

Defaults to 0
=cut

=attr MarginR

Defaults to 0
=cut

=attr MarginV

Defaults to 0
=cut

has [ 'MarginL', 'MarginR', 'MarginV' ] => ( default => 0 , is => 'rw');

=attr Encoding

Defaults to 0
=cut

has 'Encoding' => ( default => 1, is => 'rw' );

=method get_format

returns a list of the format headings in order
=cut

sub get_format {
    return [
        'Name',          'Fontname',        'Fontsize',
        'PrimaryColour', 'SecondaryColour', 'OutlineColour',
        'BackColour',    'Bold',            'Italic',
        'Underline',     'StrikeOut',       'ScaleX',
        'ScaleY',        'Spacing',         'Angle',
        'BorderStyle',   'Outline',         'Shadow',
        'Alignment',     'MarginL',         'MarginR',
        'MarginV',       'Encoding'
    ];
}

=method to_string

Returns a string representing the style
=cut

sub to_string {
    ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
    my $self = shift;
    my $ret  = 'Style: ';
    $ret .= $self->Name . ',';
    $ret .= $self->Fontname . ',';
    $ret .= $self->Fontsize . ',';
    $ret .= $self->PrimaryColour . ',';
    $ret .= $self->SecondaryColour . ',';
    $ret .= $self->OutlineColour . ',';
    $ret .= $self->BackColour . ',';
    $ret .= ( $self->Bold ? -1 : 0 ) . ',';
    $ret .= ( $self->Italic ? -1 : 0 ) . ',';
    $ret .= ( $self->Underline ? -1 : 0 ) . ',';
    $ret .= ( $self->StrikeOut ? -1 : 0 ) . ',';
    $ret .= $self->ScaleX . ',';
    $ret .= $self->ScaleY . ',';
    $ret .= $self->Spacing . ',';
    $ret .= $self->Angle . ',';
    $ret .= $self->BorderStyle . ',';
    $ret .= $self->Outline . ',';
    $ret .= $self->Shadow . ',';
    $ret .= $self->Alignment . ',';
    $ret .= $self->MarginL . ',';
    $ret .= $self->MarginR . ',';
    $ret .= $self->MarginV . ',';
    $ret .= $self->Encoding;
    return $ret;
}

=method is_equal

Returns whether another style is eqaul to the object
=cut

sub is_equal {
    my ( $self, $other_block ) = @_;
    return $self->to_string eq $other_block->to_string;
}


1;
