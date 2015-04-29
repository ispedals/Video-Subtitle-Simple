package Video::Subtitle::Simple::Time;

# ABSTRACT: A Time object that supports noninteger seconds
# VERSION

use Carp;
use Scalar::Util 'looks_like_number';
use List::Util 'max';

=head1 SYNOPSIS

    use Video::Subtitle::Simple::Time;

    my $time = Video::Subtitle::Simple::Time->from_string('0:00:03.50');
    print "Hour   : " . $time->hour   . "\n"; #0
    print "Minute : " . $time->minute . "\n"; #0
    print "Second : " . $time->second . "\n"; #3.5

=head1 DESCRIPTION

B<Video::Subtitle::Simple::Time> is a time object that has a similar interface as L<Time::Tiny>,
except that it supports noninteger seconds instead of forcing the use integer seconds.

=head2 Differences from Time::Tiny

B<Video::Subtitle::Simple::Time> provides most of the same methods as L<Time::Tiny>, but there are some
differences that result from handling noninteger seconds.

=for :list
* C<from_string> accepts the ISO 8601 time string type of "hh:mm:ss", but it also accepts
"hh:mm:ss.sss"
* C<as_string> returns a ISO 8601 time string type of "hh:mm:ss.sss"
* The C<second> accessor returns a float instead of an integer
* Accessor methods C<integer_second> and C<millisecond> have been added to easily manipulate
the second component of the time

Methods C<as_subrip_string> and C<from_seconds> have also been added for convenience.

=head1 METHODS

=head2 new

The C<new> method creates a new B<Video::Subtitle::Simple::Time> object from hash with the keys C<hour>, C<minute>, C<second>.

 C<hour> must be a positive integer
 C<minute> must be a positive integer from zero to fifty-nine inclusive
 C<second> must be a float from zero to sixty exclusive

 Returns a new B<Video::Subtitle::Simple::Time> object, or throws an exception on error.


=head2 hour

The C<hours> accessor returns the hour component of the time
as an integer.

=head2 minute

The C<minutes> accessor returns the minute component of the time
as an integer from zero to fifty-nine inclusive (0-60).

=head2 second

The C<second> accessor returns the second component of the time
as a float from zero to fifty-nine inclusive (0-60).

=head2 integer_second

The C<integer_second> accessor returns the integer portion of the second component of the time
as an integer from zero to fifty-nine (0-59).

=head2 millisecond

The C<millisecond> accessor returns the the second component of the time
converted to milliseconds as an integer from 0-59999.


=head2 from_string

The C<from_string> method creates a new B<Video::Subtitle::Simple::Time> object from a string.

The string is expected to be an "hh:mm:ss" type ISO 8601 time string

  my $almost_midnight = Video::Subtitle::Simple::Time->from_string( '23:59:59' );

or an "hh:mm:ss.sss" type ISO 8601 time string

  my $almost_midnight = Video::Subtitle::Simple::Time->from_string( '23:59:59.999' );

 Returns a new B<Video::Subtitle::Simple::Time> object, or throws an exception on error.

=head2 from_seconds

The C<from_seconds> method creates a new B<Video::Subtitle::Simple::Time> object from the time in seconds.

 Returns a new B<Video::Subtitle::Simple::Time> object, or throws an exception on error.

=head2 as_string

The C<as_string> method converts the time object to an ISO 8601
time string, with seperators (see example in C<from_string>).

Returns a string.


=head2 as_subrip_string

The C<as_subrip_string> method is the same as <as_string> except the seconds.milliseconds
separator is a comma.

  my $almost_midnight = Video::Subtitle::Simple::Time->from_string( '23:59:59.999' );
  print $almost_midnight->as_subrip_string; # 23:59:59,999

Returns a string.

=head2 as_seconds

The C<as_seconds> method converts the time object to the duration in seconds.

Returns a float.

=head2 add_seconds

