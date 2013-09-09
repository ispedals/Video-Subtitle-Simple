package Video::Subtitle::Simple::ASS::File;

# ABSTRACT: Video::Subtitle::Simple::File based implementation of an ASS subtitle file
# VERSION
use v5.12;

use Moo;
use MooX::HandlesVia;
use Carp;
use File::Slurp;
use Text::Trim;

use Video::Subtitle::Simple::ASS::Style;
use Video::Subtitle::Simple::ASS::Event;

=head1 SYNOPSIS


    #create Video::Subtitle::Simple::ASS::File object from a filehandle
    use Video::Subtitle::Simple::ASS::File;
    my $file_handle;
    my $file=Video::Subtitle::Simple::ASS::File->create_from_file($file_handle);

    #add events file
    $file->add_event(Format => 'Dialogue', start => 2, end => 3, Text => 'C,A');
    $file->add_dialogue(start => 30, end => 60, Text => '<Hola>', Name => 'Bill');
    $file->add_dialogue(start => "0:01:15", end => "0:01:20", Text => '<Como estas>', Name => 'Jill');
    $file->add_comment(start => 0, end => 1, Text => 'A');
    my @subs=$file->get_subtitles;

    #remove events
    $file->remove_event($_) foreach $file->get_events_by_attribute(sub{$_->Name eq 'Bill'});
    @subs=$file->get_subtitles; #file no longer contains line with name 'Bill'


    #add styles
    $file->add_style(Name => 'Note');


    #remove styles
    $file->remove_style($_) foreach $file->get_style_by_attribute(sub{$_->Name eq 'Boom'});

    #output file
    print $file->to_string;


    #convert ASS subtitle to SRT format
    use Video::Subtitle::Simple::SRT::File;
    print Video::Subtitle::Simple::SRT::File->create_from_subtitle($file)->to_string;

=head1 DESCRIPTION

B<Video::Subtitle::Simple::ASS::File> only parses three blocks, Info, Styles, and Events. The Info block is represented as a hashref, and the Style and Event
blocks are represented as an array of the corresponding object. The events do not understand any style overrides.
=cut

=attr Info

HashRef representing the info block of an ASS file. It defaults to:
    Title:untitled
    Original Script:unknown
    Collisions:Normal
    WrapStyle:0
    ScriptType:v4.00+
=cut

has 'Info' => (
    is      => 'rw',
    default => sub {
        {
            'Title'           => 'untitled',
            'Original Script' => 'unknown',
            'Collisions'      => 'Normal',
            'WrapStyle'       => '0',
            'ScriptType'      => 'v4.00+'
        };
    },
);

=attr Styles

An array containing L<Video::Subtitle::Simple::ASS::Style> objects representing the styles of the file.
=cut

has 'Styles' => (
    is          => 'rw',
    handles_via => 'Array',
    default     => sub {
        [ Video::Subtitle::Simple::ASS::Style->new( 'Name' => 'Default' ) ];
    },
    handles => {
        get_style_by_attribute => 'grep',
    },
);

=method add_style

Adds the given L<Video::Subtitle::Simple::ASS::Style> object or hash of a style to the file.
=cut

sub add_style {
    my $self = shift;
    if ( ref( $_[0] ) ) {
        push @{ $self->Styles }, $_[0];
    }
    else {
        push @{ $self->Styles }, Video::Subtitle::Simple::ASS::Style->new(@_);
    }
    return $self;
}

=method remove_style

Removes the given L<Video::Subtitle::Simple::ASS::Style> from the file
=cut

sub remove_style {
    my ( $self, $style ) = @_;
    $self->Styles( [ grep { !$_->is_equal($style) } @{ $self->Styles } ] );
    return $self;
}

=attr Events

Array containing all the events of the file as L<Video::Subtitle::Simple::ASS::Event> objects
=cut

has 'Events' => (
    is          => 'rw',
    handles_via => 'Array',
    default     => sub { [] },
    handles     => {
        get_events_by_attribute => 'grep',
    },
);

=method get_events_by_attribute

Given a subroutine, it returns a list of all L<Video::Subtitle::Simple::ASS::Event> that return a true value
=cut

=method add_event

Adds the given L<Video::Subtitle::Simple::ASS::Event> to the file
=cut

