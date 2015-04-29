package Video::Subtitle::Simple::SRT::File;

# ABSTRACT: Representation of a Subrip file that implements Video::Subtitle::Simple::File
# VERSION
use v5.16;
use strict;
use warnings;

use Moo;
use MooX::HandlesVia;
use File::Slurp;
use Carp;
use Video::Subtitle::Simple::SRT::Subtitle;

=head1 SYNOPSIS

    use Video::Subtitle::Simple::SRT::File;

    my $srt = Video::Subtitle::Simple::SRT::File->create_from_file('example.srt');
    $srt->to_string;

    #1
    #0:00:01,000 --> 0:00:02,000
    #Test

    $srt->add_subtitle(start => '0:00:02,000', end => '0:00:02,500', text => '123');
    $srt->to_string;

    #1
    #0:00:01,000 --> 0:00:02,000
    #Test
    #
    #2
    #0:00:02,000 --> 0:00:02,500
    #123


    #convert SRT subtitle to ASS format
    use Video::Subtitle::Simple::ASS::File;
    my $file;
    print Video::Subtitle::Simple::ASS::File->create_from_subtitle($file)->to_string;


=head1 DESCRIPTION

B<Video::Subtitle::Simple::SRT::File> consumes L<Video::Subtitle::Simple::File> for the Subrip(srt) file format. It does not understand any formatting markup, which means that if any
markup is present in a subtitle line, it will be treated as plain text. This module only understands the multi-line subrip format, which is:

    index_number
    hh:mm:ss,msmsms --> hh:mm:ss,msmsms
    Text
    Text
    ...

The single-line format will not be parsed or outputted.

By being a consumer of L<Video::Subtitle::Simple::File>, this module has the following constructors:

=for :list
* create_from_file
* create_from_string
* create_from_subtitle

=cut

=attr subtitles

This is an array containing the L<Video::Subtitle::Simple::SRT::Subtitle> lines that make up the file. While it can be accessed directly
there is no guarantee that the lines will be in chronological order that C<get_subtitles> ensures.
=cut

has 'subtitles' => (
    is          => 'rw',
    handles_via => 'Array',
    default     => sub { return [] },
    handles     => {
        get_subtitles_by_attribute => 'grep',
    },
);

sub add_subtitle {
    my $self = shift @_;
    if ( scalar @_ > 1 ) {
        push @{ $self->subtitles },
          Video::Subtitle::Simple::SRT::Subtitle->new(@_);
        return $self;
    }

    my $subtitle = shift @_;
    if ( $subtitle->DOES('Video::Subtitle::Simple::Subtitle') ) {
        push @{ $self->subtitles },
          Video::Subtitle::Simple::SRT::Subtitle->new(
            start => $subtitle->start,
            end   => $subtitle->end,
            text  => $subtitle->get_text
          );
    }
    elsif ( ref($subtitle) eq 'HASH' ) {
        push @{ $self->subtitles },
          Video::Subtitle::Simple::SRT::Subtitle->new(%$subtitle);
    }
    else {
        Carp::croak('invalid argument');
    }
    return $self;
}

with 'Video::Subtitle::Simple::File';

=method add_subtitle

Adds a subtitle to subtitles, parameter can be a hashref or hash of the required fields or a L<Video::Subtitle::Simple::Subtitle> implementing object. Throws exception on error.
=cut

=method get_subtitles_by_attribute

Given a subroutine, a list of L<Video::Subtitle::Simple::SRT::Subtitle> will be returned that match
=cut

=method remove_subtitle

Removes all subtitles that is equal to the given L<Video::Subtitle::Simple::Subtitle> implementing object. Throws exception on error.

    returns self
=cut

sub remove_subtitle {
    my ( $self, $subtitle ) = @_;
    Carp::croak('was not a Video::Subtitle::Simple::Subtitle object')
      unless $subtitle->DOES('Video::Subtitle::Simple::Subtitle');
    $subtitle = Video::Subtitle::Simple::SRT::Subtitle->new(
        start => $subtitle->start,
        end   => $subtitle->end,
        text  => $subtitle->get_text
    );
    @{ $self->subtitles } =
      grep { !$_->is_equal($subtitle) } @{ $self->subtitles };
    return $self;
}

=method get_subtitles

Returns an array of L<Video::Subtitle::Simple::SRT::Subtitle>s in chronological order, note that the C<subtitles> atttribute makes no such assumptions
=cut

sub get_subtitles {
    my $self = shift;
    my @out =
      sort { $a->start->as_seconds <=> $b->start->as_seconds }
      @{ $self->subtitles };
    return @out;
}

=method to_string

Returns a string representation of a Subrip file, defined as:

    index_number
    hh:mm:ss,msmsms --> hh:mm:ss,msmsms
    Text
    Text
    ...

=cut

sub to_string {
    my $self = shift;
    my $ret;
    my @subtitles = $self->get_subtitles;
    for my $index ( 0 .. $#subtitles ) {
        $ret .= ( $index + 1 ) . "\n";
        $ret .= $subtitles[$index]->to_string . "\n";
    }
    chomp $ret if $ret;
    return $ret;
}

=method create_from_string

Returns a B<Video::Subtitle::Simple::SRT::File> object from a string
=cut

sub create_from_string {
    my ( $self, $string ) = @_;
    my @subtitles;
    while ( $string =~
m/(?<sequence>\d*)(?:\s*)?\n(?<start>(?<shour>\d|\d\d):(?<sminute>\d\d):(?<ssecond>\d\d|(?:\d\d[.,]\d{1,3}))) --> (?<end>(?<ehour>\d|\d\d):(?<eminute>\d\d):(?<esecond>\d\d|(?:\d\d[.,]\d{1,3})))(?:\s*)?\n(?<text>.*?)(?:\n\n|\n$|$)/sg
      )
    {
        push @subtitles, Video::Subtitle::Simple::SRT::Subtitle->new(%+);
    }
    return $self->new( subtitles => \@subtitles );
}

=method create_from_file

Returns a B<Video::Subtitle::Simple::SRT::File> from either a file handle or a valid filename
=cut

sub create_from_file {
    my ( $self, $filename ) = @_;
    my $s = read_file($filename);
    return $self->create_from_string($s);
}

=method create_from_subtitle

Returns a B<Video::Subtitle::Simple::SRT::File> object from the given L<Video::Subtitle::Simple::File> consuming object.
=cut

=method hash_code

Returns a string hash code of the object.
Note that this is sensative to whitespace and formatting differences in the lines and the ordering of lines.
This means that if a subtitle file contains lines with the same start and end times, different hash codes returned could be returned
depending on how the lines are sorted
=cut

=method is_equal

Returns whether the given L<Video::Subtitle::Simple::File> consuming object is equal to the object. The same caveats apply as in C<hash_code>
=cut

1;
