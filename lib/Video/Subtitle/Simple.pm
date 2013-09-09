package Video::Subtitle::Simple;
# ABSTRACT: Roles for defining a subtitle format
# VERSION

=head1 DESCRIPTION

B<Video::Subtitle::Simple> provides a set of roles, L<Video::Subtitle::Simple::File> and L<Video::Subtitle::Simple::Subtitle>, that
are intended to provide a clean interface for creating and manipulating subtitles in a format-agnostic manner.

=head2 Assumptions

B<Video::Subtitle::Simple> assumes many things that are not true about many subtitle formats. Therefore, some subtitle formats
may not be accuretly represented by the given interface, but it is hoped that the provided interface is sufficently useful
at the expense of some loss of information.

B<Video::Subtitle::Simple> assumes that a subtitle file can be represented as container that
holds an array of subtitle lines. This means that any metadata contained about the file itself, such as intended aspect ratio, global styling information
or comments, are not exposed through this interface and therefore may be not be preserved during manipulation. It is assumed that a subtitle file
can be created from a string representation of the file and that the file itself can be serialized as a string. Modules representing subtitle files
should consume L<Video::Subtitle::Simple::File>.

B<Video::Subtitle::Simple> assumes that a subtitle line can be represented as a struct-like object that has an explict non-negative start and end time, 
and some text. This may conflict with certain subtitle formats in which each line only has a specified start time and an implicit end time. It is 
assumed that the text component may have some formatting markup, but that this markup can be removed. Modules representing subtitle lines should consume
L<Video::Subtitle::Simple::Subtitle>.

One of the primary motivations for B<Video::Subtitle::Simple> was to allow the interconversion between subtitle formats. Because of the assumptions of the roles,
interconversion will result in the loss of all formatting data and associated metadata.

=cut

1;

