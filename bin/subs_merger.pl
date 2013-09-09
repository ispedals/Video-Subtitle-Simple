## no critic
# PODNAME: subs_merger
# ABSTRACT:  Merges subtitle lines together
# VERSION
use v5.12;
use strict;
use warnings;

binmode( STDOUT, ":encoding(utf8)" );

use Video::Subtitle::Simple::ASS::File;
use Video::Subtitle::Simple::ASS::Subtitle;
use Video::Subtitle::Simple::SRT::File;
use Video::Subtitle::Simple::SRT::Subtitle;

use Getopt::Long;
use Pod::Usage;

use File::Slurp;

my $man  = 0;
my $help = 0;
my $input_format;
my $max_duration;
my $encoding;
GetOptions(
    'help|?'         => \$help,
    man              => \$man,
    'input-format=s' => \$input_format,
    'duration=f'     => \$max_duration,
    'encodings=s'    => \$encoding,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

$encoding //= 'utf8';

my $input_file;
if ( @ARGV == 0 && !-t STDIN ) {
    $input_file = read_file( \*STDIN );
}
elsif ( @ARGV == 0 ) {
    pod2usage("$0: No subtitle filename given.");
}
else {
    die "Invalid filename $ARGV[0]" unless -e $ARGV[0];
    $input_file = do {
        local $/;
        open( my $fh, "<:encoding($encoding)", $ARGV[0] )
          or die "could not open $ARGV[0]: $!\n";
        <$fh>;
    };
}

my %formats = ( ASS => 'SRT', SRT => 'ASS' );
$input_format = uc $input_format;

no strict 'refs';
my $file = ( 'Video::Subtitle::Simple::' . $formats{$input_format} . '::File' )
  ->create_from_string($input_file);

my @hugeset;    #is a list containing a list of subtitles that need to be merged

my @subtitles = $file->get_subtitles;

my $last_sub = shift @subtitles;
my @subs     = ($last_sub);                       #temp list to hold subtitles
my $duration = $last_sub->duration->as_seconds;

foreach (@subtitles) {
    if ( $duration < $max_duration
        && ( $_->start->as_seconds - $last_sub->end->as_seconds ) <
        $max_duration )
    {
        push @subs, $_;
        $duration += $_->duration->as_seconds;
        $last_sub = $_;
    }
    else {
        push @hugeset, [@subs];
        @subs     = ($_);
        $duration = $_->duration->as_seconds;
        $last_sub = $_;
    }
}

$file =
  ( 'Video::Subtitle::Simple::' . $formats{$input_format} . '::File' )->new;

foreach (@hugeset) {
    my $line =
      ( 'Video::Subtitle::Simple::' . $formats{$input_format} . '::Subtitle' )
      ->(
        start => $_->[0]->start->as_string,
        end   => $_->[-1]->end->as_string
      );
    my $text = q{};
    foreach my $l ( @{$_} ) {
        $text .= $l->get_text . "\n";
    }
    $line->set_text($text);
    $file->add_subtitle($line);
}

say $file->to_string;

=head1 SYNOPSIS

subs_merger.pl [options] [file]


Options:
    -help brief help message
    -man full documentation
    -input-format format of the original subtitle; either 'ass' or 'srt'
    -duration the maximum duration of a line
    -encoding the format the subtite is encoded in; default is utf8

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-input-format>

the format of the original subtitle; either 'ass' or 'srt'

=item B<-duration>

the maximum duration of a line

=item B<-encoding>

the format the subtite is encoded in. See L<Encode::Supported> for valid values. Default is utf8

=back

=head1 DESCRIPTION

B<This program> will read the given input subtitle file and merge adjacent lines together that are not seperated by more than the duration
specific so that the combined line's duration will not be more than the given maximum duration.
=cut
