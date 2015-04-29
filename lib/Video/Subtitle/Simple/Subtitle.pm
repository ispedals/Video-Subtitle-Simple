package Video::Subtitle::Simple::Subtitle;

# ABSTRACT: Role representing a subtitle line
# VERSION
use v5.16;
use strict;
use warnings;

use Carp;
use Moo::Role;
use Sub::Quote;
use Scalar::Util qw(blessed looks_like_number);
use Video::Subtitle::Simple::Time;
use Digest::MD5 qw(md5_hex);

=head1 DESCRIPTION

B<Video::Subtitle::Simple::Subtitle> was designed under the assumption that a subtitle line has a start and end time that can be represented in seconds elapsed, and a 
textual component that may contain format-specfic markup. It is also assumed that a subtitle line is not dependant on other lines for its state
and the start time of a line cannot be greater than the end time.

Module wanting to be subtitle lines appropriate for L<Video::Subtitle::Simple::File> implementors must implement:

=for :list
* C<get_text>: returns only the text component of the subtitle line with all formatting removed
* C<set_text>: sets the text component of the subtitle line
* C<to_string>: returns the subtitle line with time and text as a string. The format of of the string may be format-specific

Implementors recieve the C<is_equal> and C<hash_code> methods. These methods are sensative to whitespace changes.

=cut

requires 'get_text', 'to_string', 'set_text';

=attr start

A L<Video::Subtitle::Simple::Time> object representing the start time of the line. This attribute must be specified during construction. 
Both a L<Video::Subtitle::Simple::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.

=cut

=attr end

A L<Video::Subtitle::Simple::Time> object representing the end time of the line. This attribute must be specified during construction. 
Both a L<Video::Subtitle::Simple::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.

=cut

has 'start' => (
    'is'       => 'rw',
    'required' => 1,
    'coerce'   => sub {
        if ( looks_like_number $_[0] ) {
            return Video::Subtitle::Simple::Time->from_seconds( $_[0] );
        }
        elsif ( blessed $_[0]
            and blessed $_[0] eq 'Video::Subtitle::Simple::Time' )
        {
            return $_[0];
        }
        return Video::Subtitle::Simple::Time->from_string( $_[0] );
    }
);

has 'end' => (
    'is'       => 'rw',
    'required' => 1,
    'coerce'   => sub {
        if ( looks_like_number $_[0] ) {
            return Video::Subtitle::Simple::Time->from_seconds( $_[0] );
        }
        elsif ( blessed $_[0]
            and blessed $_[0] eq 'Video::Subtitle::Simple::Time' )
        {
            return $_[0];
        }
        return Video::Subtitle::Simple::Time->from_string( $_[0] );
    }
);

after [ 'start', 'end' ] => sub {
    my ( $self, $value ) = @_;
    return unless $value;
    Carp::croak('attempted to have start time greater than end time')
      if $self->start->as_seconds > $self->end->as_seconds;
};

=method duration

Returns a L<Video::Subtitle::Simple::Time> object representing the duration of the subtitle line

=cut

sub duration {
    my $self = shift;
    return Video::Subtitle::Simple::Time->new(
        second => $self->end->as_seconds - $self->start->as_seconds );
}

=method hash_code

Returns a string hash code of the subtitle. Note that differences in whitespace and formating will result in a different hash code

=cut

sub hash_code {
    my $self = shift;
    return md5_hex(
        $self->start->as_seconds,
        $self->end->as_seconds,
        $self->get_text
    );
}

=method is_equal

Returns true if two subtitles are equal. Two subtitles are equal if their hash codes are equal. Throws an exception on error.

=cut

sub is_equal {
    my ( $self, $other_line ) = @_;
    Carp::croak('was not a Video::Subtitle::Simple::Subtitle object')
      unless $other_line->DOES('Video::Subtitle::Simple::Subtitle');
    return $self->hash_code eq $other_line->hash_code;
}

1;
