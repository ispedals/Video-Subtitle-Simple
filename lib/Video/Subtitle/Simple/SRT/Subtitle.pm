package Video::Subtitle::Simple::SRT::Subtitle;

# ABSTRACT: Representation of a Subrip subtitle that implements Video::Subtitle::Simple::Subtitle
# VERSION
use v5.16;
use strict;
use warnings;

use Moo;

=head1 SYNOPSIS

    use Video::Subtitle::Simple::SRT::Subtitle;

    my $line = Video::Subtitle::Simple::SRT::Subtitle->new(start => 2, end => 3, text => 'Test');
    print $line->to_string;

    #0:00:02,000 --> 0:00:03,000
    #Test

=head1 DESCRIPTION

B<Video::Subtitle::Simple::SRT::Subtitle> represent a Subrip subtitle line that consumes the L<Video::Subtitle::Simple::Subtitle> role.
It does not understand any markup, and therefore it will not be stripped by get_text. This module follows the multi-line Subrip format.
The constructor expects a hash with the fields: C<start>, C<end>, and C<text>. If C<text> is not supplied, a blank string will be assumed.
=cut

has 'text' => (
    is      => 'rw',
    default => sub { return '' },
    reader  => 'get_text',
    writer  => 'set_text',
);

=method get_text

Returns the text of the line. Note that L<Video::Subtitle::Simple::Subtitle> requires that all formatting be removed, but because this module does not
understand formatting, if any formatting is present, it will be treated as plain text and returned as is
=cut

=method set_text

Sets the text of the line.

Returns the object

=cut

around 'set_text' => sub {
    my $org  = shift;
    my $self = shift;

    return $self->$org() unless @_;

    my $new = shift;
    chomp $new;
    return $self->$org($new);
};

=attr start

A L<Video::Subtitle::Simple::Time> object representing the start time of the line. This attribute must be specified during construction.
Both a L<Video::Subtitle::Simple::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.
=cut

=attr end

A L<Video::Subtitle::Simple::Time> object representing the end time of the line. This attribute must be specified during construction.
Both a L<Video::Subtitle::Simple::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.
=cut

=method to_string

returns a string representation of the line of the form

    hh:mm:ss,sss --> hh:mm:ss,sss
    Text

=cut

sub to_string {
    my $self = shift;
    my $ret =
        $self->start->as_subrip_string . ' --> '
      . $self->end->as_subrip_string . "\n";
    $ret .= $self->get_text . "\n";
    return $ret;
}

with 'Video::Subtitle::Simple::Subtitle';

=method duration

Returns a L<Video::Subtitle::Simple::Time> object representing the duration of the subtitle line
=cut

=method hash_code

Returns a string hash code of the subtitle. Note that differences in whitespace and formating will result in a different hash code
=cut

=method is_equal

Returns true if two subtitles are equal. Two subtitles are equal if their hash codes are equal. Throws an exception on error.
=cut

1;
