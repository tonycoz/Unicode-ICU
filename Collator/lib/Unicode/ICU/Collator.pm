package Unicode::ICU::Collator;
use strict;
use Exporter qw(import);

BEGIN {
  our $VERSION = '0.001';
  use XSLoader;
  XSLoader::load('Unicode::ICU::Collator' => $VERSION);
}

our %EXPORT_TAGS =
  (
   constants =>
   [ qw(ULOC_ACTUAL_LOCALE ULOC_VALID_LOCALE ULOC_REQUESTED_LOCALE) ],
  );

our @EXPORT_OK = map @$_, values %EXPORT_TAGS;

sub CLONE_SKIP { 1 }

sub AUTOLOAD {
  our $AUTOLOAD;

  (my $constname = $AUTOLOAD) =~ s/.*:://;
  my ($error, $val) = constant($constname);
  if ($error) {
    require Carp;
    Carp::croak($error);
  }

  {
    no strict 'refs';
    *$AUTOLOAD = sub { $val };
  }

  goto &$AUTOLOAD;
}

# everything else is XS
1;

__END__

=head1 NAME

Uncode::ICU::Collator - wrapper around ICU collation services


=head1 LICENSE

Unicode::ICU::Collator is licensed under the same terms as Perl itself.

=head1 AUTHOR

Tony Cook <tonyc@cpan.org>

=cut


