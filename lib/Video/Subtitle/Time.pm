package Video::Subtitle::Time;
# ABSTRACT: A Time object that supports noninteger seconds

=head1 SYNOPSIS

    use Video::Subtitle::Time;

    my $time = Video::Subtitle::Time->from_string('0:00:03.50');
    print "Hour   : " . $time->hour   . "\n"; #0
    print "Minute : " . $time->minute . "\n"; #0
    print "Second : " . $time->second . "\n"; #3.5

=head1 DESCRIPTION

b<Subtitles::Time> is a time object that has the same interface as L<Time::Tiny>,
except that it supports noninteger seconds instead of forcing the use integer seconds.

=head2 Differences from Time::Tiny

B<Subtitles::Time> provides all of the same methods as L<Time::Tiny>, but there are some
differences that result from handling noninteger seconds.

=for :list
* C<from_string> accepts the ISO 8601 time string type of "hh:mm:ss", but it also accepts
"hh:mm:ss.sss"
* C<as_string> returns a ISO 8601 time string type of "hh:mm:ss.sss"
* The C<second> accessor no longer returns a float instead of an integer
* Accessor methods C<integer_second> and C<millisecond> have been added to easily manipulate
the second component of the time

Methods C<as_subrip_string> and C<from_seconds> have also been added for convenience.

=head1 METHODS

See L<Time::Tiny> for the complete API and cavaets. Only methods that differ from L<Time::Tiny>
are documented here.

=head2 second

The C<second> accessor returns the second component of the time
as a float from zero to fifty-nine exclusive (0-60).

=head2 integer_second

The C<integer_second> accessor returns the integer portion of the second component of the time
as an integer from zero to fifty-nine (0-59).

=head2 millisecond

The C<millisecond> accessor returns the the second component of the time
converted to milliseconds as an integer from 0-59999.


=head2 from_string

The C<from_string> method creates a new B<Time::Tiny> object from a string.

The string is expected to be an "hh:mm:ss" type ISO 8601 time string

  my $almost_midnight = Time::Tiny->from_string( '23:59:59' );

or an "hh:mm:ss.sss" type ISO 8601 time string

  my $almost_midnight = Time::Tiny->from_string( '23:59:59.999' );

 Returns a new B<Time::Tiny> object, or throws an exception on error.

=head2 from_seconds

The C<from_seconds> method creates a new B<Time::Tiny> object from the time in seconds.

 Returns a new B<Time::Tiny> object, or throws an exception on error.

=head2 as_string

The C<as_string> method converts the time object to an ISO 8601
time string, with seperators (see example in C<from_string>).

Returns a string.


=head2 as_subrip_string

The C<as_subrip_string> method is the same as <as_string> except the seconds.milliseconds
separator is a comma.

  my $almost_midnight = Time::Tiny->from_string( '23:59:59.999' );
  print $almost_midnight->as_subrip_string; # 23:59:59,999

Returns a string.

=head1 SEE ALSO

L<DateTime>, L<DateTime::Tiny>, L<Time::Tiny>

=cut

use parent 'Time::Tiny';

sub integer_second {
    int($_[0]->{second}) || 0;
}

sub millisecond {
    ($_[0]->{second}*1000) || 0;
}

sub from_string {
	my $string = $_[1];
    unless ( defined $string and ! ref $string ) {
        Carp::croak("Did not provide a string to from_string");
    }
    unless ( $string =~ /^(\d{1,2}):(\d\d):(\d\d|(?:\d\d[.,]\d{1,3}))$/ ) {
        Carp::croak("Invalid time format (does not match ISO 8601 hh:mm:ss.sss)");
    }
	my ($h, $m, $s) = ($1, $2, $3);
	$s =~ s/,/./;
    return $_[0]->new(
        hour   => $h + 0,
        minute => $m + 0,
        second => $s + 0,
    );
}

sub from_seconds {
    my ( $self, $seconds ) = @_;
    my $SECONDS_IN_HOUR        = 3600;
    my $SECONDS_IN_MINUTE      = 60;
    my $MILLISECONDS_IN_SECOND = 1000;
    use Math::BigFloat;    #need the precision

    $seconds = Math::BigFloat->new($seconds);

    my $hours = int( $seconds / $SECONDS_IN_HOUR );
    $seconds -= $hours * $SECONDS_IN_HOUR;
    my $minutes = int( $seconds / $SECONDS_IN_MINUTE );
    $seconds -= $minutes * $SECONDS_IN_MINUTE;

    $seconds->precision(-3);

    #convert back to normal numbers by turning them into scalar values
	no bignum;
    $hours           = $hours->bstr;
    $minutes         = $minutes->bstr;
    $seconds         = $seconds->bstr;

	return $self->new(
        hour   => $hours + 0,
        minute => $minutes + 0,
        second => $seconds + 0,
    );
}

sub as_string {
    sprintf( "%02u:%02u:%06.3f",
        $_[0]->hour,
        $_[0]->minute,
        $_[0]->second,
    );
}

sub as_subrip_string {
    my $str = $_[0]->as_string;
    $str =~ s/[.]/,/;
    return $str;
}

sub DateTime {
    require DateTime;
    my $self = shift;
    DateTime->new(
        year      => 1970,
        month     => 1,
        day       => 1,
        hour      => $self->hour,
        minute    => $self->minute,
        nanosecond    => $self->second * 1e9,
        locale    => 'C',
        time_zone => 'floating',
        @_,
    );
}

1;