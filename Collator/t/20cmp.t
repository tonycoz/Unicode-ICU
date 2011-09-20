#!perl -w
use strict;
use Test::More tests => 21;

use Unicode::ICU::Collator qw(:constants);

# based on
# http://www.perl.com/pub/2011/08/whats-wrong-with-sort-and-how-to-fix-it.html
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

my $L_bar = "\x{023d}"; # L with bar
my $m_mid_tilde = "\x{1d6f}"; # small m with middle tilde

# 325 is combining ring below
# 30A is combining ring above
my $a_under_over = "a\x{0325}\x{030A}";
my $a_over_under = "a\x{030A}\x{0325}";

{
  my $col = Unicode::ICU::Collator->new('de@collation=phonebook');
  ok($col, "make de phonebook collator");
  print "# actual: ", $col->getLocale(ULOC_ACTUAL_LOCALE()), "\n";
  print "# valid: ", $col->getLocale(ULOC_VALID_LOCALE()), "\n";
  print "# req: ", $col->getLocale(ULOC_REQUESTED_LOCALE()), "\n";
  my @names = reverse @sorted_names;
  my @sorted = sort { $col->cmp($a, $b) } @names;
  is_deeply(\@sorted, \@sorted_names, "check sorted names (cmp)");

  is($col->cmp($L_bar, $m_mid_tilde), -1, "compare sure-to-be-utf8 text");
}

{
  my $col = Unicode::ICU::Collator->new('en');
  ok($col, "make en collator");
  my $key_A1 = $col->getSortKey("A");
  ok($key_A1, "make sort key for A");
  print "# ", unpack("H*", $key_A1), "\n";

  # this was broken until I got fuzzy on the buffer lengths
  my $key_A2 = $col->getSortKey("A");
  ok($key_A2, "make sort key for A again");
  print "# ", unpack("H*", $key_A2), "\n";
  
  is($key_A1, $key_A2, "make sure A repeatably returns the same sort key");
  cmp_ok($key_A1, '!~', qr/\0/, "sort key shouldn't contain \\0");

  my $key_a = $col->getSortKey("a");
  ok($key_a, "got key for a");
  print "# ", unpack("H*", $key_a), "\n";
  isnt($key_a, $key_A1, "doesn't equal A key");

  cmp_ok($key_a, 'lt', $key_A1, "a sorts before A");

  my $L_bar_key = $col->getSortKey($L_bar);
  ok($L_bar_key, "made L_bar key");
  print "# ", unpack("H*", $L_bar_key), "\n";
  my $m_tilde_key = $col->getSortKey($m_mid_tilde);
  ok($m_tilde_key, "made m_mid_tilde_key");
  print "# ", unpack("H*", $m_tilde_key), "\n";
  cmp_ok($L_bar_key, 'lt', $m_tilde_key, "make sure they compare ok");

  $col->setAttribute(UCOL_NORMALIZATION_MODE(), UCOL_ON());
  
  my $over_under_key = $col->getSortKey($a_over_under);
  ok($over_under_key, "got key for over under");
  print "# ", unpack("H*", $over_under_key), "\n";
  my $under_over_key = $col->getSortKey($a_under_over);
  ok($under_over_key, "got key for under over");
  print "# ", unpack("H*", $under_over_key), "\n";
  is($over_under_key, $under_over_key, "they should be the same");

  is($col->cmp($a_under_over, $a_over_under), 0,
     "changed mark order should be equal");

  my $m_tilde_many = $m_mid_tilde x 1000;
  my $m_tilde_many_key = $col->getSortKey($m_tilde_many);
  ok($m_tilde_many_key, "try a long sort key");
  print "# long key length: ", length $m_tilde_many_key, "\n";
}

{ # the same with getSortKey
  my $col = Unicode::ICU::Collator->new('de@collation=phonebook');
  ok($col, "make de phonebook collator");
  my @names = reverse @sorted_names;
  my @sorted = map $_->[1],
    sort { $a->[0] cmp $b->[0] }
      map [ $col->getSortKey($_), $_ ], @names;
  is_deeply(\@sorted, \@sorted_names, "check sorted names (getSortKey)");
}
