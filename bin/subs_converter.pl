## no critic
# PODNAME: subs_converter
# ABSTRACT:  Interconverts between Subrip and ASS subtitle format
# VERSION
use v5.12;
use warnings;
use utf8::all;

use Video::Subtitle::OO::ASS::File;
use Video::Subtitle::OO::SRT::File;
use File::Slurp;
use Getopt::Long;
use Pod::Usage;

my $man  = 0;
my $help = 0;
my $input_format;

GetOptions(
    'help|?'         => \$help,
    'man'            => \$man,
    'input_format=s' => \$input_format,
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
print +( 'Video::Subtitle::OO::' . $formats{$input_format} . '::File' )
  ->create_from_subtitle( ( 'Video::Subtitle::OO::' . $input_format . '::File' )
    ->create_from_string($input_file) )->to_string;

=head1 SYNOPSIS

subs_converter.pl [options] [file]

Options:
    -help brief help message
    -man full documentation
    -input_format format of the original subtitle; either 'ass' or 'srt'

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the manual page and exits.

=item B<-input_format>

the format of the original subtitle; either 'ass' or 'srt'

=back

=head1 DESCRIPTION

B<This program> will read the given input subtitle file and will convert it to either a Subrip or ASS subtitle file. The file could also
be piped in
=cut
