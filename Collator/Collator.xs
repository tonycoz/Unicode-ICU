#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "unicode/ucol.h"

#include "const-c.inc"

typedef UCollator *Unicode__ICU__Collator;

static int32_t
byte_getIndex(UCharIterator *i, UCharIteratorOrigin origin) {
  switch(origin) {
  case UITER_START:
    return 0;
  case UITER_CURRENT:
    return i->index;
  case UITER_LIMIT:
    return i->length;
  case UITER_ZERO:
    return 0;
  case UITER_LENGTH:
    return i->length;
  }
}

static int32_t
byte_move(UCharIterator *i, int32_t delta, UCharIteratorOrigin origin) {
  int32_t index = 0;
  switch(origin) {
  case UITER_START:
    index = delta;
    break;
  case UITER_CURRENT:
    index = i->index + delta;
    break;
  case UITER_LIMIT:
    index = i->length + delta;
    break;
  case UITER_ZERO:
    index = delta;
    break;
  case UITER_LENGTH:
    index = i->length + delta;
    break;
  }

  if (index >= 0 && index <= i->length)
    i->index = index;
}

static UBool
byte_hasNext(UCharIterator *i) {
  return i->index < i->length;
}

static UBool
byte_hasPrevious(UCharIterator *i) {
  return i->index > 0;
}

UChar32
byte_current(UCharIterator *i) {
  if(i->index < i->length) {
    unsigned const char *p = i->context;
    return p[i->index];
  }
  return U_SENTINEL;
}

UChar32
byte_next(UCharIterator *i) {
  if(i->index < i->length) {
    unsigned const char *p = i->context;
    return p[i->index++];
  }
  return U_SENTINEL;
}

UChar32
byte_previous(UCharIterator *i) {
  if (i->index > 0) {
    unsigned const char *p = i->context;
    return p[--(i->index)];
  }
  return U_SENTINEL;
}

uint32_t
byte_getState(const UCharIterator *i) {
  return i->index;
}

void
byte_setState(UCharIterator *i, uint32_t state, UErrorCode *status) {
  if (state > i->length) {
    *status = U_INDEX_OUTOFBOUNDS_ERROR;
  }
  else {
    i->index = state;
  }
}

/* hacky */
void
uiter_setByteString(UCharIterator *c, char const *src, size_t len) {
  c->context = src;
  c->length = len;
  c->start = 0;
  c->index = 0;
  c->limit = len;
  c->getIndex = byte_getIndex;
  c->move = byte_move;
  c->hasNext = byte_hasNext;
  c->hasPrevious = byte_hasPrevious;
  c->current = byte_current;
  c->next = byte_next;
  c->previous = byte_previous;
  c->getState = byte_getState;
  c->setState = byte_setState;
}

MODULE = Unicode::ICU::Collator  PACKAGE = Unicode::ICU::Collator PREFIX = ucol_

PROTOTYPES: DISABLE

Unicode::ICU::Collator
ucol_new(class, loc)
	const char *loc
    PREINIT:
	UErrorCode status = U_ZERO_ERROR;
    CODE:
	RETVAL = ucol_open(loc, &status);
	if (!U_SUCCESS(status)) {
	    croak("Could not create collation for %s: %d", loc, (int)status);
	}
    OUTPUT:
        RETVAL

void
ucol_DESTROY(col)
	Unicode::ICU::Collator col
    CODE:
	ucol_close(col);

int
cmp(col, sv1, sv2)
	Unicode::ICU::Collator col
	SV *sv1
	SV *sv2
    PREINIT:
        UCharIterator c1, c2;
        const char *s1, *s2;
        STRLEN len1, len2;
	UErrorCode status = U_ZERO_ERROR;
    CODE:
        s1 = SvPV(sv1, len1);
        s2 = SvPV(sv2, len2);
        if (SvUTF8(sv1))
          uiter_setUTF8(&c1, s1, len1);
        else
	  uiter_setByteString(&c1, s1, len1);
        if (SvUTF8(sv2))
          uiter_setUTF8(&c2, s2, len2);
        else
	  uiter_setByteString(&c2, s2, len2);
	RETVAL = ucol_strcollIter(col, &c1, &c2, &status);
	if (!U_SUCCESS(status)) {
	    croak("Error comparing: %d", (int)status);
	}
    OUTPUT:
	RETVAL

void
ucol_getLocale(col, type = ULOC_ACTUAL_LOCALE)
	Unicode::ICU::Collator col
	int type
    PREINIT:
       const char *name;
       UErrorCode status = U_ZERO_ERROR;
    PPCODE:
       name = ucol_getLocaleByType(col, type, &status);
       if (!U_SUCCESS(status)) {
         croak("Error getting locale type: %d", status);
       }
       if (name) {
         EXTEND(SP, 1);
	 PUSHs(sv_2mortal(newSVpv(name, 0)));
       }

void
available(...)
    PREINIT:
	int32_t count;
        int32_t i;
    PPCODE:
        count = ucol_countAvailable();
       	EXTEND(SP, count);
        for (i = 0; i < count; ++i) {
          const char *name = ucol_getAvailable(i);
	  PUSHs(sv_2mortal(newSVpv(name, 0)));
        }

INCLUDE: const-xs.inc