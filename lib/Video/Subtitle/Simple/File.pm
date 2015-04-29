package Video::Subtitle::Simple::File;

# ABSTRACT: Role for a subtitle file
# VERSION
use v5.16;
use strict;
use warnings;

use Moo::Role;
use Digest::MD5;

=head1 DESCRIPTION

B<Video::Subtitle::Simple::File> was created to provide a consistant interface for manipulating subtitle files regardless of format. 
The interface was designed under the assumption that a subtitle file can be represented as a container which contains multiple subtitle lines. 

Modules wanting to be subtitle files must implement the required methods:

=head2 Constructors

=head3 create_from_file

Given a a string filename or a open filehandle, return a B<Video::Subtitle::Simple::File> consuming object the represents a given subtitle file. When given a
string filename, it should be assumed that the file to be accessed using the filename is utf8 encoded. When given a filehandle, it should be assumed
that the proper encoding layer was used during the filehandle's creation.

=head3 create_from_string

Given a string representation of a subtitle file, return a B<Video::Subtitle::Simple::File> consuming object the represents a given subtitle file. It should be
assumed that the string has been properly decoded.

=head2 Methods

=for :list
* C<to_string>: the string representation of the file that could be used in playback

Because of the different representations of storing subtitles, the following accessors are required:

=for :list
* C<get_subtitles>: returns an array of L<Video::Subtitle::Simple::Subtitle> implementing objects in chronological order
* C<add_subtitle>, C<remove_subtitle>: add or remove subtitle objects implementing L<Video::Subtitle::Simple::Subtitle> such that they will be included in the C<to_string> representation

Sucessful implementions recieve the constructor C<create_from_subtitle> and the C<is_equal> and C<hash_code> methods.

=cut

requires 'create_from_file', 'create_from_string',
  'to_string', 'get_subtitles', 'add_subtitle', 'remove_subtitle';

=method create_from_subtitle

Returns a L<Video::Subtitle::Simple::File> consuming object from the given L<Video::Subtitle::Simple::File> object.
This is useful if one wants to convert an object into another subtitle format. However, there is no expectation that any formatting markup will
be preserved during the conversion.

=cut

sub create_from_subtitle {
    my ( $self, $file ) = @_;
    my $s = $self->new();
    $s->add_subtitle($_) foreach $file->get_subtitles();
    return $s;
}

=method hash_code

Returns a string hash code of the object.
Note that this is sensative to whitespace and formatting differences in the lines and the ordering of lines.
This means that if a subtitle file contains lines with the same start and end times, different hash codes returned could be returned
depending on how the lines are sorted

=cut

sub hash_code {
    my $self = shift;
    my $md5  = Digest::MD5->new;
    $md5->add( $_->hash_code ) foreach $self->get_subtitles();
    return $md5->hexdigest;
}

=method is_equal

Returns whether the given L<Video::Subtitle::Role::Subtitle> consuming object is equal to the object. The same caveats apply as in C<hash_code>
=cut

sub is_equal {
    my ( $self, $other_file ) = @_;
    return $self->hash_code eq $other_file->hash_code;
}

1;
