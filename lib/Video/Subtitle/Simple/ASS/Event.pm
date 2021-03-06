package Video::Subtitle::Simple::ASS::Event;

# ABSTRACT: Representation of an ASS event
# VERSION
use v5.16;
use strict;
use warnings;

use Moo;
use Carp;

=head1 SYNOPSIS

    use Video::Subtitle::Simple::ASS::Event;
    my $event=Video::Subtitle::Simple::ASS::Event->new(Format => 'Dialogue', start => 2, end => 3);
    print $event->to_string;
    #Dialogue: 0,0:00:02.000,0:00:03.000,Default,,0000,0000,0000,,

=head1 DESCRIPTION

B<Video::Subtitle::Simple::ASS::Event> represents an ASS event using L<Video::Subtitle::Simple::Subtitle>. It can only handle Comment and Dialouge events. It also does not support any
block leveling styling nor does it allow for programtic interaction with style overrides.

There is an alias L<Video::Subtitle::Simple::ASS::Subtitle>.
=cut

=attr Layer

An integer representing the layer of the events. It defaults to 0.
=cut

has 'Layer' => (
    is      => 'rw',
    default => 0,
);

=attr Format

A string representing format of the event. The only recognized formats are Comment and Dialogue. Comments are not displayed during playback.
This is required to be set during construction.
=cut

has 'Format' => (
    is       => 'rw',
    required => 1,
);

=attr Style

The string name of the style associated with the event. It defaults to Default.
=cut

has 'Style' => (
    is      => 'rw',
    default => 'Default',
);

=attr Name

The string name of the event. It defaults to ''.
=cut

has 'Name' => (
    is      => 'rw',
    default => sub { return '' },
);

=attr MarginL

The left margin in number. It defaults to 0.
=cut

=attr MarginR

The right margin in number. It defaults to 0.
=cut

=attr MarginV

The vertical margin in number. It defaults to 0.
=cut

has [ 'MarginL', 'MarginR', 'MarginV' ] => (
    is      => 'rw',
    default => '0000',
);

=attr Effect

The effect applied to the event. It defaults to nothing.
=cut

has 'Effect' => (
    is      => 'rw',
    default => sub { return '' },
);

=attr Text

The text of the event
=cut

has 'Text' => (
    is      => 'rw',
    default => sub { return '' },
    writer  => 'set_text',
    reader  => 'get_formatted_text',
);

=method get_text

Returns the text of the event with all overrides removed. It keeps any whitespace formatting though (\n, \N)
=cut

sub get_text {
    my $self = shift;
    my $text = $self->get_formatted_text;
    $text =~ s/{.*?}//g;
    $text =~ s/\\N/\n/g;
    $text =~ s/(?: )?\\\s(?: )?/  /g;
    return $text;
}

=method get_formatted_text

Returns the text of the event as is.
=cut

=method set_text

Sets the text of the event
=cut

with 'Video::Subtitle::Simple::Subtitle';

=method get_format

Returns an array with the fields of the event contained in the order they are printed
=cut

sub get_format {
    return [
        'Layer',   'Start',   'End',     'Style',  'Name',
        'MarginL', 'MarginR', 'MarginV', 'Effect', 'Text'
    ];
}

=method to_string

Returns a valid ASS-formatted line as a string of the object
=cut

sub to_string {
    my $self = shift;
    my $ret  = $self->Format . ': ';
    $ret .= $self->Layer . ',';
    $ret .= $self->start->as_string . ',';
    $ret .= $self->end->as_string . ',';
    $ret .= $self->Style . ',';
    $ret .= $self->Name . ',';
    $ret .= $self->MarginL . ',';
    $ret .= $self->MarginR . ',';
    $ret .= $self->MarginV . ',';
    $ret .= $self->Effect . ',';
    $ret .= $self->get_formatted_text;
    return $ret;
}

=method is_equal

Returns whether another event is equal to the object. Throws exception on error.
=cut

sub is_equal {
    my ( $self, $other_block ) = @_;
    Carp::croak('was not a Video::Subtitle::Simple::ASS::Event object')
      unless $other_block->isa('Video::Subtitle::Simple::ASS::Event');
    return $self->to_string eq $other_block->to_string;
}

1;
