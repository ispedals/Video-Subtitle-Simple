package Video::Subtitle::OO::Subtitle;

# ABSTRACT: Role representing a subtitle line
use v5.10;
use strict;
use warnings;

use Carp;
use Moo::Role;
use Sub::Quote;
use Scalar::Util qw(blessed looks_like_number);
use Video::Subtitle::Time;
use Digest::MD5 qw(md5_hex);
use Encode qw(encode_utf8);

=head1 DESCRIPTION

The interface was designed under the assumption that a subtitle line has a start and end time that can be represented in seconds elapsed, and a 
textualcomponent that contains format-specfic markup. It is also assumed that a subtitle line is not dependant on other lines for its state
and the start time of a line cannot be greater than the end time.

Module wanting to be subtitle lines appropriate for L<Video::Subtitle::OO::File> implementors must implement:

=for :list
* C<get_text>: returns only the text component of the subtitle line with all formatting removed
* C<set_text>: sets the text component of the subtitle line
* C<to_string>: returns the subtitle line with time and text as a string. The format of of the string may be format-specific

Implementors recieve the C<is_equal> and C<hash_code> methods. These methods are sensative to whitespace changes.

=cut

requires 'get_text', 'to_string', 'set_text';

=attr start

A L<Video::Subtitle::Time> object representing the start time of the line. This attribute must be specified during construction. 
Both a L<Video::Subtitle::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.

=cut

=attr end

A L<Video::Subtitle::Time> object representing the end time of the line. This attribute must be specified during construction. 
Both a L<Video::Subtitle::Time> suitable string timestamp or a number representing the time in seconds may be used to set the value.

=cut

has 'start' => ( 
	'is' => 'rw',
	'required' => 1,
	'coerce' => sub{ 
		if(looks_like_number $_[0]) {
			return Video::Subtitle::Time->new( second => $_[0] );
		}
		elsif(blessed $_[0] and blessed $_[0] eq 'Video::Subtitle::Time') {
			return $_[0]; 
		}
		return Video::Subtitle::Time->from_string( $_[0] );
	}
);

has 'end' => ( 
	'is' => 'rw',
	'required' => 1,
	'coerce' => sub{ 
		if(looks_like_number $_[0]) {
			return Video::Subtitle::Time->new( second => $_[0] );
		}
		elsif(blessed $_[0] and blessed $_[0] eq 'Video::Subtitle::Time') {
			return $_[0];
		}
		return Video::Subtitle::Time->from_string( $_[0] );
	}
);

after [ 'start', 'end' ] => sub {
    my ( $self, $value ) = @_;
    return unless $value;
    croak 'attempted to have start time greater than end time'
      if $self->start->second > $self->end->second;
};

=method duration

Returns a L<Video::Subtitle::Time> object representing the duration of the subtitle line

=cut

sub duration {
    my $self = shift;
    return Video::Subtitle::Time->new(
        second => $self->end->second - $self->start->second );
}

=method hash_code

Returns a string hash code of the subtitle. Note that differences in whitespace and formating will result in a different hash code

=cut

sub hash_code {
    my $self = shift;
    return md5_hex( $self->start->second, $self->end->second,
        encode_utf8( $self->get_text ) );
}

=method is_equal

Returns true if two subtitles are equal. Two subtitles are equal if their hash codes are equal

=cut

sub is_equal {
    my ( $self, $other_line ) = @_;
    return $self->hash_code eq $other_line->hash_code;
}

1;
