# PODNAME: subs_cleaner
# ABSTRACT: Removes dirty characters from subtitle lines
use v5.12;
use utf8;
use strict;
use warnings;
use Encode 'decode_utf8';
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

my %formats = ( ASS => 'SRT', SRT => 'ASS' );
$input_format = uc $input_format;
my $file = ( 'Video::Subtitle::OO::' . $formats{$input_format} . '::File' )->create_from_string($input_file);
my $newfile = ( 'Video::Subtitle::OO::' . $formats{$input_format} . '::File' )->new;

for ( $file->get_subtitles ) {
    my $t = $_->get_text;
    $t = decode_utf8($t);

    next if $t !~ /\p{InJapanese}/;

    $t =~ s/(\[|（).*?(\]|）)//g
      ;    #removes character names denoted like （A） or [B]
    $t =~ s/〈(.*?)\n(.*)〉/$1 $2/g
      ; #removes embedded newlines in parenthetical quotes and removes quote markers themselves
    $t =~ s/≪|…|》|〈|〉|《|～|「|」|♪|≫//g; #verboten characters
    $t =~ s/\n?^$(?)\n?//mg
      ;    #removes the newline both preceeding and proceeding a blank line

    next if $t !~ /\p{InJapanese}/;

    $_->set_text($t);
    $newfile->add_subtitle($_);
}
print $newfile->to_string;

sub InJapanese {
    return <<'END';
+utf8::InHiragana
+utf8::InKatakana
+utf8::InKatakanaPhoneticExtensions
+utf8::InCJKUnifiedIdeographs
END
}

sub InPuct {
    return <<'END';
+utf8::InCJKSymbolsAndPunctuation
+utf8::InHalfwidthAndFullwidthForms
END
}

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

B<This program> will read the given input subtitle file, remove the forbidden characters, and print a new file

=cut
