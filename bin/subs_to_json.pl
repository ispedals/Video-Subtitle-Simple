# PODNAME: subs_to_json
# ABSTRACT:  Converts subtitle files to JSON
use v5.12;
use strict;
use warnings;
use utf8::all;

use Video::Subtitle::OO::ASS::File;
use Video::Subtitle::OO::SRT::File;

use Getopt::Long;
use Pod::Usage;
use File::Slurp;
use JSON;

my $man  = 0;
my $help = 0;
my $input_format;
GetOptions(
    'help|?'         => \$help,
    man              => \$man,
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

my $input_constructor;
if ( $input_format eq 'ass' ) {
    $input_constructor = sub { Video::Subtitle::OO::ASS::File->create_from_string(@_) };
}
else {
    $input_constructor = sub { Video::Subtitle::OO::SRT::File->create_from_string(@_) };
}

my $file = $input_constructor->($input_file);
my @subs = map {
    {
        start => $_->start->as_string,
        end   => $_->end->as_string,
        text  => $_->get_text
    }
} $file->get_subtitles;
print to_json( \@subs, { pretty => 1 } );

=head1 SYNOPSIS

subs_to_json.pl [options] [file]


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

B<This program> will read the given input subtitle file and will convert it to json.
=cut
