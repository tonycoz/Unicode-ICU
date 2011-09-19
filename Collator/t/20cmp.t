#!perl -w
use strict;
use Test::More tests => 10;

use Unicode::ICU::Collator qw(:constants);

my @sorted_names = split /\n/, <<EOS;
Bobrowski
Bodmer
B\xf6hme
B\xf6ll
B\xf6ttcher
Borchert
Born
Brandis
Brant
EOS

{
  # based on
  # http://www.perl.com/pub/2011/08/whats-wrong-with-sort-and-how-to-fix-it.html
  my $col = Unicode::ICU::Collator->new('de@collation=phonebook');
  ok($col, "make de phonebook collator");
  print "# actual: ", $col->getLocale(ULOC_ACTUAL_LOCALE()), "\n";
  print "# valid: ", $col->getLocale(ULOC_VALID_LOCALE()), "\n";
  print "# req: ", $col->getLocale(ULOC_REQUESTED_LOCALE()), "\n";
  my @names = reverse @sorted_names;
  my @sorted = sort { $col->cmp($a, $b) } @names;
  is_deeply(\@sorted, \@sorted_names, "check sorted names");
}

{
  my $col = Unicode::ICU::Collator->new('en');
  my $key_A1 = $col->getSortKey("A");
  ok($key_A1, "make sort key for A");
  print "# ", unpack("H*", $key_A1), "\n";

  # this was broken until I got fuzzy on the buffer lengths
  my $key_A2 = $col->getSortKey("A");
  ok($key_A2, "make sort key for A again");
  print "# ", unpack("H*", $key_A2), "\n";
  
  is($key_A1, $key_A2, "make sure A repeatably returns the same sort key");
  cmp_ok($key_A1, '!~', qr/\0/, "sort key shouldn't contain \\0");
}

#{ # the same with getSortKey
#}
