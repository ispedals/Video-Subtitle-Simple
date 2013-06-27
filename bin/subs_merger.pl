## no critic
# PODNAME: subs_merger
# ABSTRACT:  Merges subtitle lines together
# VERSION
use v5.12;
use strict;
use warnings;
use Encode 'decode_utf8';
use utf8::all;

use Video::Subtitle::OO::ASS::File;
use Video::Subtitle::OO::ASS::Subtitle;
use Video::Subtitle::OO::SRT::File;
use Video::Subtitle::OO::SRT::Subtitle;

use Getopt::Long;
use Pod::Usage;

use File::Slurp;

my $man  = 0;
my $help = 0;
my $input_format;
my $max_duration;
GetOptions(
    'help|?'         => \$help,
    man              => \$man,
    'input_format=s' => \$input_format,
    'duration=f'     => \$max_duration
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage( -verbose => 2 ) if $man;

my $input_file;
if ( @ARGV == 0 && !-t STDIN ) {
    $input_file = read_file( \*STDIN );
}
elsif ( @ARGV == 0 ) {
    pod2usage("$0: No subtitle filename given.");
}
else {
    die "Invalid filename $ARGV[0]" unless -e $ARGV[0];
    $input_file = read_file( $ARGV[0] );
}

my %formats = ( ASS => 'SRT', SRT => 'ASS' );
$input_format = uc $input_format;

no strict 'refs';
my $file = ( 'Video::Subtitle::OO::' . $formats{$input_format} . '::File' )->create_from_string($input_file);

my @hugeset;    #is a list containing a list of subtitles that need to be merged

my @subtitles = $file->get_subtitles;

my $last_sub = shift @subtitles;
my @subs     = ($last_sub);                    #temp list to hold subtitles
my $duration = $last_sub->duration->as_seconds;

foreach (@subtitles) {
    if ( $duration < $max_duration
        && ( $_->start->as_seconds - $last_sub->end->as_seconds ) < $max_duration )
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

$file = ( 'Video::Subtitle::OO::' . $formats{$input_format} . '::File' )->new;

foreach (@hugeset) {
    my $line = ( 'Video::Subtitle::OO::' . $formats{$input_format} . '::Subtitle' )->(
        start => $_->[0]->start->as_string,
        end   => $_->[-1]->end->as_string
    );
    my $text = q{};
    foreach my $l ( @{$_} ) {
        $text .= decode_utf8( $l->get_text ) . "\n";
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
    -input_format format of the original subtitle; either 'ass' or 'srt'
    -duration the maximum duration of a line

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-input_format>

the format of the original subtitle; either 'ass' or 'srt'

=item B<-duration>

the maximum duration of a line

=back

=head1 DESCRIPTION

B<This program> will read the given input subtitle file and merge adjacent lines together that are not seperated by more than the duration
specific so that the combined line's duration will not be more than the given maximum duration.
=cut
