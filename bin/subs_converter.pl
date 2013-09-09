## no critic
# PODNAME: subs_converter
# ABSTRACT:  Interconverts between Subrip and ASS subtitle format
# VERSION
use v5.12;
use warnings;

binmode( STDOUT, ":encoding(utf8)" );

use Video::Subtitle::Simple::ASS::File;
use Video::Subtitle::Simple::SRT::File;

use Getopt::Long;
use Pod::Usage;

use File::Slurp;

my $man  = 0;
my $help = 0;
my $input_format;
my $encoding;
GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'input-format=s' => \$input_format,
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
print +( 'Video::Subtitle::Simple::' . $formats{$input_format} . '::File' )
  ->create_from_subtitle(
    ( 'Video::Subtitle::Simple::' . $input_format . '::File' )
    ->create_from_string($input_file) )->to_string;

=head1 SYNOPSIS

subs_converter.pl [options] [file]

Options:
    -help brief help message
    -man full documentation
    -input-format format of the original subtitle; either 'ass' or 'srt'
    -encoding the format the subtite is encoded in; default is utf8

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-input-format>

the format of the original subtitle; either 'ass' or 'srt'

=item B<-encoding>

the format the subtite is encoded in. See L<Encode::Supported> for valid values. Default is utf8

=back

=head1 DESCRIPTION

B<This program> will read the given input subtitle file and will convert it to either a Subrip or ASS subtitle file. The file could also
be piped in
=cut