sub add_event {
    my $self = shift;
    if ( ref( $_[0] ) ) {
        push @{ $self->Events }, $_[0];
    }
    else {
        push @{ $self->Events }, Video::Subtitle::Simple::ASS::Event->new(@_);
    }
    return $self;
}

=method add_subtitle

Adds the given L<Video::Subtitle::Simple::Subtitle> consuming object to the file
=cut

sub add_subtitle {
    my $self = shift;
    if ( ref( $_[0] ) ) {
        push @{ $self->Events },
          Video::Subtitle::Simple::ASS::Event->new(
            start  => $_[0]->start,
            end    => $_[0]->end,
            Text   => $_[0]->get_text,
            Format => 'Dialogue'
          );
    }
    else {
        push @{ $self->Events },
          Video::Subtitle::Simple::ASS::Event->new( @_, Format => 'Dialogue' );
    }
    return $self;
}

with 'Video::Subtitle::Simple::File';

=method add_dialogue

Given a hash with the required fields for an L<Video::Subtitle::Simple::ASS::Event> object (start, end, text), the event will be added formatted as a dialogue
=cut

sub add_dialogue {
    my $self = shift;
    $self->add_event(
        Video::Subtitle::Simple::ASS::Event->new( @_, Format => 'Dialogue' ) );
    return $self;
}

=method add_comment

Given a hash with the required fields for an L<Video::Subtitle::Simple::ASS::Event> object (start, end, Text), the event will be added formatted as a comment
=cut

sub add_comment {
    my $self = shift;
    $self->add_event(
        Video::Subtitle::Simple::ASS::Event->new( @_, Format => 'Comment' ) );
    return $self;
}

=method remove_event

Removes any matching L<Video::Subtitle::Simple::ASS::Event> object from the file
=cut

sub remove_event {
    my ( $self, $event ) = @_;
    my @e = grep { !$_->is_equal($event) } @{ $self->Events };
    $self->Events( \@e );
    return $self;
}

=method remove_subtitle

Removes any matching L<Video::Subtitle::Simple::Subtitle> consuming object from the file
=cut

sub remove_subtitle {
    my ( $self, $subtitle ) = @_;
    my $params = {
        start  => $subtitle->start,
        end    => $subtitle->end,
        Text   => $subtitle->get_text,
        Format => 'Dialogue'
    };
    $self->remove_event( Video::Subtitle::Simple::ASS::Event->new($params) );
    return $self;
}

=method get_subtitles

Returns a list of Dialogue events in chronological order. Note that directly accessing C<Events> would give both Dialogue and Comment
events and the order of the resulting list is not given.
=cut

sub get_subtitles {
    my $self = shift;
    my @ret =
      sort { $a->start->as_seconds <=> $b->start->as_seconds }
      grep { $_->Format eq 'Dialogue' } @{ $self->Events };
    return @ret;
}

=method to_string

Returns the ASS file as a string
=cut

sub to_string {
    my $self      = shift;
    my $ret       = "[Script Info]\n";
    my @info_keys = ( 'Title', 'Original Script', 'ScriptType', 'Collisions' );
    my %infos     = %{ $self->Info };
    $ret .= "$_:$infos{$_}\n" foreach @info_keys;
    delete @infos{@info_keys};
    while ( my ( $k, $v ) = each %infos ) {
        $ret .= "$k:$v\n";
    }
    $ret .= "\n";
    $ret .= "[V4+ Styles]\n";
    $ret .=
        'Format: '
      . join( ', ', @{ Video::Subtitle::Simple::ASS::Style->get_format } )
      . "\n";
    $ret .= join( "\n", map { $_->to_string } @{ $self->Styles } );
    $ret .= "\n";
    $ret .= "[Events]\n";
    $ret .=
        'Format: '
      . join( ', ', @{ Video::Subtitle::Simple::ASS::Event->get_format } )
      . "\n";
    $ret .= join( "\n", map { $_->to_string } @{ $self->Events } );
    $ret .= "\n";
    return $ret;
}

=method create_from_string

Returns a B<Video::Subtitle::Simple::ASS::File> object from the given string
=cut

sub create_from_string {
    my ( $self, $string ) = @_;
    my @lines = split /\n/, $string;
    return _create_from_array( $self, \@lines );
}

=method create_from_file

Returns a B<Video::Subtitle::Simple::ASS::File> object from a valid filename or handle
=cut

sub create_from_file {
    my ( $self, $filename ) = @_;
    my @lines = read_file($filename);
    return _create_from_array( $self, \@lines );
}

