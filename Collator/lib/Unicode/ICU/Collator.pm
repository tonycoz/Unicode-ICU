package Unicode::ICU::Collator;
use strict;
use Exporter qw(import);

BEGIN {
  our $VERSION = '0.001';
  use XSLoader;
  XSLoader::load('Unicode::ICU::Collator' => $VERSION);
}

{
  my @loc_constants =
    qw(ULOC_ACTUAL_LOCALE ULOC_VALID_LOCALE ULOC_REQUESTED_LOCALE);
  my @attr_constants =
    (
     qw(UCOL_FRENCH_COLLATION UCOL_ALTERNATE_HANDLING UCOL_CASE_FIRST
	UCOL_CASE_LEVEL UCOL_NORMALIZATION_MODE UCOL_DECOMPOSITION_MODE
	UCOL_STRENGTH UCOL_HIRAGANA_QUATERNARY_MODE UCOL_NUMERIC_COLLATION),
     qw(UCOL_DEFAULT UCOL_PRIMARY UCOL_SECONDARY UCOL_TERTIARY
	UCOL_DEFAULT_STRENGTH UCOL_CE_STRENGTH_LIMIT UCOL_QUATERNARY
	UCOL_IDENTICAL UCOL_STRENGTH_LIMIT UCOL_OFF UCOL_ON UCOL_SHIFTED
	UCOL_NON_IGNORABLE UCOL_LOWER_FIRST UCOL_UPPER_FIRST)
     );
    
  our %EXPORT_TAGS =
    (
     locale => \@loc_constants,
     attributes => \@attr_constants,
     constants => [ @loc_constants, @attr_constants ],
    );


  our @EXPORT_OK = map @$_, values %EXPORT_TAGS;
}

sub sort {
  my $self = shift;
  return map $_->[1],
    sort { $a->[0] cmp $b->[0] }
      map [ $self->getSortKey($_), $_ ], @_;
}

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