The C<add_seconds> method creates a new B<Video::Subtitle::Simple::Time> object by adding the given seconds to the given object.
The given seconds could be both postive or negative. If the given seconds is negative and would result in a negative time, the time set to zero.

 Returns a new B<Video::Subtitle::Simple::Time> object, or throws an exception on error.


=head1 SEE ALSO

L<DateTime>, L<DateTime::Tiny>, L<Time::Tiny>

=cut

sub new {
    my $class = shift;
    my %self  = @_;

    croak( 'Hour must be a postive integer, given value: ' . $self{hour} )
      unless looks_like_number( $self{hour} )
      && $self{hour} >= 0
      && int( $self{hour} ) == $self{hour};

    croak 'Minute must be a postive integer, given value: ' . $self{minute}
      unless looks_like_number( $self{minute} )
      && $self{minute} >= 0
      && $self{minute} < 60
      && int( $self{minute} ) == $self{minute};

    croak 'Second must be a postive float, given value: ' . $self{second}
      unless looks_like_number( $self{second} )
      && $self{second} >= 0
      && $self{second} < 60;

    return bless \%self, ref($class) || $class;
}

sub hour {
    $_[0]->{hour};
}

sub minute {
    $_[0]->{minute};
}

sub second {
    $_[0]->{second};
}

sub integer_second {
    int( $_[0]->{second} ) || 0;
}

sub millisecond {
    ( $_[0]->{second} * 1000 ) || 0;
}

sub from_string {
    my $string = $_[1];
    unless ( defined $string and !ref $string ) {
        Carp::croak("Did not provide a string to from_string");
    }
    unless ( $string =~ /^(\d{1,2}):(\d\d):(\d\d|(?:\d\d[.,]\d{1,3}))$/ ) {
        Carp::croak(
            "Invalid time format (does not match ISO 8601 hh:mm:ss.sss)");
    }
    my ( $h, $m, $s ) = ( $1, $2, $3 );
    $s =~ s/,/./;
    return $_[0]->new(
        hour   => $h + 0,
        minute => $m + 0,
        second => $s + 0,
    );
}

sub from_seconds {
    use Math::BigFloat;    #need the precision
    my ( $self, $seconds ) = @_;
    my $SECONDS_IN_HOUR        = 3600;
    my $SECONDS_IN_MINUTE      = 60;
    my $MILLISECONDS_IN_SECOND = 1000;

    Carp::croak(
        "Tried to create object using invalid value for seconds: $seconds")
      if $seconds < 0;

    $seconds = Math::BigFloat->new($seconds);

    my $hours = int( $seconds / $SECONDS_IN_HOUR );
    $seconds -= $hours * $SECONDS_IN_HOUR;
    my $minutes = int( $seconds / $SECONDS_IN_MINUTE );
    $seconds -= $minutes * $SECONDS_IN_MINUTE;

    $seconds->precision(-3);

    #convert back to normal numbers by turning them into scalar values
    no bignum;
    $hours   = $hours->bstr;
    $minutes = $minutes->bstr;
    $seconds = $seconds->bstr;

    return $self->new(
        hour   => $hours + 0,
        minute => $minutes + 0,
        second => $seconds + 0,
    );
}

sub add_seconds {
    Carp::croak( 'tried to add non-numeric value ' . $_[1] )
      unless looks_like_number( $_[1] );
    return $_[0]->from_seconds( max( 0, ( $_[0]->as_seconds + $_[1] ) ) );
}

sub as_string {
    sprintf( "%02u:%02u:%06.3f", $_[0]->hour, $_[0]->minute, $_[0]->second, );
}

sub as_subrip_string {
    my $str = $_[0]->as_string;
    $str =~ s/[.]/,/;
    return $str;
}

sub as_seconds {
    return ( $_[0]->hour * 60 * 60 ) + ( $_[0]->minute * 60 ) + $_[0]->second;
}

1;
