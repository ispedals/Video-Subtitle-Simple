package Video::Subtitle::OO::SRT::File;
# ABSTRACT: Representation of a Subrip file that implements Video::Subtitle::OO::File
# VERSION
use v5.12;
use strict;
use warnings;

use Moo;
use MooX::HandlesVia;
use File::Slurp;
use Video::Subtitle::OO::SRT::Subtitle;

=head1 SYNOPSIS

    use Video::Subtitle::OO::SRT::File;

    my $srt = Video::Subtitle::OO::SRT::File->create_from_file('example.srt');
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
    use Video::Subtitle::OO::ASS::File;
    my $file;
    print Video::Subtitle::OO::ASS::File->create_from_subtitle($file)->to_string;
    
    
=head1 DESCRIPTION

B<Video::Subtitle::OO::SRT::File> consumes L<Video::Subtitle::OO::File> for the Subrip(srt) file format. It does not understand any formatting markup, which means that if any 
markup is present in a subtitle line, it will be treated as plain text. This module only understands the multi-line subrip format, which is: 

	index_number
	hh:mm:ss,msmsms --> hh:mm:ss,msmsms
	Text
	Text
	...

The single-line format will not be parsed or outputted.

By being a consumer of L<Video::Subtitle::OO::File>, this module has the following constructors:

=for :list
* create_from_file
* create_from_string
* create_from_subtitle

=cut

# unimplement for now
# coerce 'Subtitles::SRT::Subtitle' => from
  # 'HashRef' => via { Subtitles::SRT::Subtitle->new( %{$_} ) },
  # => from 'Subtitles::Subtitle',
  # => via {
    # $_->isa('Subtitles::SRT::Subtitle') ? $_ : Subtitles::SRT::Subtitle->new(
        # start => $_->start,
        # end   => $_->end,
        # text  => $_->get_text
    # );
  # };

# subtype 'CollectionofSRT' => as 'ArrayRef[Subtitles::SRT::Subtitle]';

# coerce 'CollectionofSRT' => from 'HashRef' =>
  # via { [ Subtitles::SRT::Subtitle->new( %{$_} ) ] };

# coerce 'CollectionofSRT' => from 'Subtitles::SRT::Subtitle' => via { [$_] };

# coerce 'CollectionofSRT' => from 'ArrayRef[HashRef]' => via {
    # [ map { Subtitles::SRT::Subtitle->new( %{$_} ) } @{$_} ];
# };

=attr subtitles

This is an array containing the L<Video::Subtitle::OO::SRT::Subtitle> lines that make up the file. While it can be accessed directly
there is no guarantee that the lines will be in chronological order that C<get_subtitles> makes.
=cut

has 'subtitles' => (
    is      => 'rw',
    handles_via => 'Array',
    default => sub { return [] },
    handles => {
        get_subtitles_by_attribute => 'grep',
#        add_subtitle               => 'push'
    },
);

sub add_subtitle {
	my($self, $subtitle) = @_;
	if(ref($subtitle) eq 'HASH') {
		push @{$self->subtitles}, Video::Subtitle::OO::SRT::Subtitle->new(%$subtitle);
	}
	else {
		push @{$self->subtitles}, Video::Subtitle::OO::SRT::Subtitle->new(
			start => $subtitle->start,
			end => $subtitle->end,
			text => $subtitle->get_text
		);
	}
	return $self;
}

with 'Video::Subtitle::OO::File';

=method add_subtitle

Adds a subtitle to subtitles, parameter can be either a hashref of the required fields or a L<Video::Subtitle::OO::Subtitle> implementing object
=cut

=method get_subtitles_by_attribute

Given a subroutine, an array of L<Video::Subtitle::OO::SRT::Subtitle> will be returned that match
=cut

=method remove_subtitle

Removes all subtitles that is equal to the given L<Video::Subtitle::OO::Subtitle> implementing object

	returns self
=cut

sub remove_subtitle {
    my ( $self, $subtitle ) = @_;
    $subtitle = Video::Subtitle::OO::SRT::Subtitle->new(
        start => $subtitle->start,
        end   => $subtitle->end,
        text  => $subtitle->get_text
    );
    @{ $self->subtitles } =
      grep { !$_->is_equal($subtitle) } @{ $self->subtitles };
    return $self;
}

=method get_subtitles

Returns an array of L<Video::Subtitle::OO::SRT::Subtitle>s in chronological order, note that the C<subtitles> atttribute makes no such assumptions
=cut

sub get_subtitles {
    my $self = shift;
    my @out =
      sort { $a->start->second <=> $b->start->second } @{ $self->subtitles };
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

Returns a B<Video::Subtitle::OO::SRT::File> object from a string
=cut

sub create_from_string {
    my ( $self, $string ) = @_;
    my @subtitles;
    while ( $string =~
m/(?<sequence>\d*)(?:\s*)?\n(?<start>(?<shour>\d|\d\d):(?<sminute>\d\d):(?<ssecond>\d\d|(?:\d\d[.,]\d{1,3}))) --> (?<end>(?<ehour>\d|\d\d):(?<eminute>\d\d):(?<esecond>\d\d|(?:\d\d[.,]\d{1,3})))(?:\s*)?\n(?<text>.*?)(?:\n\n|\n$|$)/sg
      )
    {
		push @subtitles, Video::Subtitle::OO::SRT::Subtitle->new(%+);
    }
    return $self->new( subtitles => \@subtitles );
}

=method create_from_file

Returns a B<Video::Subtitle::OO::SRT::File> from either a file handle or a valid filename
=cut

sub create_from_file {
    my ( $self, $filename ) = @_;
    my $s = read_file($filename);
    return $self->create_from_string($s);
}

=method create_from_subtitle

Returns a B<Video::Subtitle::OO::SRT::File> object from the given L<Video::Subtitle::OO::File> consuming object.
=cut

=method hash_code

Returns a string hash code of the object. 
Note that this is sensative to whitespace and formatting differences in the lines and the ordering of lines.
This means that if a subtitle file contains lines with the same start and end times, different hash codes returned could be returned
depending on how the lines are sorted
=cut

=method is_equal

Returns whether the given L<Video::Subtitle::OO::File> consuming object is equal to the object. The same caveats apply as in C<hash_code>
=cut

1;
