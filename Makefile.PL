use strict;
use ExtUtils::MakeMaker;

die "This does nothing for now, the important bit is in Collator/";

my %opts = 
  (
   NAME => 'Unicode::ICU',
   VERSION_FROM => 'ICU.pm',
   OBJECT => 'ICU.o',
  );
my $eu_mmv = eval $ExtUtils::MakeMaker::VERSION;
if ($eu_mmv > 6.06) {
  $opts{AUTHOR} = 'Tony Cook <tonyc@cpan.org>';
  $opts{ABSTRACT} = 'General ICU wrapper';
}
if ($eu_mmv > 6.30) {
  $opts{LICENSE} = 'perl';
}

WriteMakefile(%opts);