sub _create_from_array {
    my ( $self, $lines ) = @_;
    my @subs = @{$lines};

    my %blocks;

    my $line_number = 0;

    my $get_format = sub {
        my $line = shift;
        my %format;
        my ( $key, $value ) = map { trim } split /:/, $line, 2;
        croak "Expecting Format got $key" unless $key eq 'Format';
        my @tokens = map { trim } split /,/, $value;
        for my $index ( 0 .. $#tokens ) {
            $format{ $tokens[$index] } = $index;
        }
        return %format;
    };

    my $parse_line = sub {
        my ( $line, $valid_keys ) = @_;
        return
          if $line =~ /^[;!]/
          or $line !~ /:/;    #comments or does not have format
        my ( $key, $value ) = map { trim } split /:/, $line, 2;
        return if defined $valid_keys && !defined $valid_keys->{$key};
        return ( $key, $value );
    };

    my $parse_formatted_block = sub {
        my $valid_keys = shift;
        $line_number++;
        my %format = $get_format->( $subs[$line_number] );
        my @ret;
        for (
            ;
            $line_number <= $#subs and $subs[$line_number] !~ /^\[\w.*\]/ ;
            $line_number++
          )
        {
            my ( $key, $value ) =
              $parse_line->( $subs[$line_number], $valid_keys );
            next unless defined $key;
            my @tokens = map { trim } split /,/, $value, scalar keys %format;
            my %real;
            while ( my ( $field, $index ) = each %format ) {
                $real{$field} = $tokens[$index];
            }
            $real{'Format'} = $key;
            push @ret, \%real;
        }
        return @ret;
    };

    croak 'invalid ass file' unless $subs[$line_number] =~ /\[Script Info\]/;

    $blocks{'Info'} = {};

    for (
        $line_number = 1 ;
        $line_number <= $#subs and $subs[$line_number] !~ /^\[\w.*\]/ ;
        $line_number++
      )
    {
        my ( $key, $value ) = $parse_line->( $subs[$line_number] );
        next unless defined $key;
        $blocks{'Info'}{$key} = $value;
    }

    my $handler = {
        'V4+ Styles' => sub {
            my $hashes = [ $parse_formatted_block->( { 'Style' => 1 } ) ];
            delete $hashes->[$_]{'Format'} for ( 0 .. scalar @{$hashes} - 1 );
            push @{ $blocks{'Styles'} },
              Video::Subtitle::Simple::ASS::Style->new(%$_)
              for @$hashes;
        },
        'Events' => sub {
            my $hashes =
              [ $parse_formatted_block->( { 'Comment' => 1, 'Dialogue' => 1 } )
              ];
            my %key_mappings =
              ( Start => 'start', End => 'end', text => 'Text' );
            for ( 0 .. scalar @{$hashes} - 1 ) {
                while ( my ( $bad_key, $good_key ) = each %key_mappings ) {
                    $hashes->[$_]{$good_key} = $hashes->[$_]{$bad_key}
                      if defined $hashes->[$_]{$bad_key};
                }
                delete @{ $hashes->[$_] }{ keys %key_mappings };
            }
            push @{ $blocks{'Events'} },
              Video::Subtitle::Simple::ASS::Event->new(%$_)
              for @$hashes;
          }
    };

    while ( $line_number < $#subs ) {
        if ( $subs[$line_number] =~ /\[(\w.*)\]/ and defined $handler->{$1} ) {
            &{ $handler->{$1} };
        }
        else {
            for (
                ;
                $line_number < $#subs and $subs[$line_number] !~ /^\[\w.*\]/ ;
                $line_number++
              )
            {
            }
        }
    }
    return $self->new(%blocks);
}

=method hash_code

Returns a string hash code of the object.
Note that this is sensative to whitespace and formatting differences in the lines and the ordering of lines.
This means that if a subtitle file contains lines with the same start and end times, different hash codes returned could be returned
depending on how the lines are sorted
=cut

=method is_equal

Returns whether the given Subtitle::File object is equal to the object. The same caveats apply as in C<hash_code>
=cut

=method create_from_subtitle

Creates a L<Video::Subtitle::Simple::File> object from the given L<Video::Subtitle::Simple::File> object.
This is useful if one wants to convert an object into another subtitle format. However, there is no expectation that any formatting markup will
be preserved during the conversion.
=cut

1;
