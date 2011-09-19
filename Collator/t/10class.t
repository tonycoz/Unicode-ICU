#!perl -w
use strict;
use Test::More tests => 3;

BEGIN { use_ok("Unicode::ICU::Collator") }

{
  my @avail = Unicode::ICU::Collator->available;
  ok(@avail, "at least some are available");
  my ($en) = grep $_ eq "en", @avail;
  ok($en, "en is available");
}
