use strict;
use ExtUtils::MakeMaker;
use Text::ParseWords qw(shellwords);
use ExtUtils::Constant qw(WriteConstants);

my $cflags = `icu-config --cppflags`
  or die "No icu-config --cppflags found\n";
my $libs = `icu-config --ldflags`
  or die "No icu-config libraries\n";
chomp $cflags;
chomp $libs;

# cppflags includes both defines and -I options, separate them out
my @define;
my @inc;
for my $flag (shellwords $cflags) {
  if ($flag =~ /^-I/) {
    push @inc, $flag;
  }
  else {
    push @define, $flag;
  }
}

@define = requote(@define);
@inc = requote(@inc);

my %opts = 
  (
   NAME => 'Unicode::ICU::Collator',
   VERSION_FROM => 'lib/Unicode/ICU/Collator.pm',
   OBJECT => 'Collator.o',
   DEFINE => "@define",
   INC => "@inc",
   LIBS => $libs,
  );
my $eu_mmv = eval $ExtUtils::MakeMaker::VERSION;
if ($eu_mmv > 6.06) {
  $opts{AUTHOR} = 'Tony Cook <tonyc@cpan.org>';
  $opts{ABSTRACT} = 'Wrapper around ICU collation services';
}
if ($eu_mmv > 6.30) {
  $opts{LICENSE} = 'perl';
}

WriteMakefile(%opts);

WriteConstants
  (
   NAME => "Unicode::ICU::Collator",
   NAMES => 
   [
    map
    +{
      name => $_,
      macro => 1
     },
    qw(ULOC_ACTUAL_LOCALE ULOC_VALID_LOCALE ULOC_REQUESTED_LOCALE)
   ],
  );

sub requote {
  return map { / / ? qq("$_") : $_ } @_;
}
